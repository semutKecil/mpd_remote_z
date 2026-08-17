import 'dart:convert';
import 'dart:typed_data';
import 'package:mpd_remote_z/mpd/model/mpd_consume_mode.dart';
import 'package:mpd_remote_z/mpd/model/mpd_count.dart';
import 'package:mpd_remote_z/mpd/model/mpd_output.dart';
import 'package:mpd_remote_z/mpd/model/mpd_random_mode.dart';
import 'package:mpd_remote_z/mpd/model/mpd_repeat_mode.dart';
import 'package:mpd_remote_z/mpd/model/mpd_single_mode.dart';
import 'package:mpd_remote_z/mpd/model/mpd_state.dart';
import 'package:mpd_remote_z/mpd/model/mpd_stats.dart';
import 'package:mpd_remote_z/mpd/model/mpd_song.dart';
import 'package:mpd_remote_z/mpd/model/mpd_status.dart';
import 'package:mpd_remote_z/mpd/model/mpd_tag_group.dart';
import 'package:mpd_remote_z/mpd/model/mpd_binary.dart';
import 'package:mpd_remote_z/mpd/uint8_list_ext.dart';

extension ListExt<T> on List<T> {
  MpdBinary toMpdBinary() {
    var lastData = last;
    if (lastData is Uint8List && lastData.startsWithString("ACK")) {
      throw Exception(String.fromCharCodes(lastData));
    }

    int? size;
    String? type;
    int binary = 0;
    Uint8List data = Uint8List(0);

    for (var i = 0; i < length; i++) {
      var bin = this[i] as Uint8List;

      if (bin.startsWithString("size")) {
        var spl = String.fromCharCodes(bin).split(": ");
        size = int.parse(spl[1]);
      }

      if (bin.startsWithString("type")) {
        var spl = String.fromCharCodes(bin).split(": ");
        type = spl[1];
      }

      if (bin.startsWithString("binary")) {
        var spl = String.fromCharCodes(bin).split(": ");
        binary = int.parse(spl[1]);
        data = this[i + 1] as Uint8List;
        break;
      }
    }

    return MpdBinary(size: size, binary: binary, data: data, type: type);
  }

  List<dynamic> toMpdFilesList() {
    return toMpdDynamicList({
      "file": (data) {
        return _toMpdSongFromMap(data);
      },
      "directory": (data) {
        return _toMpdDirectoryFromMap(data);
      },
      "playlist": (data) {
        return _toMpdPlaylistFromMap(data);
      },
    });
  }

  MpdStatus toMpdStatus() {
    var data = toMpdMap();
    return MpdStatus(
      repeat: MpdRepeatMode.values.firstWhere(
        (e) => e.value == data["repeat"]?.first,
      ),
      random: MpdRandomMode.values.firstWhere(
        (e) => e.value == data["random"]?.first,
      ),
      single: MpdSingleMode.values.firstWhere(
        (e) => e.value == data["single"]?.first,
      ),
      consume: MpdConsumeMode.values.firstWhere(
        (e) => e.value == data["consume"]?.first,
      ),
      partition: data["partition"]?.first,
      playlist: int.parse(data["playlist"]?.first.toString() ?? ""),
      playlistLength: int.parse(data["playlistlength"]?.first.toString() ?? ""),
      mixrampDb: double.parse(data["mixrampdb"]?.first.toString() ?? ""),
      state: MpdState.values.firstWhere((e) => e.name == data["state"]?.first),
      volume: int.tryParse(data["volume"]?.first.toString() ?? ""),
      song: int.tryParse(data["song"]?.first.toString() ?? ""),
      songId: int.tryParse(data["songid"]?.first.toString() ?? ""),
      time: data["time"]?.first,
      elapsed: double.tryParse(data["elapsed"]?.first.toString() ?? ""),
      bitrate: double.tryParse(data["bitrate"]?.first.toString() ?? ""),
      duration: double.tryParse(data["duration"]?.first.toString() ?? ""),
      audio: data["audio"]?.first,
      nextSong: int.tryParse(data["nextsong"]?.first.toString() ?? ""),
      nextSongId: int.tryParse(data["nextsongid"]?.first.toString() ?? ""),
      error: data["error"]?.first,
      mixrampDelay: double.tryParse(
        data["mixrampdelay"]?.first.toString() ?? "",
      ),
      xfade: double.tryParse(data["xfade"]?.first.toString() ?? ""),
      updatingDb: int.tryParse(data["updating_db"]?.first.toString() ?? ""),
      lastLoadedPlaylist: data["lastloadedplaylist"]?.first,
    );
  }

