import 'dart:convert';

import 'package:mpd_remote_z/model/server_info.dart';
import 'package:mpd_remote_z/mpd/model/mpd_consume_mode.dart';
import 'package:mpd_remote_z/mpd/model/mpd_count.dart';
import 'package:mpd_remote_z/mpd/model/mpd_single_mode.dart';
import 'package:mpd_remote_z/mpd/model/mpd_song.dart';
import 'package:mpd_remote_z/mpd/model/mpd_stats.dart';
import 'package:mpd_remote_z/mpd/model/mpd_status.dart';
import 'package:mpd_remote_z/mpd/model/mpd_tag_group.dart';
import 'package:mpd_remote_z/service/general_audio_handler.dart';

class AudioHandlerCustom {
  final GeneralAudioHandler handler;
  const AudioHandlerCustom(this.handler);

  Future<void> connect(ServerInfo serverInfo) async {
    await CustomAction.connect.call(handler, serverInfo.toJson());
  }

  Future<void> disconnect({bool consent = true}) async {
    await CustomAction.disconnect.call(handler, {'consent': consent});
  }

  Future<MpdStatus?> mpdStatus() async {
    return await CustomAction.mpdStatus.call(handler);
  }

  Future<MpdStats?> mpdStats() async {
    return await CustomAction.mpdStats.call(handler);
  }

  Future<bool> isConnect() async {
    return await CustomAction.isConnect.call(handler);
  }

  Future<void> toggleRepeat() async {
    await CustomAction.toggleRepeat.call(handler);
  }

  Future<void> clearCache() async {
    await CustomAction.clearCache.call(handler);
  }

  Future<void> toggleRandom() async {
    await CustomAction.toggleRandom.call(handler);
  }

  Future<void> toggleSingle() async {
    await CustomAction.toggleSingle.call(handler);
  }

  Future<void> toggleConsume() async {
    await CustomAction.toggleConsume.call(handler);
  }

  Future<void> setSingle(MpdSingleMode single) async {
    await CustomAction.setSingle.call(handler, {'single': single});
  }

  Future<void> setConsume(MpdConsumeMode consume) async {
    await CustomAction.setConsume.call(handler, {'consume': consume});
  }

  Future<void> moveId(int from, int to) async {
    await CustomAction.moveId.call(handler, {'from': from, 'to': to});
  }

  Future<void> deleteId(int id) async {
    await CustomAction.deleteId.call(handler, {'id': id});
  }

  Future<void> playlistAdd(String name, String uri, {int? position}) async {
    await CustomAction.playlistAdd.call(handler, {
      "name": name,
      "uri": uri,
      "position": position,
    });
  }

  Future<List<dynamic>?> lsInfo({String? uri}) async {
    return await CustomAction.lsInfo.call(handler, {"uri": uri});
  }

  Future<List<MpdPlaylist>?> listPlaylists() async {
    return await CustomAction.listPlaylists.call(handler);
  }

  Future<bool> clear() async {
    return await CustomAction.clear.call(handler);
  }

  Future<bool> playId(int songId) async {
    return await CustomAction.playId.call(handler, {"songId": songId});
  }

  Future<int> addId(String uri, {String? position}) async {
    return await CustomAction.addId.call(handler, {
      "uri": uri,
      "position": position,
    });
  }

  Future<bool> add(String uri, {String? position}) async {
    return await CustomAction.add.call(handler, {
      "uri": uri,
      "position": position,
    });
  }

  Future<bool> load(
    String name, {
    int? start,
    int? end,
    String? position,
  }) async {
    return await CustomAction.load.call(handler, {
      "name": name,
      "start": start,
      "end": end,
      "position": position,
    });
  }

  Future<List<MpdSong>> listPlaylistInfo(
    String name, {
    int? start,
    int? end,
  }) async {
    return await CustomAction.listPlaylistInfo.call(handler, {
      "name": name,
      "start": start,
      "end": end,
    });
  }

  Future<bool> playlistDelete(
    String name, {
    int? songPos,
    int? start,
    int? end,
  }) async {
    return await CustomAction.playlistDelete.call(handler, {
      "name": name,
      "songPos": songPos,
      "start": start,
      "end": end,
    });
  }

