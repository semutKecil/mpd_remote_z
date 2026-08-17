import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:mpd_remote_z/main.dart';
import 'package:mpd_remote_z/ui/widget/tile/queue_song_tile.dart';

class QueueSliver extends StatefulWidget {
  const QueueSliver({super.key});

  @override
  State<QueueSliver> createState() => _QueueSliverState();
}

class _QueueSliverState extends State<QueueSliver> {
  late final StreamSubscription<List<MediaItem>> _sub;
  List<MediaItem> _queue = [];
  @override
  void initState() {
    super.initState();
    _sub = audioService.queue.listen((value) {
      setState(() {
        _queue = value;
      });
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverReorderableList(
      itemBuilder: (context, index) {
        return ReorderableDelayedDragStartListener(
          key: ValueKey(_queue[index].id), // Unique key is crucial
          index: index,
          child: QueueSongTile(
            key: ValueKey(_queue[index].id),
            song: _queue[index],
          ),
        );
      },
      itemCount: _queue.length,
      onReorderItem: (oldIndex, newIndex) async {
        var dupQueue = List.from(_queue);
        setState(() {
          _queue = List.from(_queue)
            ..removeAt(oldIndex)
            ..insert(
              newIndex - (newIndex > oldIndex ? 1 : 0),
              _queue[oldIndex],
            );
        });

        await audioService.custom.moveId(
          int.parse(dupQueue[oldIndex].id),
          newIndex - (newIndex > oldIndex ? 1 : 0),
        );

        //
      },
    );
  }
}
