import 'package:flutter/material.dart';
import 'package:mpd_remote_z/main.dart';
import 'package:mpd_remote_z/mpd/model/mpd_song.dart';
import 'package:mpd_remote_z/ui/widget/dialog/add_playlist_dialog.dart';
import 'package:mpd_remote_z/ui/widget/menu/simple_popup_menu.dart';

class FolderMenu extends StatelessWidget {
  final MpdDirectory directory;
  final bool isAppBarMenu;
  const FolderMenu({
    super.key,
    required this.directory,
    this.isAppBarMenu = false,
  });

  @override
  Widget build(BuildContext context) {
    return SimplePopupMenu(
      icon: Icon(isAppBarMenu ? Icons.more_vert : Icons.more_horiz),
      items: {
        "Add": () async {
          audioService.custom.add(directory.directory);
        },
        "Add & Play": () async {
          var length = audioService.queue.value.length;
          await audioService.custom.add(directory.directory);
          audioService.skipToQueueItem(length);
        },
        "Clear & Play": () async {
          await audioService.custom.clear();
          await audioService.custom.add(directory.directory);
          await audioService.play();
        },
        "Add To Playlist": () async {
          AddPlaylistDialog.addToPlaylist(context, (playlist) async {
            await audioService.custom.playlistAdd(
              playlist,
              directory.directory,
            );
          });
        },
      },
    );
  }
}
