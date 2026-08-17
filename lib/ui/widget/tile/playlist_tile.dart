import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mpd_remote_z/app_router.gr.dart';
import 'package:mpd_remote_z/mpd/model/mpd_song.dart';
import 'package:mpd_remote_z/ui/widget/tile/list_tile_default.dart';
import 'package:mpd_remote_z/ui/widget/menu/playlist_tile_menu.dart';

class PlaylistTile extends StatelessWidget {
  final MpdPlaylist playlist;
  final bool savedPlaylist;
  const PlaylistTile({
    super.key,
    required this.playlist,
    this.savedPlaylist = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTileDefault(
      title: Text(playlist.playlist),
      leading: const Icon(Icons.playlist_play),
      trailing: PlaylistTileMenu(playlist: playlist, savedPlaylist: false),
      onTap: () {
        AutoRouter.of(
          context,
        ).push(PlaylistRoute(playlist: playlist.playlist, static: true));
      },
    );
  }
}
