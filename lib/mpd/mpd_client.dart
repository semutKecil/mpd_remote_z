import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:mpd_remote_z/mpd/list_ext.dart';
import 'package:mpd_remote_z/mpd/model/mpd_binary.dart';
import 'package:mpd_remote_z/mpd/model/mpd_consume_mode.dart';
import 'package:mpd_remote_z/mpd/model/mpd_count.dart';
import 'package:mpd_remote_z/mpd/model/mpd_output.dart';
import 'package:mpd_remote_z/mpd/model/mpd_random_mode.dart';
import 'package:mpd_remote_z/mpd/model/mpd_repeat_mode.dart';
import 'package:mpd_remote_z/mpd/model/mpd_single_mode.dart';
import 'package:mpd_remote_z/mpd/model/mpd_stats.dart';
import 'package:mpd_remote_z/mpd/model/mpd_status.dart';
import 'package:mpd_remote_z/mpd/model/mpd_connection_setting.dart';
import 'package:mpd_remote_z/mpd/model/mpd_tag_group.dart';
import 'package:mpd_remote_z/mpd/mpd_message.dart';
import 'package:mpd_remote_z/mpd/model/mpd_response.dart';
import 'package:mpd_remote_z/mpd/model/mpd_song.dart';
import 'package:mpd_remote_z/mpd/string_ext.dart';
import 'package:mpd_remote_z/mpd/uint8_list_ext.dart';

part 'mpd_auto_idle.dart';

class MpdClient {
  MpdClient._({required this.connectionSetting});
  MpdConnectionSetting connectionSetting;
  final lock = AsyncLock();

  Socket? _socket;
  // bool _connected = false;
  Uint8List _mpdResponseBucket = Uint8List(0);
  final List<Uint8List> _unfinishedResponse = [];
  final Queue<MpdMessage> _commandQueue = Queue<MpdMessage>();
  StreamSubscription<Uint8List>? _subs;
  int _binaryLength = -1;
  Uint8List _unfinishedBinnary = Uint8List(0);
  // Completer<bool> isInitializedCompleter = Completer<bool>();
  final List<MpdAutoIdle> _autoIldeList = [];
  bool? _done;
  String? version;
  // String? currentPartition;

  void _cleanUp() {
    _binaryLength = -1;
    _unfinishedResponse.clear();
    _commandQueue.clear();
    // _connected = false;
    _unfinishedBinnary = Uint8List(0);
    _mpdResponseBucket = Uint8List(0);
  }

  void _messageProcessor(List<Uint8List> splitData) {
    var pos = 0;
    for (var i = 0; i < splitData.length; i++) {
      pos = i;
      if (splitData[i].startsWithString("OK") && splitData[i].length == 2) {
        _commandQueue.removeFirst().response.complete(
          List.from(_unfinishedResponse..add(splitData[i])),
        );
        _binaryLength = -1;
        _unfinishedResponse.clear();
      } else if (splitData[i].startsWithString("ACK")) {
        _commandQueue.removeFirst().response.complete(
          List.from(_unfinishedResponse..add(splitData[i])),
        );
        _binaryLength = -1;
        _unfinishedResponse.clear();
      } else if (splitData[i].startsWithString("binary:")) {
        var binLength = int.tryParse(
          String.fromCharCodes(splitData[i].sublist(8)),
        );

        _unfinishedResponse.add(splitData[i]);

        if (binLength != null) {
          _binaryLength = binLength;
          break;
        }
      } else {
        _unfinishedResponse.add(splitData[i]);
      }
    }

    if (_binaryLength > -1 && pos < splitData.length - 1) {
      var newBin = splitData.sublist(pos + 1);
      BytesBuilder builder = BytesBuilder();
      List<Uint8List> resData = [];
      for (var element in newBin) {
        if (builder.length >= _binaryLength) {
          resData.add(element);
        } else {
          builder.add(element);
        }
        if (builder.length < _binaryLength) {
          builder.add([0x0A]);
        }
      }

      if (builder.length < _binaryLength) {
        _unfinishedBinnary = builder.toBytes();
      } else {
        _unfinishedResponse.add(builder.toBytes());
        _messageProcessor(resData);
      }
    }
  }

