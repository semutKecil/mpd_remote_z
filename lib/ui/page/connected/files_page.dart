import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mpd_remote_z/main.dart';
import 'package:mpd_remote_z/mpd/model/mpd_song.dart';
import 'package:mpd_remote_z/ui/widget/menu/folder_menu.dart';
import 'package:mpd_remote_z/ui/widget/tile/folder_tile.dart';
import 'package:mpd_remote_z/ui/widget/future_widget.dart';
import 'package:mpd_remote_z/ui/widget/tile/playlist_tile.dart';
import 'package:mpd_remote_z/ui/widget/tile/song_tile.dart';

@RoutePage()
class FilesPage extends StatelessWidget {
  final String? parent;
  const FilesPage({super.key, @PathParam('parent') this.parent});

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
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Files"),
              parent != null
                  ? Text(
                      parent!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(fontSize: 12),
                    )
                  : SizedBox.shrink(),
            ],
          ),
          actions: parent != null
              ? [
                  FolderMenu(
                    directory: MpdDirectory(directory: parent!),
                    isAppBarMenu: true,
                  ),
                ]
              : null,
        ),
        Expanded(
          child: FutureWidget(
            future: () => audioService.custom.lsInfo(uri: parent),
            builder: (context, data) {
              if (data == null) return SizedBox.shrink();
              List<MpdDirectory> dirs = data.whereType<MpdDirectory>().toList();
              List<MpdPlaylist> playlists = data.whereType<MpdPlaylist>().where(
                (element) {
                  return element.playlist.endsWith(".m3u") ||
                      element.playlist.endsWith(".pls") ||
                      element.playlist.endsWith(".asx") ||
                      element.playlist.endsWith(".rss") ||
                      element.playlist.endsWith(".cue");
                },
              ).toList();
              List<MpdSong> songs = data.whereType<MpdSong>().toList();

              return CustomScrollView(
                slivers: [
                  SliverList.builder(
                    itemBuilder: (context, index) {
                      return FolderTile(
                        key: ValueKey("dir-${dirs[index].directory}"),
                        directory: dirs[index],
                      );
                    },
                    itemCount: dirs.length,
                  ),

                  SliverList.builder(
                    itemBuilder: (context, index) {
                      return PlaylistTile(
                        key: ValueKey("pls-${playlists[index].playlist}"),
                        playlist: playlists[index],
                        savedPlaylist: false,
                      );
                    },
                    itemCount: playlists.length,
                  ),

                  SliverList.builder(
                    itemBuilder: (context, index) {
                      return SongTile(
                        key: ValueKey("song-${songs[index].file}"),
                        song: songs[index],
                      );
                    },
                    itemCount: songs.length,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
