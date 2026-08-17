import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:mpd_remote_z/model/song_art.dart';
import 'package:mpd_remote_z/mpd/model/mpd_song.dart';

extension MediaItemExt on MediaItem {
  MpdSong? get mpdSong =>
      extras?["mpdSong"] == null ? null : MpdSong.fromJson(extras?["mpdSong"]);
  ColorScheme? get colorScheme => extras?["colorScheme"] == null
      ? null
      : ColorSchemeExt.fromJson(extras?["colorScheme"]);
  String? get file => extras?["file"];
}
