import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mpd_remote_z/app_router.gr.dart';
import 'package:mpd_remote_z/main.dart';
import 'package:mpd_remote_z/mpd/model/mpd_song.dart';
import 'package:mpd_remote_z/service/general_audio_handler.dart';
import 'package:mpd_remote_z/ui/widget/drawer/drawer_expansion_tile.dart';
import 'package:mpd_remote_z/ui/widget/drawer/drawer_menu_tile.dart';
import 'package:mpd_remote_z/ui/widget/menu/playlist_tile_menu.dart';

class PlaylistMenu extends StatefulWidget {
  const PlaylistMenu({super.key});

  @override
  State<PlaylistMenu> createState() => _PlaylistMenuState();
}

class _PlaylistMenuState extends State<PlaylistMenu> {
  List<MpdPlaylist>? _playlists;
  StreamSubscription<dynamic>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = audioService.customEvent.listen((value) async {
      if (value == AudioHandlerEvent.storedPlaylistUpdate) {
        _playlists = await audioService.custom.listPlaylists();
        if (mounted) {
          setState(() {});
        }
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      _playlists = await audioService.custom.listPlaylists();
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DrawerExpansionTile(
      title: "Playlists",
      leading: Icon(Icons.playlist_play),
      children: List.generate(_playlists?.length ?? 0, (index) {
        return DrawerMenuTile(
          title: _playlists![index].playlist,
          leading: Icon(Icons.playlist_play_rounded),
          onTap: () {
            Navigator.pop(context);
            AutoRouter.of(
              context,
            ).push(PlaylistRoute(playlist: _playlists![index].playlist));
          },
          trailing: PlaylistTileMenu(
            playlist: MpdPlaylist(playlist: _playlists![index].playlist),
            savedPlaylist: true,
          ),
        );
      }),
    );
  }
}
