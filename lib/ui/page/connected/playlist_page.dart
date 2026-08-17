import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mpd_remote_z/main.dart';
import 'package:mpd_remote_z/mpd/model/mpd_song.dart';
import 'package:mpd_remote_z/service/general_audio_handler.dart';
import 'package:mpd_remote_z/ui/widget/menu/song_menu.dart';
import 'package:mpd_remote_z/ui/widget/menu/playlist_tile_menu.dart';
import 'package:mpd_remote_z/ui/widget/tile/song_tile.dart';

@RoutePage()
class PlaylistPage extends StatefulWidget {
  final String playlist;
  final bool static;
  const PlaylistPage({
    super.key,
    @PathParam("name") required this.playlist,
    this.static = false,
  });

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  List<MpdSong>? _songs;
  late final StreamSubscription<dynamic> _sub;

  @override
  void initState() {
    super.initState();
    _sub = audioService.customEvent.listen((value) {
      if (value == AudioHandlerEvent.storedPlaylistUpdate) {
        loadSong();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      loadSong();
    });
  }

  Future<void> loadSong() async {
    _songs = await audioService.custom.listPlaylistInfo(widget.playlist);
    if (mounted && context.mounted) setState(() {});
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  Widget tileBuilder(BuildContext context, int index) {
    return SongTile(
      key: ValueKey(index),
      song: _songs![index],
      withPlaylistMenu: SongPlaylistMenu(
        playlist: widget.playlist,
        songPos: index,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          leading: context.router.stack.length > 2
              ? IconButton(
                  onPressed: () {
                    AutoRouter.of(context).pop();
                  },
                  icon: Icon(Icons.arrow_back),
                )
              : null,
          title: Text(widget.playlist),
          actions: [
            PlaylistTileMenu(
              playlist: MpdPlaylist(playlist: widget.playlist),
              savedPlaylist: true,
              isAppBarMenu: true,
            ),
          ],
        ),
        Expanded(
          child: _songs == null
              ? const Center(child: CircularProgressIndicator())
              : Builder(
                  builder: (context) {
                    return widget.static
                        ? ListView.builder(
                            itemBuilder: tileBuilder,
                            itemCount: _songs!.length,
                          )
                        : ReorderableListView.builder(
                            // padding: const EdgeInsets.symmetric(horizontal: 20),
                            buildDefaultDragHandles: false,
                            itemBuilder: (context, index) {
                              return ReorderableDelayedDragStartListener(
                                key: ValueKey(index), // Unique key is crucial
                                index: index,
                                child: tileBuilder(context, index),
                              );
                            },
                            itemCount: _songs!.length,
                            onReorderItem: (oldIndex, newIndex) async {
                              setState(() {
                                _songs = List.from(_songs!)
                                  ..removeAt(oldIndex)
                                  ..insert(
                                    newIndex - (newIndex > oldIndex ? 1 : 0),
                                    _songs![oldIndex],
                                  );
                              });

                              await audioService.custom.playlistMove(
                                widget.playlist,
                                from: oldIndex,
                                to: newIndex - (newIndex > oldIndex ? 1 : 0),
                              );
                            },
                          );
                  },
                ),
        ),
      ],
    );
  }
}
