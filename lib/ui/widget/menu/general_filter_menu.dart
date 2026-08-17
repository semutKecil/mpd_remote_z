import 'package:flutter/material.dart';
import 'package:mpd_remote_z/main.dart';
import 'package:mpd_remote_z/ui/widget/dialog/add_playlist_dialog.dart';
import 'package:mpd_remote_z/ui/widget/menu/simple_popup_menu.dart';

class GeneralFilterMenu extends StatelessWidget {
  final bool isAppBarMenu;
  final String filter;
  final ButtonStyle? style;
  const GeneralFilterMenu({
    super.key,
    required this.filter,
    this.isAppBarMenu = false,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return SimplePopupMenu(
      icon: Icon(isAppBarMenu ? Icons.more_vert : Icons.more_horiz),
      style: style,
      items: {
        "Add": () async {
          await audioService.custom.findAdd(
            filter, //'(Artist == "${artist.mpdEscape()}")',
          );
        },
        "Add & Play": () async {
          var length = audioService.queue.value.length;
          await audioService.custom.findAdd(filter);
          await audioService.skipToQueueItem(length);
        },
        "Clear & Play": () async {
          await audioService.custom.clear();
          await audioService.custom.findAdd(filter);
          await audioService.play();
        },
        "Add To Playlist": () async {
          AddPlaylistDialog.addToPlaylist(context, (playlist) {
            audioService.custom.searchAddPl(playlist, filter);
          });
        },
      },
    );
  }
}