  Future<String?> _connect() async {
    _done = null;
    var connectedCompleter = Completer<String?>();
    try {
      _cleanUp();
      await _subs?.cancel();

      _socket = await Socket.connect(
        connectionSetting.host,
        connectionSetting.port,
        timeout: const Duration(seconds: 5),
      );

      _subs = _socket!.listen(
        (event) {
          var fullResponse = event;
          if (_binaryLength > 0) {
            var diff = _binaryLength - _unfinishedBinnary.length;
            BytesBuilder builder = BytesBuilder();
            builder.add(_unfinishedBinnary);
            if (fullResponse.length <= diff) {
              builder.add(fullResponse);
            } else {
              builder.add(fullResponse.take(diff).toList());
              fullResponse = fullResponse.sublist(diff);
            }

            _unfinishedBinnary = builder.toBytes();
            if (_unfinishedBinnary.length == _binaryLength) {
              _unfinishedResponse.add(_unfinishedBinnary);
              _unfinishedBinnary = Uint8List(0);
              _binaryLength = -1;
            }
          }

          if (_mpdResponseBucket.isNotEmpty) {
            BytesBuilder builder = BytesBuilder();
            builder.add(_mpdResponseBucket);
            builder.add(fullResponse);
            fullResponse = builder.toBytes();
          }

          if (fullResponse.last == 0x0A) {
            var splitRes = fullResponse.splitUint8List(0x0A);

            if (splitRes[0].startsWithString("OK MPD")) {
              var connectMessage = String.fromCharCodes(splitRes.removeAt(0));
              debugPrint("connect = $connectMessage");
              version = connectMessage.substring(7);
              if (connectionSetting.password != null) {
                MpdResponse.fromFunction(
                  () async => (await _unSaveSend(
                    "password",
                    args: [connectionSetting.password!],
                  )).toMpdMap(),
                ).then((value) async {
                  if (value.isValid) {
                    connectedCompleter.complete(version);
                    _done = false;
                  } else {
                    debugPrint("invalid password");
                    connectedCompleter.completeError(
                      Exception("invalid password"),
                    );
                  }
                });
              } else {
                connectedCompleter.complete(version);
                _done = false;
              }
            }

            _messageProcessor(splitRes);
            _mpdResponseBucket = Uint8List(0);
          } else {
            _mpdResponseBucket = fullResponse;
          }
        },
        onDone: () {
          debugPrint("done");
          for (var element in _commandQueue) {
            element.response.completeError(
              Exception(
                "${element.command}: error unfinished. connection closed",
              ),
            );
          }
          if (!connectedCompleter.isCompleted) {
            connectedCompleter.complete(null);
          }
          _done = true;
        },
        onError: (e) {
          if (!connectedCompleter.isCompleted) {
            connectedCompleter.completeError(Exception("connection error"));
          }
        },
      );

      var res = await connectedCompleter.future;
      debugPrint("check partition");
      if (res != null && connectionSetting.partition != null) {
        debugPrint("set status");
        await _unSaveSend("partition", args: [connectionSetting.partition!]);
        debugPrint("set partition ok");
      }
      debugPrint("check partition end");
      return res;
    } catch (e, s) {
      if (!connectedCompleter.isCompleted) {
        connectedCompleter.complete(null);
      }
      debugPrintStack(stackTrace: s, label: e.toString());
      rethrow;
    }
  }

