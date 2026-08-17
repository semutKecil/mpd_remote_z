import 'package:flutter/material.dart';
import 'package:mpd_remote_z/main.dart';
import 'package:mpd_remote_z/mpd/model/mpd_song.dart';
import 'package:mpd_remote_z/ui/widget/dialog/rename_playlist_dialog.dart';
import 'package:mpd_remote_z/ui/widget/menu/simple_popup_menu.dart';

class PlaylistTileMenu extends StatelessWidget {
  final bool isAppBarMenu;
  final MpdPlaylist playlist;
  final bool savedPlaylist;
  const PlaylistTileMenu({
    super.key,
    required this.playlist,
    this.isAppBarMenu = false,
    this.savedPlaylist = true,
  });

  @override
  Widget build(BuildContext context) {
    var menu = {
      "Add": () async {
        audioService.custom.load(playlist.playlist);
      },
      "Add & Play": () async {
        var length = audioService.queue.value.length;
        await audioService.custom.load(playlist.playlist);
        audioService.skipToQueueItem(length);
      },
      "Clear & Play": () async {
        await audioService.custom.clear();
        await audioService.custom.load(playlist.playlist);
        await audioService.play();
      },
    };

    if (savedPlaylist) {
      menu["Remove"] = () async {
        await audioService.custom.rm(playlist.playlist);
      };

      menu["Rename"] = () async {
        RenamePlaylistDialog.show(context, playlist);
      };
    }

    return SimplePopupMenu(
      icon: Icon(isAppBarMenu ? Icons.more_vert : Icons.more_horiz),
      items: menu,
    );
  }
}
