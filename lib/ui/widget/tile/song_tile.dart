import 'package:flutter/material.dart';
import 'package:mpd_remote_z/mpd/model/mpd_song.dart';
import 'package:mpd_remote_z/ui/widget/tile/list_tile_default.dart';
import 'package:mpd_remote_z/ui/widget/menu/song_menu.dart';

class SongTile extends StatelessWidget {
  final MpdSong song;
  final SongPlaylistMenu? withPlaylistMenu;
  const SongTile({super.key, required this.song, this.withPlaylistMenu});

  @override
  Widget build(BuildContext context) {
    return ListTileDefault(
      title: Text(song.title),
      subtitle: Text(song.description),
      leading: const Icon(Icons.music_note),
      trailing: SongMenu(song: song, withPlaylistMenu: withPlaylistMenu),
      // SongTileMenu.toPopUpButon(
      //   context,
      //   song,
      //   withPlaylistMenu: withPlaylistMenu,
      //   vertical: false,
      // ),
    );
  }
}
