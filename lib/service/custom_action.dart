part of 'general_audio_handler.dart';

enum CustomAction {
  connect._(_connect),
  disconnect._(_disconnect),
  isConnect._(_isConnect),
  mpdStatus._(_mpdStatus),
  mpdStats._(_mpdStats),
  toggleRandom._(_toggleRandom),
  toggleRepeat._(_toggleRepeat),
  toggleSingle._(_toggleSingle),
  toggleConsume._(_toggleConsume),
  moveId._(_moveId),
  deleteId._(_deleteId),
  lsInfo._(_lsInfo),
  clear._(_clear),
  listPlaylists._(_listPlaylists),
  playlistAdd._(_playlistAdd),
  addId._(_addId),
  add._(_add),
  playId._(_playId),
  load._(_load),
  listPlaylistInfo._(_listPlaylistInfo),
  playlistDelete._(_playlistDelete),
  playlistMove._(_playlistMove),
  rm._(_rm),
  rename._(_rename),
  list._(_list),
  find._(_find),
  search._(_search),
  count._(_count),
  findAdd._(_findAdd),
  searchAdd._(_searchAdd),
  searchAddPl._(_searchAddPl),
  clearCache._(_clearCache),
  setSingle._(_setSingle),
  setConsume._(_setConsume),
  crossFade._(_crossFade),
  mixRampDb._(_mixRampDb),
  mixRampDelay._(_mixRampDelay),
  replayGainMode._(_replayGainMode),
  replayGainStatus._(_replayGainStatus),
  update._(_update),
  rescan._(_rescan),
  listPartitions._(_listPartitions),
  toggleOutput._(_toggleOutput),
  partition._(_partition),
  newPartition._(_newPartition),
  delPartition._(_delPartition),
  switchPartition._(_switchPartition),
  setFavorite._(_setFavorite),
  deleteFavorite._(_deleteFavorite);

  const CustomAction._(this._action);

  final Future<dynamic> Function(
    GeneralAudioHandler handler, [
    Map<String, dynamic>? extras,
  ])
  _action;

  Future<dynamic> call(
    GeneralAudioHandler handler, [
    Map<String, dynamic>? extras,
  ]) async {
    return handler.customAction(name, extras);
  }

  static Future<dynamic> _connect(
    GeneralAudioHandler handler, [
    Map<String, dynamic>? extras,
  ]) async {
    try {
      debugPrint(extras.toString());
      if (handler._mpdClient != null) {
        try {
          await handler._mpdClient?.disconnect();
          handler._mpdClient = null;
        } catch (e, s) {
          debugPrintStack(stackTrace: s, label: e.toString());
        }
      }
      // if (_mpdClient == null) {
      handler._mpdClient = await MpdClient.connect(
        host: extras!['host'],
        port: extras['port'],
        password: extras['password'],
        partition: extras['partition'],
      );

      handler.serverId = extras['id'];
      ServerInfo.saveCurrentServer(
        ServerInfo(
          id: extras['id'],
          name: extras['name'],
          host: extras['host'],
          port: extras['port'],
          password: extras['password'],
          partition: extras['partition'],
          version: handler._mpdClient?.version,
        ),
      );
      // }

      await handler._mpdUpdateQueue();
      await handler._mpdUpdateCurrentSong();
      await handler._updateStats();
      if (handler.mpdStatus == null) {
        await handler._updateStatus();
      }

      await handler._initAutoIdle();
      handler.customEvent.add(AudioHandlerEvent.connect);
    } catch (_) {
      rethrow;
    }
  }

  static Future<dynamic> _isConnect(
    GeneralAudioHandler handler, [
    Map<String, dynamic>? extras,
  ]) async {
    return handler._mpdClient != null;
  }

  static Future<dynamic> _disconnect(
    GeneralAudioHandler handler, [
    Map<String, dynamic>? extras,
  ]) async {
    await handler._disconnect(consent: extras!["consent"]);
  }

