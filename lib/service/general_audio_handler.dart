import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:mpd_remote_z/model/server_info.dart';
import 'package:mpd_remote_z/model/song_art.dart';
import 'package:mpd_remote_z/mpd/model/mpd_consume_mode.dart';
import 'package:mpd_remote_z/mpd/model/mpd_count.dart';
import 'package:mpd_remote_z/mpd/model/mpd_random_mode.dart';
import 'package:mpd_remote_z/mpd/model/mpd_repeat_mode.dart';
import 'package:mpd_remote_z/mpd/model/mpd_single_mode.dart';
import 'package:mpd_remote_z/mpd/model/mpd_song.dart';
import 'package:mpd_remote_z/mpd/model/mpd_state.dart';
import 'package:mpd_remote_z/mpd/model/mpd_stats.dart';
import 'package:mpd_remote_z/mpd/model/mpd_status.dart';
import 'package:mpd_remote_z/mpd/model/mpd_tag_group.dart';
import 'package:mpd_remote_z/mpd/mpd_client.dart';
import 'package:mpd_remote_z/mpd/string_ext.dart';
import 'package:mpd_remote_z/service/audio_handler_custom.dart';
import 'package:mpd_remote_z/service/debouncer.dart';
import 'package:mpd_remote_z/service/media_item_ext.dart';
import 'package:mpd_remote_z/service/mpd_song_ext.dart';
import 'package:mpd_remote_z/service/mpd_status_ext.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'custom_action.dart';

enum AudioHandlerEvent {
  connect,
  disconnet,
  preDisconnet,
  statusUpdate,
  statsUpdate,
  storedPlaylistUpdate,
  stop,
  outputUpdate,
  partitionChange,
}

class GeneralAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  GeneralAudioHandler() {
    _custom = AudioHandlerCustom(this);
  }

  late AudioHandlerCustom _custom;
  MpdClient? _mpdClient;
  MpdStatus? mpdStatus;
  MpdSong? mpdSong;
  MpdStats? mpdStats;
  String? serverId;
  Completer<bool> _playPauseCompleter = Completer();
  MpdAutoIdle? autoIdle;

  AudioHandlerCustom get custom => _custom;

  final Debouncer _volumeDebouncer = Debouncer(
    delay: Duration(milliseconds: 300),
  );

  Future<void> _updateStatus() async {
    var status = (await _mpdClient?.status());
    if (status?.isValid == true) {
      mpdStatus = status!.data;
      // mpdStatus.state
      customEvent.add(AudioHandlerEvent.statusUpdate);
      playbackState.add(mpdStatus!.toPlaybackState());
      androidPlaybackInfo.add(
        RemoteAndroidPlaybackInfo(
          volumeControlType: AndroidVolumeControlType.absolute,
          maxVolume: 100,
          volume: mpdStatus?.volume ?? 0,
        ),
      );
    }
  }

  Future<void> _updateStats() async {
    var stats = (await _mpdClient?.stats());
    if (stats?.isValid == true) {
      mpdStats = stats!.data;
      customEvent.add(AudioHandlerEvent.statsUpdate);
    }
  }

  Future<void> _updateMediaItemArt() async {
    try {
      debugPrint("start read picture");
      var pic = await _mpdClient?.readPicture(mpdSong!.file);
      debugPrint("end read picture");
      if (pic?.isValid != true) {
        debugPrint("invalid image");
        await SongArt.saveWithDefault(song: mpdSong!);
      } else {
        debugPrint("save image");
        var art = await SongArt.create(song: mpdSong!, bytes: pic!.data.data);
        debugPrint("update media item");
        mediaItem.add(
          mediaItem.value!.copyWith(
            artUri: await art.uri,
            extras: {
              ...mediaItem.value!.extras!,
              "colorScheme": art.colorScheme.toJson(),
            },
          ),
        );
      }
    } catch (e, s) {
      debugPrintStack(stackTrace: s, label: e.toString());
    }
  }

  Future _mpdUpdateCurrentSong() async {
    debugPrint("update song");
    var song = (await _mpdClient?.currentSong());
    if (!(song?.isValid == true)) {
      return;
    }

    mpdSong = song!.data;

    if (mpdSong != null) {
      if (mediaItem.value?.file != mpdSong!.file) {
        mediaItem.add(await mpdSong!.toMediaItem());
        var uri = mediaItem.value?.artUri;
        if (mediaItem.value?.colorScheme == null ||
            uri != null && !File.fromUri(uri).existsSync()) {
          await _updateMediaItemArt();
        }
      }
      await _updateStatus();
      if (!_playPauseCompleter.isCompleted) {
        _playPauseCompleter.complete(true);
      }
    } else {
      mediaItem.add(null);
      playbackState.add(playbackState.value.copyWith(playing: false));
    }
  }

  Future _mpdUpdateQueue() async {
    var playlistInfo = await _mpdClient?.playlistInfo();
    if (playlistInfo!.isValid) {
      if (playlistInfo.data.isEmpty) {
        await _updateStatus();
      }
      queue.add(
        await Future.wait(
          playlistInfo.data.map((e) async => await e.toMediaItem()).toList(),
        ),
      );
    }
  }

  Future<void> _playOrPause() async {
    if (_playPauseCompleter.isCompleted) {
      _playPauseCompleter = Completer();
    }
    switch (mpdStatus?.state) {
      case MpdState.play:
        await _mpdClient?.pause(1);
        break;
      case MpdState.pause:
        await _mpdClient?.pause(0);
        break;
      case MpdState.stop:
        await _mpdClient?.play(0);
        break;
      default:
        break;
    }

    await _playPauseCompleter.future;
  }

  Future<void> _disconnect({bool isStop = false, bool consent = false}) async {
    if (consent) {
      customEvent.add(AudioHandlerEvent.preDisconnet);
    }
    mediaItem.add(null);
    queue.add([]);
    playbackState.add(
      playbackState.value.copyWith(
        errorCode: -1,
        errorMessage: "disconnected",
        playing: false,
      ),
    );
    super.stop();
    await autoIdle?.noIdle();
    await _mpdClient?.disconnect();
    _mpdClient = null;
    customEvent.add(
      isStop ? AudioHandlerEvent.stop : AudioHandlerEvent.disconnet,
    );
  }

  Future<void> _initAutoIdle() async {
    try {
      autoIdle = await _mpdClient!.autoIdle(
        onPlayer: () => _mpdUpdateCurrentSong(),
        onConnectionError: () {
          _disconnect();
        },
        onOptions: () => _updateStatus(),
        onPlaylist: () => _mpdUpdateQueue(),
        onMixer: () => _updateStatus(),
        onStoredPlaylist: () =>
            customEvent.add(AudioHandlerEvent.storedPlaylistUpdate),
        onDatabase: () {
          _updateStats();
        },
        onPartition: () {
          // cekPartitionChange();
        },
        onOutput: () => customEvent.add(AudioHandlerEvent.outputUpdate),
      );
    } catch (e, s) {
      debugPrintStack(stackTrace: s, label: e.toString());
      rethrow;
    }
  }

  Future<T?> _cacheData<T>({
    required String command,
    required String args,
    required Future<T?> Function() compute,
    required FutureOr<T?> Function(String json) decode,
  }) async {
    SharedPreferencesAsync prefs = SharedPreferencesAsync();
    var dbDate = mpdStats?.dbUpdate.toIso8601String() ?? "null";
    var key = "$serverId-$dbDate-$command-$args";
    var cached = await prefs.getString(key);
    if (cached != null) {
      return decode(cached);
    }
    var data = await compute();
    if (data == null) return null;
    await prefs.setString(key, jsonEncode(data));

    return data;
  }

  @override
  Future<void> play() async {
    await _playOrPause();
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    await _mpdClient?.play(index);
    return super.skipToQueueItem(index);
  }

  @override
  Future<void> pause() async {
    await _playOrPause();
  }

  @override
  Future<void> stop() async {
    await _disconnect(isStop: true);
  }

  @override
  Future<void> skipToNext() async {
    await _mpdClient?.next();
  }

  @override
  Future<void> skipToPrevious() async {
    await _mpdClient?.previous();
  }

  @override
  Future<void> seek(Duration position) async {
    await _mpdClient?.seekCur(position.inMilliseconds.toDouble() / 1000.0);
  }

  @override
  Future<void> playFromMediaId(
    String mediaId, [
    Map<String, dynamic>? extras,
  ]) async {
    await _mpdClient?.playId(int.parse(mediaId));
  }

  @override
  Future<void> androidSetRemoteVolume(int volumeIndex) async {
    androidPlaybackInfo.add(
      RemoteAndroidPlaybackInfo(
        volumeControlType: AndroidVolumeControlType.absolute,
        maxVolume: 100,
        volume: volumeIndex,
      ),
    );

    await _volumeDebouncer.run(() {
      var volume = volumeIndex;
      _mpdClient?.setVol(volume);
    });
  }

  @override
  Future<void> androidAdjustRemoteVolume(
    AndroidVolumeDirection direction,
  ) async {
    if (direction == AndroidVolumeDirection.same) {
      return super.androidAdjustRemoteVolume(direction);
    }
    var beforeVolume =
        (androidPlaybackInfo.value as RemoteAndroidPlaybackInfo).volume;
    androidPlaybackInfo.add(
      RemoteAndroidPlaybackInfo(
        volumeControlType: AndroidVolumeControlType.absolute,
        maxVolume: 100,
        volume: beforeVolume + direction.index,
      ),
    );

    await _volumeDebouncer.run(() {
      var volume = beforeVolume + direction.index;
      _mpdClient?.setVol(volume);
    });
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    await _mpdClient?.add(mediaItem.file!);
  }

  @override
  Future<void> insertQueueItem(int index, MediaItem mediaItem) async {
    await _mpdClient?.add(mediaItem.file!, position: index.toString());
  }

  @override
  Future<dynamic> customAction(
    String name, [
    Map<String, dynamic>? extras,
  ]) async {
    return CustomAction.values
            .where((element) => element.name == name)
            .firstOrNull
            ?._action(this, extras) ??
        super.customAction(name, extras);
  }
}
