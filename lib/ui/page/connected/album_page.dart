
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mpd_remote_z/main.dart';
import 'package:mpd_remote_z/mpd/model/mpd_song.dart';
import 'package:mpd_remote_z/mpd/string_ext.dart';
import 'package:mpd_remote_z/ui/widget/album_title.dart';
import 'package:mpd_remote_z/ui/widget/future_widget.dart';
import 'package:mpd_remote_z/ui/widget/menu/general_filter_menu.dart';
import 'package:mpd_remote_z/ui/widget/tile/song_tile.dart';

@RoutePage()
class AlbumPage extends StatelessWidget {
  final String album;
  const AlbumPage({super.key, @PathParam("album") required this.album});

  Future<List<MpdSong>> loadAlbumData() async {
    return audioService.custom.find('(Album == "${album.mpdEscape()}")');
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
          title: Text(album),
          actions: [
            GeneralFilterMenu(
              filter: '(Album == "${album.mpdEscape()}")',
              isAppBarMenu: true,
            ),
          ],
        ),
        Expanded(
          child: FutureWidget(
            future: loadAlbumData,
            builder: (context, data) {
              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 200,
                    pinned: false,
                    // title: Text(album),
                    // backgroundColor: Colors.black,
                    forceMaterialTransparency: true,
                    automaticallyImplyLeading: false,
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.parallax,
                      expandedTitleScale: 1,
                      background: AlbumTitle(song: data[0]),
                      // centerTitle: true,
                      // title: Text(album, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList.builder(
                      itemBuilder: (context, index) {
                        return SongTile(song: data[index]);
                      },
                      itemCount: data.length,
                    ),
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