  static Future<dynamic> _mpdStatus(
    GeneralAudioHandler handler, [
    Map<String, dynamic>? extras,
  ]) async {
    return handler.mpdStatus;
  }

  static Future<dynamic> _mpdStats(
    GeneralAudioHandler handler, [
    Map<String, dynamic>? extras,
  ]) async {
    return handler.mpdStats;
  }

  static Future<dynamic> _toggleRandom(
    GeneralAudioHandler handler, [
    Map<String, dynamic>? extras,
  ]) async {
    if (handler.mpdStatus?.random == MpdRandomMode.on) {
      await handler._mpdClient?.random(MpdRandomMode.off);
    } else {
      await handler._mpdClient?.random(MpdRandomMode.on);
    }
  }

  static Future<dynamic> _toggleRepeat(
    GeneralAudioHandler handler, [
    Map<String, dynamic>? extras,
  ]) async {
    if (handler.mpdStatus?.repeat == MpdRepeatMode.on) {
      await handler._mpdClient?.repeat(MpdRepeatMode.off);
    } else {
      await handler._mpdClient?.repeat(MpdRepeatMode.on);
    }
  }

  static Future<dynamic> _toggleSingle(
    GeneralAudioHandler handler, [
    Map<String, dynamic>? extras,
  ]) async {
    if (handler.mpdStatus?.single == MpdSingleMode.on) {
      await handler._mpdClient?.single(MpdSingleMode.oneshot);
    } else if (handler.mpdStatus?.single == MpdSingleMode.off) {
      await handler._mpdClient?.single(MpdSingleMode.on);
    } else {
      await handler._mpdClient?.single(MpdSingleMode.off);
    }
  }

  static Future<dynamic> _toggleConsume(
    GeneralAudioHandler handler, [
    Map<String, dynamic>? extras,
  ]) async {
    if (handler._mpdClient?.version?.isVersionSupported("0.24") == true) {
      if (handler.mpdStatus?.consume == MpdConsumeMode.on) {
        await handler._mpdClient?.consume(MpdConsumeMode.oneshot);
      } else if (handler.mpdStatus?.consume == MpdConsumeMode.off) {
        await handler._mpdClient?.consume(MpdConsumeMode.on);
      } else {
        await handler._mpdClient?.consume(MpdConsumeMode.off);
      }
    } else {
      if (handler.mpdStatus?.consume == MpdConsumeMode.off) {
        await handler._mpdClient?.consume(MpdConsumeMode.on);
      } else {
        await handler._mpdClient?.consume(MpdConsumeMode.off);
      }
    }
  }

  static Future<dynamic> _moveId(
    GeneralAudioHandler handler, [
    Map<String, dynamic>? extras,
  ]) async {
    await handler._mpdClient?.moveId(extras!["from"], extras["to"]);
  }

  static Future<dynamic> _deleteId(
    GeneralAudioHandler handler, [
    Map<String, dynamic>? extras,
  ]) async {
    await handler._mpdClient?.deleteId(extras!["id"]);
  }

  static Future<dynamic> _lsInfo(
    GeneralAudioHandler handler, [
    Map<String, dynamic>? extras,
  ]) async {
    return handler._cacheData(
      command: "lsInfo",
      args: extras!["uri"] ?? "::null",
      compute: () async {
        return (await handler._mpdClient?.lsInfo(extras["uri"]))?.data;
      },
      decode: (json) {
        return List.from(jsonDecode(json)).map((e) {
          try {
            return MpdSong.fromJson(e);
          } catch (_) {
            try {
              return MpdDirectory.fromJson(e);
            } catch (_) {
              return MpdPlaylist.fromJson(e);
            }
          }
        }).toList();
      },
    );
  }

  static Future<dynamic> _clear(
    GeneralAudioHandler handler, [
    Map<String, dynamic>? extras,
  ]) async {
    return (await handler._mpdClient?.clear())?.data;
  }

