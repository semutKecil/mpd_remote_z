import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mpd_remote_z/app_router.gr.dart';
import 'package:mpd_remote_z/main.dart';
import 'package:mpd_remote_z/model/server_info.dart';
import 'package:mpd_remote_z/mpd/model/mpd_stats.dart';
import 'package:mpd_remote_z/service/u.dart';
import 'package:mpd_remote_z/ui/page/connected/search_page.dart';
import 'package:mpd_remote_z/ui/widget/drawer/drawer_expansion_tile.dart';
import 'package:mpd_remote_z/ui/widget/drawer/drawer_menu_tile.dart';
import 'package:mpd_remote_z/ui/widget/future_widget.dart';
import 'package:mpd_remote_z/ui/widget/drawer/playlist_menu.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  Future<MapEntry<ServerInfo, MpdStats>?> loadInfo() async {
    var serverInfo = await ServerInfo.getCurrentServer();
    var mpdStats = await audioService.custom.mpdStats();
    if (serverInfo == null || mpdStats == null) return null;
    return MapEntry(serverInfo, mpdStats);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(
        context,
      ).colorScheme.primaryContainer.withAlpha(240),
      shape: LinearBorder(),
      child: SafeArea(
        child: ListView(
          children: [
            Container(
              decoration: BoxDecoration(
                border: BoxBorder.fromLTRB(
                  bottom: BorderSide(
                    width: 1,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha(50),
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      spacing: 20,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: Image.asset(
                            'assets/images/rect81.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        Expanded(
                          child: FutureWidget<MapEntry<ServerInfo, MpdStats>?>(
                            future: loadInfo,
                            builder: (context, data) {
                              if (data != null) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data.key.name,
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      "${data.key.host}:${data.key.port}",
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    Text(
                                      "Songs: ${data.value.songs}",
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    Text(
                                      "Play Time: ${data.value.dbPlaytime.formatPlayTime()}",
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                );
                              } else {
                                return Container();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            DrawerMenuTile(
              title: "Now Playing",
              leading: Icon(Icons.home),
              onTap: () {
                Navigator.pop(context);
                AutoRouter.of(context).replaceAll([NowPlayingRoute()]);
              },
            ),
            // DrawerMenuTile(title: "Favorites", leading: Icon(Icons.star)),
            DrawerMenuTile(
              title: "Search",
              leading: Icon(Icons.search),
              onTap: () {
                Navigator.pop(context);
                AutoRouter.of(
                  context,
                ).replaceAll([NowPlayingRoute(), SearchRoute()]);
              },
            ),

            DrawerExpansionTile(
              title: "Library",
              leading: Icon(Icons.library_music),
              children: [
                DrawerMenuTile(
                  title: "Files",
                  leading: Icon(Icons.folder_open),
                  onTap: () {
                    Navigator.pop(context);
                    AutoRouter.of(
                      context,
                    ).replaceAll([NowPlayingRoute(), FilesRoute()]);
                  },
                ),
                DrawerMenuTile(
                  title: "Artists",
                  leading: Icon(Icons.mic),
                  onTap: () {
                    Navigator.pop(context);
                    AutoRouter.of(
                      context,
                    ).replaceAll([NowPlayingRoute(), ArtistListRoute()]);
                  },
                ),
                DrawerMenuTile(
                  title: "Albums",
                  leading: Icon(Icons.album),
                  onTap: () {
                    Navigator.pop(context);
                    AutoRouter.of(
                      context,
                    ).replaceAll([NowPlayingRoute(), AlbumListRoute()]);
                  },
                ),
                DrawerExpansionTile(
                  title: "Tags",
                  leading: Icon(Icons.tag),
                  children: Tags.values
                      .where(
                        (e) =>
                            !(e == Tags.title ||
                                e == Tags.album ||
                                e == Tags.artist),
                      )
                      .map((e) {
                        return DrawerMenuTile(
                          title: e.label,
                          leading: Icon(Icons.tag),
                          onTap: () {
                            Navigator.pop(context);
                            AutoRouter.of(context).replaceAll([
                              NowPlayingRoute(),
                              TagsListRoute(title: e.label, tag: e.value),
                            ]);
                          },
                        );
                      })
                      .toList(),
                ),
              ],
            ),
            const PlaylistMenu(),
            // DrawerMenuTile(title: "Radio", leading: Icon(Icons.radio)),
            DrawerMenuTile(
              title: "Settings",
              leading: Icon(Icons.settings),
              onTap: () {
                Navigator.pop(context);
                AutoRouter.of(
                  context,
                ).replaceAll([NowPlayingRoute(), const SettingsRoute()]);
              },
            ),

            // DrawerMenuTile(
            //   title: "Clear",
            //   leading: Icon(Icons.settings),
            //   onTap: () {
            //     audioService.custom.clearCache();
            //   },
            // ),
            DrawerMenuTile(
              title: "Disconnect",
              leading: Icon(Icons.power_settings_new),
              onTap: () async {
                await audioService.custom.disconnect(consent: true);
                await ServerInfo.deleteCurrentServer();
                if (context.mounted) {
                  AutoRouter.of(context).replaceAll([
                    ServerListRoute(
                      onConnect: (context) {
                        AutoRouter.of(context).replaceAll([NowPlayingRoute()]);
                      },
                    ),
                  ]);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
