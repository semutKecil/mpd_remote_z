import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mpd_remote_z/app_router.gr.dart';
import 'package:mpd_remote_z/mpd/string_ext.dart';
import 'package:mpd_remote_z/ui/widget/menu/general_filter_menu.dart';
import 'package:mpd_remote_z/ui/widget/tile/list_tile_default.dart';

class GeneralTagTile extends StatelessWidget {
  final String tag;
  final String value;
  final String title;
  const GeneralTagTile({
    super.key,
    required this.tag,
    required this.value,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return ListTileDefault(
      leading: const Icon(Icons.tag),
      title: Text(value),
      onTap: () {
        AutoRouter.of(
          context,
        ).push(TagsRoute(title: title, tag: tag, value: value));
      },
      trailing: GeneralFilterMenu(filter: '($tag == "${value.mpdEscape()}")'),
    );
  }
}
