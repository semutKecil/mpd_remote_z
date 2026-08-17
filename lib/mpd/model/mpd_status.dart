import 'package:mpd_remote_z/mpd/model/mpd_consume_mode.dart';
import 'package:mpd_remote_z/mpd/model/mpd_random_mode.dart';
import 'package:mpd_remote_z/mpd/model/mpd_repeat_mode.dart';
import 'package:mpd_remote_z/mpd/model/mpd_single_mode.dart';
import 'package:mpd_remote_z/mpd/model/mpd_state.dart';

class MpdStatus {
  /// partition: the name of the current partition (see Partition commands)
  /// volume: 0-100 (deprecated: -1 if the volume cannot be determined)
  /// repeat: 0 or 1
  /// random: 0 or 1
  /// single 2: 0, 1, or oneshot 6
  /// consume 2: 0, 1 or oneshot 13
  /// playlist: 31-bit unsigned integer, the playlist version number
  /// playlistlength: integer, the length of the playlist
  /// state: play, stop, or pause
  /// song: playlist song number of the current song stopped on or playing
  /// songid: playlist songid of the current song stopped on or playing
  /// nextsong 2: playlist song number of the next song to be played
  /// nextsongid 2: playlist songid of the next song to be played
  /// time: total time elapsed (of current playing/paused song) in seconds (deprecated, use elapsed instead)
  /// elapsed 3: Total time elapsed within the current song in seconds, but with higher resolution.
  /// duration 5: Duration of the current song in seconds.
  /// bitrate: instantaneous bitrate in kbps
  /// xfade: crossfade in seconds (see Cross-Fading)
  /// mixrampdb: mixramp threshold in dB
  /// mixrampdelay: mixrampdelay in seconds
  /// audio: The format emitted by the decoder plugin during playback, format: samplerate:bits:channels. See Global Audio Format for a detailed explanation.
  /// updating_db: job id
  /// error: if there is an error, returns message here
  /// lastloadedplaylist: last loaded stored playlist 13
  final String partition;
  final int? volume;
  final MpdRepeatMode repeat;
  final MpdRandomMode random;
  final MpdSingleMode single;
  final MpdConsumeMode consume;
  final int playlist;
  final int playlistLength;
  final MpdState state;
  final int? song;
  final int? songId;
  final int? nextSong;
  final int? nextSongId;
  final String? time;
  final double? elapsed;
  final double? duration;
  final double? bitrate;
  final double? xfade;
  final double? mixrampDb;
  final double? mixrampDelay;
  final String? audio;
  final int? updatingDb;
  final String? error;
  final String? lastLoadedPlaylist;
  const MpdStatus({
    required this.partition,
    required this.repeat,
    required this.random,
    required this.single,
    required this.consume,
    required this.playlist,
    required this.playlistLength,
    required this.state,
    this.mixrampDb,
    this.time,
    this.elapsed,
    this.duration,
    this.bitrate,
    this.xfade,
    this.mixrampDelay,
    this.audio,
    this.updatingDb,
    this.volume,
    this.error,
    this.song,
    this.songId,
    this.nextSong,
    this.nextSongId,
    this.lastLoadedPlaylist,
  });

  /// Convert MpdStatus to JSON map
  Map<String, dynamic> toJson() {
    final jsonMap = <String, dynamic>{
      'partition': partition,
      'repeat': repeat.value,
      'random': random.value,
      'single': single.value,
      'consume': consume.value,
      'playlist': playlist,
      'playlistLength': playlistLength,
      'state': state.name,
    };

    if (mixrampDb != null) jsonMap['mixrampDb'] = mixrampDb;
    if (volume != null) jsonMap['volume'] = volume;
    if (song != null) jsonMap['song'] = song;
    if (songId != null) jsonMap['songId'] = songId;
    if (nextSong != null) jsonMap['nextSong'] = nextSong;
    if (nextSongId != null) jsonMap['nextSongId'] = nextSongId;
    if (time != null) jsonMap['time'] = time;
    if (elapsed != null) jsonMap['elapsed'] = elapsed;
    if (duration != null) jsonMap['duration'] = duration;
    if (bitrate != null) jsonMap['bitrate'] = bitrate;
    if (xfade != null) jsonMap['xfade'] = xfade;
    if (mixrampDelay != null) jsonMap['mixrampDelay'] = mixrampDelay;
    if (audio != null) jsonMap['audio'] = audio;
    if (updatingDb != null) jsonMap['updatingDb'] = updatingDb;
    if (error != null) jsonMap['error'] = error;
    if (lastLoadedPlaylist != null) {
      jsonMap['lastLoadedPlaylist'] = lastLoadedPlaylist;
    }

    return jsonMap;
  }

  /// Create MpdStatus from JSON map
  factory MpdStatus.fromJson(Map<String, dynamic> json) {
    return MpdStatus(
      partition: json['partition'] as String,
      volume: json['volume'] as int?,
      repeat: MpdRepeatMode.parseMpdRepeatMode(json['repeat']),
      random: MpdRandomMode.parseMpdRandomMode(json['random']),
      single: MpdSingleMode.parseMpdSingleMode(json['single']),
      consume: MpdConsumeMode.parseMpdConsumeMode(json['consume']),
      playlist: json['playlist'] as int,
      playlistLength: json['playlistLength'] as int,
      state: MpdState.parseMpdState(json['state']),
      song: json['song'] as int?,
      songId: json['songId'] as int?,
      nextSong: json['nextSong'] as int?,
      nextSongId: json['nextSongId'] as int?,
      time: json['time'] as String?,
      elapsed: json['elapsed'] as double?,
      duration: json['duration'] as double?,
      bitrate: json['bitrate'] as double?,
      xfade: json['xfade'] as double?,
      mixrampDb: json['mixrampDb'] as double,
      mixrampDelay: json['mixrampDelay'] as double?,
      audio: json['audio'] as String?,
      updatingDb: json['updatingDb'] as int?,
      error: json['error'] as String?,
      lastLoadedPlaylist: json['lastLoadedPlaylist'] as String?,
    );
  }
}
