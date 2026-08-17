import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mpd_remote_z/main.dart';
import 'package:mpd_remote_z/mpd/model/mpd_song.dart';
import 'package:mpd_remote_z/mpd/string_ext.dart';
import 'package:mpd_remote_z/ui/widget/future_widget.dart';
import 'package:mpd_remote_z/ui/widget/tile/song_tile.dart';

@RoutePage()
class TagsPage extends StatelessWidget {
  final String value;
  final String tag;
  final String title;
  const TagsPage({
    super.key,
    @PathParam("value") required this.value,
    @PathParam("tag") required this.tag,
    @PathParam("title") required this.title,
  });

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
          title: Text("$title: $value"),
        ),
        Expanded(
          child: FutureWidget<List<MpdSong>>(
            future: () =>
                audioService.custom.find('($tag == "${value.mpdEscape()}")'),
            builder: (context, data) {
              return ListView.builder(
                      // padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemBuilder: (context, index) {
                        return SongTile(song: data[index]);
                      },
                      itemCount: data.length,
                    );
            },
          ),
        ),
      ],
    );
  }
}