  static Future<dynamic> _listPlaylists(
    GeneralAudioHandler handler, [
    Map<String, dynamic>? extras,
  ]) async {
    return (await handler._mpdClient?.listPlaylists())?.data;
  }

  static Future<dynamic> _playlistAdd(
    GeneralAudioHandler handler, [
    Map<String, dynamic>? extras,
  ]) async {
    return (await handler._mpdClient?.playlistAdd(
      extras!["name"],
      extras["uri"],
      position: extras["position"],
    ))?.data;
  }

  static Future<dynamic> _addId(
    GeneralAudioHandler handler, [
    Map<String, dynamic>? extras,
  ]) async {
    return (await handler._mpdClient?.addId(
      extras!["uri"],
      position: extras["position"],
    ))?.data;
  }

  static Future<dynamic> _add(
    GeneralAudioHandler handler, [
    Map<String, dynamic>? extras,
  ]) async {
    return (await handler._mpdClient?.add(
      extras!["uri"],
      position: extras["position"],
    ))?.data;
  }

  static Future<dynamic> _playId(
    GeneralAudioHandler handler, [
    Map<String, dynamic>? extras,
  ]) async {
    return (await handler._mpdClient?.playId(extras!["songId"]))?.data;
  }

  static Future<dynamic> _load(
    GeneralAudioHandler handler, [
    Map<String, dynamic>? extras,
  ]) async {
    return (await handler._mpdClient?.load(
      extras!["name"],
      start: extras["start"],
      end: extras["end"],
      position: extras["position"],
    ))?.data;
  }

  static Future<dynamic> _listPlaylistInfo(
    GeneralAudioHandler handler, [
    Map<String, dynamic>? extras,
  ]) async {
    return (await handler._mpdClient?.listPlaylistInfo(
      extras!["name"],
      start: extras["start"],
      end: extras["end"],
    ))?.data;
  }

  static Future<dynamic> _playlistDelete(
    GeneralAudioHandler handler, [
    Map<String, dynamic>? extras,
  ]) async {
    return (await handler._mpdClient?.playlistDelete(
      extras!["name"],
      songPos: extras["songPos"],
      start: extras["start"],
      end: extras["end"],
    ))?.data;
  }

  static Future<dynamic> _playlistMove(
    GeneralAudioHandler handler, [
    Map<String, dynamic>? extras,
  ]) async {
    return (await handler._mpdClient?.playlistMove(
      extras!["name"],
      from: extras["from"],
      start: extras["start"],
      end: extras["end"],
      to: extras["to"],
    ))?.data;
  }

  static Future<dynamic> _rm(
    GeneralAudioHandler handler, [
    Map<String, dynamic>? extras,
  ]) async {
    return (await handler._mpdClient?.rm(extras!["name"]))?.data;
  }

  static Future<dynamic> _rename(
    GeneralAudioHandler handler, [
    Map<String, dynamic>? extras,
  ]) async {
    return (await handler._mpdClient?.rename(
      extras!["name"],
      extras["newName"],
    ))?.data;
  }

  static Future<dynamic> _list(
    GeneralAudioHandler handler, [
    Map<String, dynamic>? extras,
  ]) async {
    return await handler._cacheData(
      command: "name_tags",
      args:
          "${extras!["type"]}:${extras["filter"]}:${extras["groups"]}:${extras["start"]}:${extras["end"]}",
      compute: () async {
        return (await handler._mpdClient?.list(
          extras["type"],
          filter: extras["filter"],
          groups: List<String>.from(jsonDecode(extras["groups"])),
          start: extras["start"],
          end: extras["end"],
        ))?.data;
      },
      decode: (json) {
        return List.from(
          jsonDecode(json),
        ).map((e) => MpdTagGroup.fromJson(e)).toList();
      },
    );
  }

