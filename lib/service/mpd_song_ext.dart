import 'dart:async';
import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:mpd_remote_z/main.dart';
import 'package:mpd_remote_z/model/song_art.dart';
import 'package:mpd_remote_z/mpd/model/mpd_song.dart';
import 'package:path_provider/path_provider.dart';

extension MpdSongExt on MpdSong {
  Future<MediaItem> toMediaItem({bool withArt = true}) async {
    SongArt? art;
    Uri? artUri;
    ColorScheme? cs;
    if (withArt) {
      art = await SongArt.findByData(song: this);
      artUri = await art?.uri;
      cs = art?.colorScheme;
      if (art == null) {
        final docDir = await getApplicationSupportDirectory();
        artUri = File('${docDir.path}/$defaultCoverHash').uri;
      }
    }
    return MediaItem(
      id: id.toString(),
      title: title,
      album: album,
      artist: artist,
      duration: duration != null
          ? Duration(milliseconds: ((duration ?? 0.0) * 1000.0).toInt())
          : time != null
          ? Duration(milliseconds: ((time ?? 0.0) * 1000.0).toInt())
          : null,
      artUri: artUri,
      displayTitle: title,
      displaySubtitle: description,
      genre: genre,
      displayDescription: description,
      playable: true,
      // isLive: true,
      isLive: false,
      extras: {"file": file, "colorScheme": cs?.toJson(), "mpdSong": toJson()},
    );
  }
}