  MpdStats toMpdStats() {
    var data = toMpdMap();

    return MpdStats(
      albums: int.parse(data["albums"]?.first),
      artists: int.parse(data["artists"]?.first),
      playtime: int.parse(data["playtime"]?.first),
      songs: int.parse(data["songs"]?.first),
      uptime: int.parse(data["uptime"]?.first),
      dbPlaytime: int.parse(data["db_playtime"]?.first),
      dbUpdate: DateTime.fromMillisecondsSinceEpoch(
        int.parse(data["db_update"]?.first) * 1000,
      ),
    );
  }

  List<MpdSong> toMpdSongList() {
    return toMpdDynamicList({
      "file": (data) {
        return _toMpdSongFromMap(data);
      },
    }).whereType<MpdSong>().toList();
  }

  List<MpdOutput> toMpdOutputList() {
    return toMpdDynamicList({
      "outputid": (data) {
        return _toMpdOutputFromMap(data);
      },
    }).whereType<MpdOutput>().toList();
  }

  List<MpdTagGroup> toMpdTagGroupList({required List<String> groups}) {
    // List<String> groupTag = List.from(groups);
    List<MpdTagGroup> result = [];
    // var lv = 0;
    var lastData = last;
    if (lastData is Uint8List && lastData.startsWithString("ACK")) {
      throw Exception(String.fromCharCodes(lastData));
    }

    for (var i = 0; i < length; i++) {
      var spl = utf8.decode(this[i] as Uint8List).split(": ");
      if (spl.length >= 2) {
        var type = spl.removeAt(0);
        var value = spl.join(": ");
        var lv = groups.indexOf(type);

        if (lv == 0) {
          result.add(MpdTagGroup(type: type, value: value, children: []));
        } else {
          var head = result.last;
          var j = 1;
          while (j < lv) {
            head = head.children.last;
            j++;
          }
          head.children.add(
            MpdTagGroup(type: type, value: value, children: []),
          );
        }
      }
    }

    return result;
  }

  static MpdDirectory? _toMpdDirectoryFromMap(Map<String, List<dynamic>> data) {
    if (data.isEmpty) {
      return null;
    }

    return MpdDirectory(
      directory: data["directory"]?.first,
      lastModified: DateTime.tryParse(
        data["lastModified"]?.first.toString() ?? "",
      ),
    );
  }

  static MpdPlaylist? _toMpdPlaylistFromMap(Map<String, List<dynamic>> data) {
    if (data.isEmpty) {
      return null;
    }

    return MpdPlaylist(
      playlist: data["playlist"]?.first,
      lastModified: DateTime.tryParse(
        data["lastModified"]?.first.toString() ?? "",
      ),
    );
  }

  static MpdOutput? _toMpdOutputFromMap(Map<String, List<dynamic>> data) {
    if (data.isEmpty) {
      return null;
    }

    return MpdOutput(
      enabled: data["outputenabled"]?.first.toString() == "1",
      id: data["outputid"]?.first.toString() ?? "",
      name: data["outputname"]?.first.toString() ?? "",
      plugin: data["plugin"]?.first.toString(),
      attribute: data["attribute"]?.first.toString(),
    );
  }

  static MpdSong? _toMpdSongFromMap(Map<String, List<dynamic>> data) {
    if (data.isEmpty) {
      return null;
    }

    // var tagData = Map<String, List<dynamic>>.from(data);
    Map<String, List<String>> tags = Map<String, List<dynamic>>.from(data).map(
      (key, value) =>
          MapEntry(key.toLowerCase(), value.map((e) => e.toString()).toList()),
    );

    return MpdSong(
      id: data["Id"] != null ? int.parse(data["Id"]?.first) : null,
      file: data["file"]?.first,
      duration: data["duration"] != null
          ? double.tryParse(data["duration"]?.first)
          : null,
      format: data["Format"]?.first,
      lastModified: DateTime.tryParse(
        data["Last-Modified"]?.first.toString() ?? "",
      ),
      added: DateTime.tryParse(data["added"]?.first.toString() ?? ""),
      range: data["Range"]?.first,
      time: data["Time"] != null ? int.tryParse(data["Time"]?.first) : null,
      tags: tags,
      pos: data["Pos"] == null ? null : int.parse(data["Pos"]?.first),
    );
  }

