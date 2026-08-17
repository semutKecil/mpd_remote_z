import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mpd_remote_z/app_router.gr.dart';
import 'package:mpd_remote_z/mpd/model/mpd_song.dart';
import 'package:mpd_remote_z/ui/widget/menu/folder_menu.dart';
import 'package:mpd_remote_z/ui/widget/tile/list_tile_default.dart';

class FolderTile extends StatelessWidget {
  final MpdDirectory directory;
  const FolderTile({super.key, required this.directory});

  @override
  Widget build(BuildContext context) {
    return ListTileDefault(
      title: Text(directory.name),
      leading: const Icon(Icons.folder),
      onTap: () =>
          AutoRouter.of(context).push(FilesRoute(parent: directory.directory)),
      trailing: FolderMenu(directory: directory),
    );
  }
}