  static Future<dynamic> _find(
    GeneralAudioHandler handler, [
    Map<String, dynamic>? extras,
  ]) async {
    return await handler._cacheData(
      command: "find",
      args:
          "${extras!["filter"]}:${extras["sort"]}:${extras["start"]}:${extras["end"]}",
      compute: () async {
        return (await handler._mpdClient?.find(
          extras["filter"],
          sort: extras["sort"],
          start: extras["start"],
          end: extras["end"],
        ))?.data;
      },
      decode: (json) {
        return List.from(
          jsonDecode(json),
        ).map((e) => MpdSong.fromJson(e)).toList();
      },
    );
  }

  static Future<dynamic> _search(
    GeneralAudioHandler handler, [
    Map<String, dynamic>? extras,
  ]) async {
    return await handler._cacheData(
      command: "search",
      args:
          "${extras!["filter"]}:${extras["sort"]}:${extras["start"]}:${extras["end"]}",
      compute: () async {
        return (await handler._mpdClient?.search(
          extras["filter"],
          sort: extras["sort"],
          start: extras["start"],
          end: extras["end"],
        ))?.data;
      },
      decode: (json) {
        return List.from(
          jsonDecode(json),
        ).map((e) => MpdSong.fromJson(e)).toList();
      },
    );
  }

  static Future<dynamic> _count(
    GeneralAudioHandler handler, [
    Map<String, dynamic>? extras,
  ]) async {
    return await handler._cacheData(
      command: "count",
      args: "${extras!["filter"]}:${extras["group"]}",
      compute: () async {
        return (await handler._mpdClient?.count(
          extras["filter"],
          group: extras["group"],
        ))?.data;
      },
      decode: (json) {
        return List.from(
          jsonDecode(json),
        ).map((e) => MpdCount.fromJson(e)).toList();
      },
    );
  }

  static Future<dynamic> _findAdd(
    GeneralAudioHandler handler, [
    Map<String, dynamic>? extras,
  ]) async {
    return (await handler._mpdClient?.findAdd(
      extras!["filter"],
      sort: extras["sort"],
      start: extras["start"],
      end: extras["end"],
      position: extras["position"],
    ))?.data;
  }

  static Future<dynamic> _searchAdd(
    GeneralAudioHandler handler, [
    Map<String, dynamic>? extras,
  ]) async {
    return (await handler._mpdClient?.searchAdd(
      extras!["filter"],
      sort: extras["sort"],
      start: extras["start"],
      end: extras["end"],
      position: extras["position"],
    ))?.data;
  }

  static Future<dynamic> _searchAddPl(
    GeneralAudioHandler handler, [
    Map<String, dynamic>? extras,
  ]) async {
    return (await handler._mpdClient?.searchAddPl(
      extras!["name"],
      extras["filter"],
      sort: extras["sort"],
      start: extras["start"],
      end: extras["end"],
      position: extras["position"],
    ))?.data;
  }

  static Future<dynamic> _clearCache(
    GeneralAudioHandler handler, [
    Map<String, dynamic>? extras,
  ]) async {
    SharedPreferencesAsync prefs = SharedPreferencesAsync();
    var keys = await prefs.getKeys();
    var dbDate = handler.mpdStats?.dbUpdate.toIso8601String() ?? "null";
    keys
        .where((e) => e.startsWith("${handler.serverId}-$dbDate"))
        .forEach((e) => prefs.remove(e));
  }

  static Future<dynamic> _setSingle(
    GeneralAudioHandler handler, [
    Map<String, dynamic>? extras,
  ]) async {
    await handler._mpdClient?.single(extras!["single"]);
  }

  static Future<dynamic> _setConsume(
    GeneralAudioHandler handler, [
    Map<String, dynamic>? extras,
  ]) async {
    await handler._mpdClient?.consume(extras!["consume"]);
  }

  static Future<dynamic> _crossFade(
    GeneralAudioHandler handler, [
    Map<String, dynamic>? extras,
  ]) async {
    await handler._mpdClient?.crossFade(extras!["seconds"]);
  }

