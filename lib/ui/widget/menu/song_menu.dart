import 'package:flutter/material.dart';
import 'package:mpd_remote_z/main.dart';
import 'package:mpd_remote_z/mpd/model/mpd_song.dart';
import 'package:mpd_remote_z/mpd/string_ext.dart';
import 'package:mpd_remote_z/service/mpd_song_ext.dart';
import 'package:mpd_remote_z/ui/widget/dialog/add_playlist_dialog.dart';
import 'package:mpd_remote_z/ui/widget/dialog/common_dialog.dart';
import 'package:mpd_remote_z/ui/widget/menu/simple_popup_menu.dart';

class SongPlaylistMenu {
  final String playlist;
  final int songPos;
  const SongPlaylistMenu({required this.playlist, required this.songPos});
}

class SongMenu extends StatelessWidget {
  final bool isAppBarMenu;
  final MpdSong song;
  final SongPlaylistMenu? withPlaylistMenu;
  final int? queueId;
  const SongMenu({
    super.key,
    required this.song,
    this.isAppBarMenu = false,
    this.withPlaylistMenu,
    this.queueId,
  });

  @override
  Widget build(BuildContext context) {
    var menu = {
      "Add": () async {
        audioService.addQueueItem(await song.toMediaItem(withArt: false));
      },
      "Add & Play": () async {
        var id = await audioService.custom.addId(song.file);
        await audioService.custom.playId(id);
      },
      "Clear & Play": () async {
        await audioService.custom.clear();
        await audioService.addQueueItem(await song.toMediaItem(withArt: false));
        await audioService.play();
      },
      "Add To Playlist": () async {
        AddPlaylistDialog.addToPlaylist(context, (playlist) async {
          await audioService.custom.playlistAdd(playlist, song.file);
        });
      },
      "Details": () async {
        showDialog<void>(
          context: context,
          useRootNavigator: true,
          builder: (BuildContext context) {
            return CommonDialog(
              titleText: song.title,
              builder: (context) => Column(
                mainAxisSize: MainAxisSize.min,
                children: song.tags.entries
                    .map(
                      (e) => Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 80, child: Text(e.key.capitalize())),
                          Text(": "),
                          Expanded(child: Text(e.value.join(", "))),
                        ],
                      ),
                    )
                    .toList(),
              ),
              actionsBuilder: (context) => [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      },
    };

    if (withPlaylistMenu != null) {
      menu["Remove"] = () async {
        await audioService.custom.playlistDelete(
          withPlaylistMenu!.playlist,
          songPos: withPlaylistMenu!.songPos,
        );
      };
    }

    if (queueId != null) {
      menu["Remove"] = () async {
        audioService.custom.deleteId(int.parse(queueId.toString()));
      };
    }

    return SimplePopupMenu(
      icon: Icon(isAppBarMenu ? Icons.more_vert : Icons.more_horiz),
      items: menu,
    );
  }
}