  Future<List<Uint8List>> _unSaveSend(
    String command, {
    List<String> args = const [],
  }) async {
    try {
      if (_done == true) {
        await _socket?.close();
        _socket?.destroy();
        _socket = null;
        await _connect();
      }

      var sendMsg = MpdMessage(command: command, args: args);
      _commandQueue.add(sendMsg);
      var strCommand = sendMsg.toCmdString();
      debugPrint("comand: $strCommand");
      _socket?.write(strCommand);
      await _socket?.flush();
      return await sendMsg.response.future;
    } on SocketException catch (e) {
      if (e.osError?.errorCode == 32 || e.message.contains("Broken pipe")) {
        await _socket?.close();
        _socket?.destroy();
        _socket = null;
        await _connect();

        return _unSaveSend(command);
      } else {
        // Handle other socket exceptions
        rethrow;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Uint8List>> send(
    String command, {
    List<String> args = const [],
  }) async {
    return await lock.synchronized(() async {
      return await _unSaveSend(command, args: args);
    });
  }

  Future<MpdResponse<bool>> pause(int state) {
    assert(state == 0 || state == 1, "sstate must be 0 or 1");
    return MpdResponse.fromFunction(
      () async => (await send("pause", args: [state.toString()])).toOK(),
    );
  }

  Future<MpdResponse<bool>> playId(int songId) {
    return MpdResponse.fromFunction(
      () async => (await send("playid", args: [songId.toString()])).toOK(),
    );
  }

  Future<MpdResponse<bool>> setVol(int volume) {
    return MpdResponse.fromFunction(
      () async => (await send("setvol", args: [volume.toString()])).toOK(),
    );
  }

  Future<MpdResponse<bool>> play(int songPos) {
    return MpdResponse.fromFunction(
      () async => (await send("play", args: [songPos.toString()])).toOK(),
    );
  }

  Future<MpdResponse<bool>> next() {
    return MpdResponse.fromFunction(() async => (await send("next")).toOK());
  }

  Future<MpdResponse<bool>> previous() {
    return MpdResponse.fromFunction(
      () async => (await send("previous")).toOK(),
    );
  }

  Future<MpdResponse<bool>> crossFade(int seconds) {
    return MpdResponse.fromFunction(
      () async => (await send("crossfade", args: [seconds.toString()])).toOK(),
    );
  }

  Future<MpdResponse<bool>> mixRampDb(int db) {
    return MpdResponse.fromFunction(
      () async => (await send("mixrampdb", args: [db.toString()])).toOK(),
    );
  }

  Future<MpdResponse<bool>> mixRampDelay(String seconds) {
    return MpdResponse.fromFunction(
      () async => (await send("mixrampdelay", args: [seconds])).toOK(),
    );
  }

  Future<MpdResponse<bool>> seek(int songPos, double time) {
    return MpdResponse.fromFunction(
      () async => (await send(
        "seek",
        args: [songPos.toString(), time.toString()],
      )).toOK(),
    );
  }

  Future<MpdResponse<bool>> seekId(int songId, double time) {
    return MpdResponse.fromFunction(
      () async => (await send(
        "seekid",
        args: [songId.toString(), time.toString()],
      )).toOK(),
    );
  }

  Future<MpdResponse<bool>> setFavorite(String uri) {
    //sticker set song "path/to/song_1.mp3" "name_1" "value_1"
    return MpdResponse.fromFunction(
      () async => (await send(
        "sticker",
        args: ["set", "song", uri, "favorite", "1"],
      )).toOK(),
    );
  }

  Future<MpdResponse<bool>> deleteFavorite(String uri) {
    //sticker set song "path/to/song_1.mp3" "name_1" "value_1"
    return MpdResponse.fromFunction(
      () async => (await send(
        "sticker",
        args: ["delete", "song", uri, "favorite"],
      )).toOK(),
    );
  }

  Future<MpdResponse<List<String>>> findFavoriteUri() async {
    //sticker set song "path/to/song_1.mp3" "name_1" "value_1"
    return MpdResponse.fromFunction(() async {
      return (await send(
        "sticker",
        args: ["find", "song", "", "favorite"],
      )).toStickerFavorite()..sort((a, b) => a.compareTo(b));
    });
  }

  Future<MpdResponse<List<MpdSong>>> findFavorite() async {
    return MpdResponse.fromFunction(() async {
      return Future.wait(
        (await findFavoriteUri()).data.map((e) async {
          var path = (e.split("/")..removeLast()).join("/");
          return (await lsInfo(path)).data
              .whereType<MpdSong>()
              .where((element) => element.file == e)
              .first;
        }),
      );
    });
  }

  Future<MpdResponse<bool>> seekCur(double time) {
    return MpdResponse.fromFunction(
      () async => (await send("seekcur", args: [time.toString()])).toOK(),
    );
  }

  Future<MpdResponse<bool>> stop() {
    return MpdResponse.fromFunction(() async => (await send("stop")).toOK());
  }

  Future<MpdResponse<bool>> random(MpdRandomMode mode) {
    return MpdResponse.fromFunction(
      () async => (await send("random", args: [mode.value])).toOK(),
    );
  }

  Future<MpdResponse<bool>> repeat(MpdRepeatMode mode) {
    return MpdResponse.fromFunction(
      () async => (await send("repeat", args: [mode.value])).toOK(),
    );
  }

  Future<MpdResponse<bool>> single(MpdSingleMode mode) {
    return MpdResponse.fromFunction(
      () async => (await send("single", args: [mode.value])).toOK(),
    );
  }

  Future<MpdResponse<bool>> consume(MpdConsumeMode mode) {
    return MpdResponse.fromFunction(
      () async => (await send("consume", args: [mode.value])).toOK(),
    );
  }

  Future<MpdResponse<bool>> moveId(int from, int to) {
    return MpdResponse.fromFunction(
      () async =>
          (await send("moveid", args: [from.toString(), to.toString()])).toOK(),
    );
  }

  // playlistmove {NAME} [{FROM} | {START:END}] {TO}
  Future<MpdResponse<bool>> playlistMove(
    String name, {
    int? from,
    int? start,
    int? end,
    required int to,
  }) {
    assert(
      !(from != null && !(start == null && end == null)),
      "cant use range and from parameter at the same time",
    );

    var args = [name];

    if (from != null) {
      args.add("$from");
    } else if (start != null) {
      args.add("$start:${end ?? ""}");
    }

    args.add("$to");

    return MpdResponse.fromFunction(
      () async => (await send("playlistmove", args: args)).toOK(),
    );
  }

  Future<MpdResponse<bool>> deleteId(int id) {
    return MpdResponse.fromFunction(
      () async => (await send("deleteid", args: [id.toString()])).toOK(),
    );
  }

  Future<MpdResponse<bool>> playlistDelete(
    String name, {
    int? songPos,
    int? start,
    int? end,
  }) {
    assert(
      !(songPos != null && !(start == null)),
      "cant use range and songpos parameter at the same time",
    );

    assert(
      !(start != null && end != null && start > end),
      "invalid range parameter. end>start",
    );

    var args = [name];
    if (songPos != null) {
      args.add("$songPos");
    }

    if (start != null) {
      args.add("$start:${end ?? ""}");
    }

    return MpdResponse.fromFunction(
      () async => (await send("playlistdelete", args: args)).toOK(),
    );
  }

  Future<void> noIdle() async {
    _socket?.write("noidle\n");
    await _socket?.flush();
  }

  Future<MpdResponse<MpdSong?>> currentSong() async {
    return MpdResponse.fromFunction(
      () async => (await send("currentsong")).toMpdSong(),
    );
  }

  Future<MpdResponse<Map<String, List<dynamic>>>> password(
    String password,
  ) async {
    return MpdResponse.fromFunction(
      () async => (await send("password", args: [password])).toMpdMap(),
    );
  }

  Future<MpdResponse<MpdStats>> stats() async {
    return MpdResponse.fromFunction(
      () async => (await send("stats")).toMpdStats(),
    );
  }

  Future<MpdResponse<Map<String, List<dynamic>>>> clearError() async {
    return MpdResponse.fromFunction(
      () async => (await send("clearerror")).toMpdMap(),
    );
  }

  Future<MpdResponse<MpdStatus>> status() async {
    return MpdResponse.fromFunction(
      () async => (await send("status")).toMpdStatus(),
    );
  }

  Future<MpdResponse<List<MpdSong>>> playlistInfo({
    int? songPos,
    int? start,
    int? end,
  }) async {
    assert(
      !(songPos != null && !(start == null && end == null)),
      "cant use range and songpos parameter at the same time",
    );

    assert(
      !(start != null && end != null && start > end),
      "invalid range parameter. end>start",
    );

    List<String> args = [];

    if (songPos != null) {
      args.add("$songPos");
    }

    if (start != null) {
      args.add("$start:${end ?? ""}");
    }

    return MpdResponse.fromFunction(
      () async => (await send("playlistinfo", args: args)).toMpdSongList(),
    );
  }

  Future<MpdResponse<List<MpdSong>>> listPlaylistInfo(
    String name, {
    int? start,
    int? end,
  }) async {
    List<String> args = [name];

    if (start != null) {
      args.add("$start:${end ?? ""}");
    }

    return MpdResponse.fromFunction(
      () async => (await send("listplaylistinfo", args: args)).toMpdSongList(),
    );
  }

  Future<MpdResponse<bool>> load(
    String name, {
    int? start,
    int? end,
    String? position,
  }) async {
    List<String> args = [name];
    if (start != null) {
      args.add("$start:${end ?? ""}");
    }

    if (position != null) {
      if (start == null) {
        args.add("0:");
      }
      args.add(position);
    }

    return MpdResponse.fromFunction(
      () async => (await send("load", args: args)).toOK(),
    );
  }

  Future<MpdResponse<List<dynamic>>> lsInfo(String? uri) async {
    return MpdResponse.fromFunction(() async {
      return uri == null
          ? (await send("lsinfo")).toMpdFilesList()
          : (await send("lsinfo", args: [uri])).toMpdFilesList();
    });
  }

  Future<MpdResponse<List<MpdPlaylist>>> listPlaylists() async {
    return MpdResponse.fromFunction(() async {
      return (await send(
        "listplaylists",
      )).toMpdFilesList().whereType<MpdPlaylist>().toList();
    });
  }

  Future<MpdResponse<bool>> add(String uri, {String? position}) async {
    return MpdResponse.fromFunction(() async {
      if (position != null) {
        return (await send("add", args: [uri, position.toString()])).toOK();
      }
      return (await send("add", args: [uri])).toOK();
    });
  }

  Future<MpdResponse<int>> addId(String uri, {String? position}) async {
    // _Exception (Exception: ACK [2@0] {addid} Integer expected: null)
    return MpdResponse.fromFunction(() async {
      var map = position != null
          ? (await send("addid", args: [uri, position.toString()])).toMpdMap()
          : (await send("addid", args: [uri])).toMpdMap();
      return int.parse(map["Id"]?.first);
    });
  }

  //playlistadd {NAME} {URI} [POSITION]
  Future<MpdResponse<bool>> playlistAdd(
    String name,
    String uri, {
    int? position,
  }) async {
    return MpdResponse.fromFunction(() async {
      if (position != null) {
        return (await send(
          "playlistadd",
          args: [name, uri, position.toString()],
        )).toOK();
      }
      return (await send("playlistadd", args: [name, uri])).toOK();
    });
  }

  Future<MpdResponse<bool>> rm(String name) async {
    return MpdResponse.fromFunction(() async {
      return (await send("rm", args: [name])).toOK();
    });
  }

  Future<MpdResponse<bool>> rename(String name, String newName) async {
    return MpdResponse.fromFunction(() async {
      return (await send("rename", args: [name, newName])).toOK();
    });
  }

  Future<MpdResponse<bool>> clear() async {
    return MpdResponse.fromFunction(() async {
      return (await send("clear")).toOK();
    });
  }

  Future<MpdResponse<List<MpdCount>>> count(
    String filter, {
    String? group,
  }) async {
    var args = [filter];

    if (group != null) {
      args.add("group");
      args.add(group);
    }

    return MpdResponse.fromFunction(() async {
      return (await send("count", args: args)).toMpdCountList(group: group);
    });
  }

  Future<MpdResponse<bool>> searchAdd(
    String filter, {
    String? sort,
    int? start,
    int? end,
    int? position,
  }) async {
    var args = [filter];

    if (sort != null) {
      args.add("sort");
      args.add(sort);
    }

    if (start != null) {
      args.add("window");
      args.add("$start:${end ?? ""}");
    }

    if (position != null) {
      args.add("position");
      args.add(position.toString());
    }

    return MpdResponse.fromFunction(() async {
      return (await send("searchadd", args: args)).toOK();
    });
  }

  Future<MpdResponse<bool>> searchAddPl(
    String name,
    String filter, {
    String? sort,
    int? start,
    int? end,
    int? position,
  }) async {
    var args = [name, filter];

    if (sort != null) {
      args.add("sort");
      args.add(sort);
    }

    if (start != null) {
      args.add("window");
      args.add("$start:${end ?? ""}");
    }

    if (position != null) {
      args.add("position");
      args.add(position.toString());
    }

    return MpdResponse.fromFunction(() async {
      return (await send("searchaddpl", args: args)).toOK();
    });
  }

  Future<MpdResponse<List<MpdSong>>> search(
    String filter, {
    String? sort,
    int? start,
    int? end,
  }) async {
    var args = [filter];

    if (sort != null) {
      args.add("sort");
      args.add(sort);
    }

    if (start != null) {
      args.add("window");
      args.add("$start:${end ?? ""}");
    }

    return MpdResponse.fromFunction(() async {
      return (await send("search", args: args)).toMpdSongList();
    });
  }

  Future<MpdResponse<bool>> findAdd(
    String filter, {
    String? sort,
    int? start,
    int? end,
    int? position,
  }) async {
    var args = [filter];

    if (sort != null) {
      args.add("sort");
      args.add(sort);
    }

    if (start != null) {
      args.add("window");
      args.add("$start:${end ?? ""}");
    }

    if (position != null) {
      args.add("position");
      args.add(position.toString());
    }

    return MpdResponse.fromFunction(() async {
      return (await send("findadd", args: args)).toOK();
    });
  }

  Future<MpdResponse<List<MpdSong>>> find(
    String filter, {
    String? sort,
    int? start,
    int? end,
  }) async {
    var args = [filter];

    if (sort != null) {
      args.add("sort");
      args.add(sort);
    }

    if (start != null) {
      args.add("window");
      args.add("$start:${end ?? ""}");
    }

    return MpdResponse.fromFunction(() async {
      return (await send("find", args: args)).toMpdSongList();
    });
  }

  Future<MpdResponse<MpdReplayGainMode>> replayGainStatus() async {
    return MpdResponse.fromFunction(() async {
      final mode = (await send(
        "replay_gain_status",
      )).toMpdMap()["replay_gain_mode"]!.first;
      return MpdReplayGainMode.values.firstWhere((e) => e.name == mode);
    });
  }

  Future<MpdResponse<bool>> replayGainMode(MpdReplayGainMode mode) async {
    return MpdResponse.fromFunction(() async {
      return (await send("replay_gain_mode", args: [mode.name])).toOK();
    });
  }

  Future<MpdResponse<bool>> update({String? uri}) async {
    return MpdResponse.fromFunction(() async {
      return (await send("update", args: uri == null ? [] : [uri])).toOK();
    });
  }

  Future<MpdResponse<bool>> rescan({String? uri}) async {
    return MpdResponse.fromFunction(() async {
      return (await send("rescan", args: uri == null ? [] : [uri])).toOK();
    });
  }

  Future<MpdResponse<bool>> toggleOutput(String id) async {
    return MpdResponse.fromFunction(() async {
      return (await send("toggleoutput", args: [id])).toOK();
    });
  }

  Future<MpdResponse<bool>> moveOutput(String name) async {
    return MpdResponse.fromFunction(() async {
      return (await send("moveoutput", args: [name])).toOK();
    });
  }

  Future<MpdResponse<List<String>>> listPartitions() async {
    return MpdResponse.fromFunction(() async {
      return (await send(
            "listpartitions",
          )).toMpdMap()["partition"]?.map((e) => e.toString()).toList() ??
          [];
    });
  }

  Future<MpdResponse<bool>> partition(String partition) async {
    var data = await MpdResponse.fromFunction(() async {
      return (await send("partition", args: [partition])).toOK();
    });

    if (data.isValid) {
      connectionSetting = connectionSetting.copyWith(partition: partition);
    }

    return data;
  }

  Future<MpdResponse<bool>> newPartition(String name) async {
    return MpdResponse.fromFunction(() async {
      return (await send("newpartition", args: [name])).toOK();
    });
  }

  Future<MpdResponse<bool>> delPartition(String name) async {
    return MpdResponse.fromFunction(() async {
      return (await send("delpartition", args: [name])).toOK();
    });
  }

  Future<MpdResponse<List<MpdOutput>>> outputs() async {
    return MpdResponse.fromFunction(() async {
      return ((await send("outputs")).toMpdOutputList());
    });
  }

  //replay_gain_mode

  Future<MpdResponse<List<MpdTagGroup>>> list(
    String type, {
    String? filter,
    List<String> groups = const [],
    int? start,
    int? end,
  }) async {
    return MpdResponse.fromFunction(() async {
      var args = [type];

      if (filter != null) {
        args.add(filter);
      }

      if (groups.isNotEmpty) {
        for (var e in groups) {
          args.add("group");
          args.add(e.mpdEscape());
        }
      }

      if (start != null) {
        args.add("$start:${end ?? ""}");
      }

      return (await send(
        "list",
        args: args,
      )).toMpdTagGroupList(groups: groups.reversed.toList()..add(type));
    });
  }

  Future<MpdAutoIdle> autoIdle({
    VoidCallback? onDatabase,
    VoidCallback? onUpdate,
    VoidCallback? onStoredPlaylist,
    VoidCallback? onPlaylist,
    VoidCallback? onPlayer,
    VoidCallback? onMixer,
    VoidCallback? onOutput,
    VoidCallback? onOptions,
    VoidCallback? onPartition,
    VoidCallback? onSticker,
    VoidCallback? onSubscription,
    VoidCallback? onMessage,
    VoidCallback? onNeighbor,
    VoidCallback? onMount,
    VoidCallback? onConnectionError,
  }) async {
    MpdAutoIdle autoIdle = MpdAutoIdle._(
      connectionSetting: connectionSetting,
      onDatabase: onDatabase,
      onUpdate: onUpdate,
      onStoredPlaylist: onStoredPlaylist,
      onPlaylist: onPlaylist,
      onPlayer: onPlayer,
      onMixer: onMixer,
      onOutput: onOutput,
      onOptions: onOptions,
      onPartition: onPartition,
      onSticker: onSticker,
      onSubscription: onSubscription,
      onMessage: onMessage,
      onNeighbor: onNeighbor,
      onMount: onMount,
      onConnectionError: onConnectionError,
    );

    await autoIdle.initialize();
    _autoIldeList.add(autoIdle);
    return autoIdle;
  }

  Future<void> disconnect() async {
    _socket?.destroy();
    _socket = null;
    _cleanUp();
  }

  Future<MpdResponse<MpdBinary>> readPicture(String file) async {
    var client = await MpdClient.connect(
      host: connectionSetting.host,
      port: connectionSetting.port,
      password: connectionSetting.password,
      partition: connectionSetting.partition,
    );

    debugPrint("act read picture");

    var res = MpdResponse.fromFunction(() async {
      await client.send("binarylimit", args: ["8192"]);
      BytesBuilder builder = BytesBuilder();
      var initialBin = (await client.send(
        "readpicture",
        args: [file, "0"],
      )).toMpdBinary();

      builder.add(initialBin.data);
      if (initialBin.size == null) throw Exception("size is null");
      while (builder.length < initialBin.size!) {
        builder.add(
          (await client.send(
            "readpicture",
            args: [file, builder.length.toString()],
          )).toMpdBinary().data,
        );
      }

      return MpdBinary(
        binary: builder.length,
        size: builder.length,
        type: initialBin.type,
        data: builder.takeBytes(),
      );
    });

    client.disconnect();
    return res;
  }

  static Future<MpdClient> connect({
    required String host,
    required int port,
    String? password,
    String? partition,
  }) async {
    var mpd = MpdClient._(
      connectionSetting: MpdConnectionSetting(
        host: host,
        port: port,
        password: password,
        partition: partition,
      ),
    );
    try {
      var version = await mpd._connect();
      if (version == null) {
        mpd.disconnect();
        throw Exception("invalid connection settings");
      }
      return mpd;
    } catch (_) {
      rethrow;
    }
  }
}

class AsyncLock {
  Future<void> _last = Future.value();

  Future<T> synchronized<T>(Future<T> Function() action) {
    final completer = Completer<T>();
    _last = _last
        .then((_) => action())
        .then(completer.complete)
        .onError(completer.completeError);
    return completer.future;
  }
}