  Future<bool> playlistMove(
    String name, {
    int? from,
    int? start,
    int? end,
    required int to,
  }) async {
    return await CustomAction.playlistMove.call(handler, {
      "name": name,
      "from": from,
      "start": start,
      "end": end,
      "to": to,
    });
  }

  Future<bool> rm(String name) async {
    return await CustomAction.rm.call(handler, {"name": name});
  }

  Future<bool> rename(String name, String newName) async {
    return await CustomAction.rename.call(handler, {
      "name": name,
      "newName": newName,
    });
  }

  Future<List<MpdTagGroup>> list(
    String type, {
    String? filter,
    List<String> groups = const [],
    int? start,
    int? end,
  }) async {
    return await CustomAction.list.call(handler, {
      "type": type,
      "filter": filter,
      "groups": jsonEncode(groups),
      "start": start,
      "end": end,
    });
  }

  Future<List<MpdCount>> count(String filter, {String? group}) async {
    return await CustomAction.count.call(handler, {
      "filter": filter,
      "group": group,
    });
  }

  Future<bool> findAdd(
    String filter, {
    String? sort,
    int? start,
    int? end,
    int? position,
  }) async {
    return await CustomAction.findAdd.call(handler, {
      "filter": filter,
      "sort": sort,
      "start": start,
      "end": end,
      "position": position,
    });
  }

  Future<List<MpdSong>> find(
    String filter, {
    String? sort,
    int? start,
    int? end,
  }) async {
    return await CustomAction.find.call(handler, {
      "filter": filter,
      "sort": sort,
      "start": start,
      "end": end,
    });
  }

  Future<bool> searchAdd(
    String filter, {
    String? sort,
    int? start,
    int? end,
    int? position,
  }) async {
    return await CustomAction.searchAdd.call(handler, {
      "filter": filter,
      "sort": sort,
      "start": start,
      "end": end,
      "position": position,
    });
  }

  Future<bool> searchAddPl(
    String name,
    String filter, {
    String? sort,
    int? start,
    int? end,
    int? position,
  }) async {
    return await CustomAction.searchAddPl.call(handler, {
      "name": name,
      "filter": filter,
      "sort": sort,
      "start": start,
      "end": end,
      "position": position,
    });
  }

  Future<List<MpdSong>> search(
    String filter, {
    String? sort,
    int? start,
    int? end,
  }) async {
    return await CustomAction.search.call(handler, {
      "filter": filter,
      "sort": sort,
      "start": start,
      "end": end,
    });
  }

  Future<void> crossFade(int seconds) async {
    await CustomAction.crossFade.call(handler, {"seconds": seconds});
  }

  Future<void> mixRampDb(int db) async {
    await CustomAction.mixRampDb.call(handler, {"db": db});
  }

  Future<void> mixRampDelay(String seconds) async {
    await CustomAction.mixRampDelay.call(handler, {"seconds": seconds});
  }

  Future<void> replayGainMode(MpdReplayGainMode mode) async {
    await CustomAction.replayGainMode.call(handler, {"mode": mode});
  }

  Future<MpdReplayGainMode> replayGainStatus() async {
    return await CustomAction.replayGainStatus.call(handler);
  }

  Future<void> update({String? uri}) async {
    await CustomAction.update.call(handler, {"uri": uri});
  }

  Future<void> rescan({String? uri}) async {
    await CustomAction.rescan.call(handler, {"uri": uri});
  }

  Future<void> toggleOutput(String id) async {
    await CustomAction.toggleOutput.call(handler, {"id": id});
  }

  Future<List<String>> listPartitions() async {
    return await CustomAction.listPartitions.call(handler);
  }

  Future<void> partition(String partition) async {
    await CustomAction.partition.call(handler, {"partition": partition});
  }

  Future<void> newPartition(String partition) async {
    await CustomAction.newPartition.call(handler, {"partition": partition});
  }

  Future<void> delPartition(String partition) async {
    await CustomAction.delPartition.call(handler, {"partition": partition});
  }

  Future<void> switchPartition(String partition) async {
    await CustomAction.switchPartition.call(handler, {"partition": partition});
  }

  Future<void> setFavorite(String uri) async {
    await CustomAction.setFavorite.call(handler, {"uri": uri});
  }

  Future<void> deleteFavorite(String uri) async {
    await CustomAction.deleteFavorite.call(handler, {"uri": uri});
  }
}
