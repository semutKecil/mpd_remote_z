import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mpd_remote_z/app_router.gr.dart';
import 'package:mpd_remote_z/mpd/string_ext.dart';
import 'package:mpd_remote_z/ui/widget/menu/general_filter_menu.dart';
import 'package:mpd_remote_z/ui/widget/tile/list_tile_default.dart';

class ArtistTile extends StatelessWidget {
  final String artist;
  const ArtistTile({super.key, required this.artist});

  @override
  Widget build(BuildContext context) {
    return ListTileDefault(
      leading: const Icon(Icons.mic),
      title: Text(artist),
      onTap: () {
        AutoRouter.of(context).push(ArtistRoute(artist: artist));
      },
      trailing: GeneralFilterMenu(
        filter: '(Artist == "${artist.mpdEscape()}")',
      ),
    );
  }
}