  static Future<dynamic> _mixRampDb(
    GeneralAudioHandler handler, [
    Map<String, dynamic>? extras,
  ]) async {
    await handler._mpdClient?.mixRampDb(extras!["db"]);
  }

  static Future<dynamic> _mixRampDelay(
    GeneralAudioHandler handler, [
    Map<String, dynamic>? extras,
  ]) async {
    await handler._mpdClient?.mixRampDelay(extras!["seconds"]);
  }

  static Future<dynamic> _replayGainMode(
    GeneralAudioHandler handler, [
    Map<String, dynamic>? extras,
  ]) async {
    await handler._mpdClient?.replayGainMode(extras!["mode"]);
  }

  static Future<dynamic> _replayGainStatus(
    GeneralAudioHandler handler, [
    Map<String, dynamic>? extras,
  ]) async {
    return (await handler._mpdClient?.replayGainStatus())!.data;
  }

  static Future<dynamic> _update(
    GeneralAudioHandler handler, [
    Map<String, dynamic>? extras,
  ]) async {
    return (await handler._mpdClient?.update(uri: extras?["uri"]))!.data;
  }

  static Future<dynamic> _rescan(
    GeneralAudioHandler handler, [
    Map<String, dynamic>? extras,
  ]) async {
    return (await handler._mpdClient?.rescan(uri: extras?["uri"]))!.data;
  }

  static Future<dynamic> _listPartitions(
    GeneralAudioHandler handler, [
    Map<String, dynamic>? extras,
  ]) async {
    return (await handler._mpdClient?.listPartitions())!.data;
  }

  static Future<dynamic> _toggleOutput(
    GeneralAudioHandler handler, [
    Map<String, dynamic>? extras,
  ]) async {
    return (await handler._mpdClient?.toggleOutput(extras!["id"]))!.data;
  }

  static Future<dynamic> _partition(
    GeneralAudioHandler handler, [
    Map<String, dynamic>? extras,
  ]) async {
    return (await handler._mpdClient?.partition(extras!["partition"]))!.data;
  }

  static Future<dynamic> _newPartition(
    GeneralAudioHandler handler, [
    Map<String, dynamic>? extras,
  ]) async {
    return (await handler._mpdClient?.newPartition(extras!["partition"]))!.data;
  }

  static Future<dynamic> _delPartition(
    GeneralAudioHandler handler, [
    Map<String, dynamic>? extras,
  ]) async {
    return (await handler._mpdClient?.delPartition(extras!["partition"]))!.data;
  }

  static Future<dynamic> _switchPartition(
    GeneralAudioHandler handler, [
    Map<String, dynamic>? extras,
  ]) async {
    debugPrint("cek partition change");
    await handler._mpdClient?.partition(extras!["partition"]);
    var cekStatus = await handler._mpdClient?.status();
    if (cekStatus?.isValid == true &&
        handler.mpdStatus?.partition != cekStatus!.data.partition) {
      debugPrint("reinit player");
      handler.autoIdle?.noIdle();
      await handler._mpdUpdateQueue();
      await handler._mpdUpdateCurrentSong();
      await handler._updateStats();
      await handler._initAutoIdle();
      ServerInfo.saveCurrentServer(
        (await ServerInfo.getCurrentServer())!.copyWith(
          partition: extras!["partition"],
        ),
      );
      debugPrint("fire event partition change");
      await handler._updateStatus();
      handler.customEvent.add(AudioHandlerEvent.partitionChange);
    }
  }

  static Future<dynamic> _setFavorite(
    GeneralAudioHandler handler, [
    Map<String, dynamic>? extras,
  ]) async {
    return (await handler._mpdClient?.setFavorite(extras!["uri"]))!.data;
  }

  static Future<dynamic> _deleteFavorite(
    GeneralAudioHandler handler, [
    Map<String, dynamic>? extras,
  ]) async {
    return (await handler._mpdClient?.deleteFavorite(extras!["uri"]))!.data;
  }
}
