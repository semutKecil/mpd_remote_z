import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mpd_remote_z/main.dart';
import 'package:mpd_remote_z/model/song_art.dart';
import 'package:mpd_remote_z/mpd/model/mpd_song.dart';
import 'package:mpd_remote_z/mpd/string_ext.dart';
import 'package:mpd_remote_z/ui/widget/album_title.dart';
import 'package:mpd_remote_z/ui/widget/future_widget.dart';
import 'package:mpd_remote_z/ui/widget/menu/general_filter_menu.dart';
import 'package:mpd_remote_z/ui/widget/tile/song_tile.dart';
import 'package:path_provider/path_provider.dart';

class AlbumSong {
  final String album;
  final int count;
  final Uri art;
  final ColorScheme scheme;
  final Duration duration;
  final List<MpdSong> songs;
  const AlbumSong({
    required this.album,
    required this.songs,
    required this.art,
    required this.scheme,
    this.duration = const Duration(seconds: 0),
    this.count = 0,
  });
}

@RoutePage()
class ArtistPage extends StatelessWidget {
  final String artist;
  const ArtistPage({
    super.key,
    @PathParam("artist") required this.artist,
  }); // required this.artist});

  Future<List<AlbumSong>> loadArtistData(String artist) async {
    List<MpdSong> songs = await audioService.custom.find(
      '(Artist == "${artist.mpdEscape()}")',
    );

    Map<String, List<MpdSong>> albumMap = {};
    for (var song in songs) {
      if (albumMap[song.album] == null) albumMap[song.album] = [];
      albumMap[song.album]!.add(song);
    }

    return Future.wait(
      albumMap.entries.map((e) async {
        var songArt = await SongArt.findByData(song: e.value.first);
        var art = await songArt?.uri;
        if (songArt?.uri == null) {
          final docDir = await getApplicationSupportDirectory();
          art = File('${docDir.path}/$defaultCoverHash').uri;
        }

        var count = await audioService.custom.count(
          '(Album == "${e.key.mpdEscape()}")',
        );

        return AlbumSong(
          album: e.key,
          songs: e.value,
          art: art!,
          scheme: songArt?.colorScheme ?? defaultColorScheme,
          count: count.first.songs,
          duration: count.first.duration,
        );
      }).toList(),
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
          title: Text(artist),
          actions: [
            GeneralFilterMenu(
              filter: '(Album == "${artist.mpdEscape()}")',
              isAppBarMenu: true,
            ),
          ],
        ),
        Expanded(
          child: FutureWidget(
            future: () => loadArtistData(artist),
            builder: (context, data) {
              List<Widget> slivers = [];
              for (var albumSong in data) {
                slivers.add(
                  SliverAppBar(
                    expandedHeight: 200,
                    pinned: false,
                    forceMaterialTransparency: true,
                    automaticallyImplyLeading: false,
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.parallax,
                      expandedTitleScale: 1,
                      background: AlbumTitle(song: albumSong.songs.first),
                    ),
                  ),
                );

                slivers.add(
                  SliverPadding(
                    padding: EdgeInsetsGeometry.only(bottom: 30),
                    sliver: SliverList.builder(
                      itemBuilder: (context, index) {
                        return SongTile(song: albumSong.songs[index]);
                      },
                      itemCount: albumSong.songs.length,
                    ),
                  ),
                );
              }

              return CustomScrollView(slivers: slivers);
            },
          ),
        ),
      ],
    );
  }
}
