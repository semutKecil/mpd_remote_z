import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mpd_remote_z/app_router.gr.dart';
import 'package:mpd_remote_z/main.dart';
import 'package:mpd_remote_z/ui/page/connected/search_page.dart';
import 'package:mpd_remote_z/ui/widget/tile/album_card.dart';
import 'package:mpd_remote_z/ui/widget/future_widget.dart';

class AlbumAndArtist {
  final String album;
  final String artist;
  const AlbumAndArtist({required this.album, required this.artist});
}

@RoutePage()
class AlbumListPage extends StatelessWidget {
  const AlbumListPage({super.key});

  Future<List<AlbumAndArtist>> loadAlbum() async {
    return (await audioService.custom.list("AlbumArtist", groups: ["Album"]))
        .map(
          (e) => AlbumAndArtist(
            album: e.value,
            artist: e.children.map((a) => a.value).join(", "),
          ),
        )
        .toList();
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
          title: const Text("Albums"),
          actions: [
            IconButton(
              onPressed: () {
                AutoRouter.of(
                  context,
                ).push(SearchRoute(tags: Tags.album.value));
              },
              icon: Icon(Icons.search),
            ),
          ],
        ),
        Expanded(
          child: FutureWidget<List<AlbumAndArtist>>(
            future: loadAlbum,
            builder: (context, data) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  var albumWidth = 150.0;
                  if (constraints.maxWidth > 500) {
                    albumWidth = 200.0;
                  }

                  var row = (constraints.maxWidth / albumWidth).floor();

                  return GridView.builder(
                    padding: const EdgeInsets.all(15),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: row, // number of columns
                      crossAxisSpacing: 15, // horizontal spacing
                      mainAxisSpacing: 15, // vertical spacing
                      // childAspectRatio: 0.7,
                    ),
                    itemBuilder: (context, index) {
                      return AlbumCard(
                        key: ValueKey("$index-${data[index].album}"),
                        data: data[index],
                      );
                    },
                    itemCount: data.length,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
