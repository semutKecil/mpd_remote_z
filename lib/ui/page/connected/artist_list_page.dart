import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mpd_remote_z/app_router.gr.dart';
import 'package:mpd_remote_z/main.dart';
import 'package:mpd_remote_z/ui/widget/future_widget.dart';
import 'package:mpd_remote_z/ui/page/connected/search_page.dart';
import 'package:mpd_remote_z/ui/widget/tile/artist_tile.dart';

@RoutePage()
class ArtistListPage extends StatelessWidget {
  const ArtistListPage({super.key});

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
          title: const Text("Artists"),
          actions: [
            IconButton(
              onPressed: () {
                AutoRouter.of(
                  context,
                ).push(SearchRoute(tags: Tags.artist.value));
              },
              icon: Icon(Icons.search),
            ),
          ],
        ),
        Expanded(
          child: FutureWidget(
            future: () {
              return audioService.custom.list("Artist");
            },
            builder: (context, data) {
              return ListView.builder(
                itemBuilder: (context, index) {
                  return ArtistTile(
                    key: ValueKey(index),
                    artist: data[index].value,
                  );
                },
                itemCount: data.length,
              );
            },
          ),
          //
        ),
      ],
    );
  }
}