  MpdSong? toMpdSong() {
    return _toMpdSongFromMap(toMpdMap());
  }

  List<MpdCount> toMpdCountList({String? group}) {
    if (group == null) {
      var data = toMpdMap();
      return [
        MpdCount(
          songs: data["songs"]?.firstOrNull == null
              ? 0
              : int.parse(data["songs"]?.firstOrNull),
          duration: data["playtime"]?.firstOrNull == null
              ? Duration.zero
              : Duration(seconds: int.parse(data["playtime"]?.firstOrNull)),
        ),
      ];
    } else {
      return toMpdDynamicList({
        group: (data) => MpdCount(
          songs: data["songs"]?.firstOrNull == null
              ? 0
              : int.parse(data["songs"]?.firstOrNull),
          duration: data["playtime"]?.firstOrNull == null
              ? Duration.zero
              : Duration(seconds: int.parse(data["playtime"]?.firstOrNull)),
          group: data["group"]?.firstOrNull,
        ),
      }).whereType<MpdCount>().toList();
    }
  }

  List<dynamic> toMpdDynamicList(
    Map<String, dynamic Function(Map<String, List<dynamic>>)> segmentParser,
  ) {
    if (isEmpty) throw Exception("Not an Uint8List list");
    var lastData = last;
    if (lastData is Uint8List && lastData.startsWithString("ACK")) {
      throw Exception(String.fromCharCodes(lastData));
    }

    List<dynamic> result = [];
    List<Uint8List> bucket = [];
    for (var i = 0; i < length; i++) {
      var bit = this[i] as Uint8List;
      if (segmentParser.keys
              .where((element) => bit.startsWithString("$element:"))
              .firstOrNull !=
          null) {
        if (bucket.isNotEmpty) {
          var res = bucket.toMpdMap();
          var key = segmentParser.keys
              .where((element) => bucket.first.startsWithString("$element:"))
              .first;
          result.add(segmentParser[key]!(res));
          bucket.clear();
        }
      }

      if (!bit.startsWithString("OK")) {
        bucket.add(bit);
      }
    }
    if (bucket.isNotEmpty) {
      var res = bucket.toMpdMap();
      var key = segmentParser.keys
          .where((element) => bucket.first.startsWithString(element))
          .first;
      result.add(segmentParser[key]!(res));
      bucket.clear();
    }

    return result;
  }

  bool toOK() {
    if (isNotEmpty) {
      var lastData = last;
      if (lastData is Uint8List && lastData.startsWithString("ACK")) {
        throw Exception(String.fromCharCodes(lastData));
      }
    }
    return true;
  }

  List<String> toStickerFavorite() {
    return toMpdDynamicList({
      "file": (data) => data["file"]?.firstOrNull as String?,
    }).whereType<String>().toList();
  }

  Map<String, List<dynamic>> toMpdMap() {
    if (isEmpty) throw Exception("Not an Uint8List list");
    var lastData = last;
    if (lastData is Uint8List && lastData.startsWithString("ACK")) {
      throw Exception(String.fromCharCodes(lastData));
    }
    var pasedData = map((e) {
      var split = utf8
          .decode(e as Uint8List)
          .split(": "); //String.fromCharCodes(e as Uint8List).split(": ");
      if (split.length <= 2) {
        return split;
      } else {
        return [split[0], split.sublist(1).join(": ")];
      }
    }).where((e) => e.length == 2).toList();

    Map<String, List<dynamic>> result = {};

    for (var data in pasedData) {
      if (result.containsKey(data[0])) {
        result[data[0]]!.add(data[1]);
      } else {
        result[data[0]] = [data[1]];
      }
    }

    return result;
  }
}
