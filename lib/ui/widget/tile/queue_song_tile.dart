import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:mpd_remote_z/main.dart';
import 'package:mpd_remote_z/service/general_audio_handler.dart';
import 'package:mpd_remote_z/service/media_item_ext.dart';
import 'package:mpd_remote_z/service/u.dart';
import 'package:mpd_remote_z/ui/widget/tile/list_tile_default.dart';
import 'package:mpd_remote_z/ui/widget/menu/song_menu.dart';

class QueueSongTile extends StatefulWidget {
  final MediaItem song;
  const QueueSongTile({super.key, required this.song});

  @override
  State<QueueSongTile> createState() => _QueueSongTileState();
}

class _QueueSongTileState extends State<QueueSongTile> {
  late final StreamSubscription<dynamic> _sub;
  bool _selected = false;
  @override
  void initState() {
    super.initState();
    _selected = widget.song.id == audioService.mpdStatus?.songId.toString();
    _sub = audioService.customEvent.listen((value) async {
      if (value == AudioHandlerEvent.statusUpdate) {
        if (!mounted) return;
        setState(() {
          _selected =
              widget.song.id == audioService.mpdStatus?.songId.toString();
        });
      }
    });
  }

  // void checkSelected() {
  //   var id = audioService.mpdStatus?.songId;
  // }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTileDefault(
      title: Text(widget.song.title, overflow: TextOverflow.ellipsis),
      selected: _selected,
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              widget.song.displayDescription ?? "-",
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(widget.song.duration?.format() ?? "-:--"),
        ],
      ),
      trailing: SongMenu(
        song: widget.song.mpdSong!,
        queueId: widget.song.mpdSong?.id,
      ),
      leading: Icon(Icons.music_note_outlined),
      onTap: () => audioService.playFromMediaId(widget.song.id),
    );
  }
}
