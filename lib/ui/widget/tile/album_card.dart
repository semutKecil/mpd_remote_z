import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mpd_remote_z/app_router.gr.dart';
import 'package:mpd_remote_z/main.dart';
import 'package:mpd_remote_z/model/song_art.dart';
import 'package:mpd_remote_z/mpd/string_ext.dart';
import 'package:mpd_remote_z/ui/page/connected/album_list_page.dart';
import 'package:mpd_remote_z/ui/widget/menu/general_filter_menu.dart';
import 'package:path_provider/path_provider.dart';

class AlbumCard extends StatefulWidget {
  final AlbumAndArtist data;
  const AlbumCard({super.key, required this.data});

  @override
  State<AlbumCard> createState() => _AlbumCardState();
}

class _AlbumCardState extends State<AlbumCard> {
  File? art;
  ColorScheme? scheme;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final docDir = await getApplicationSupportDirectory();
      art = File('${docDir.path}/$defaultCoverHash');
      if (mounted) {
        setState(() {
          art = File('${docDir.path}/$defaultCoverHash');
        });
      }
      var songs = await audioService.custom.find(
        '(Album == "${widget.data.album.mpdEscape()}")',
      );

      var songArt = await SongArt.findByData(song: songs.first);

      var loadedArt = await songArt?.uri;
      if (mounted &&
          loadedArt != null &&
          File.fromUri(loadedArt).existsSync()) {
        setState(() {
          scheme = songArt!.colorScheme;
          art = File.fromUri(loadedArt);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AutoRouter.of(context).push(AlbumRoute(album: widget.data.album));
      },
      child: Theme(
        data: scheme == null
            ? Theme.of(context)
            : Theme.of(context).copyWith(colorScheme: scheme!),
        child: Builder(
          builder: (context) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: AnimatedSwitcher(
                        duration: Duration(milliseconds: 1000),
                        child: art == null
                            ? SizedBox.shrink()
                            : SizedBox(
                                key: ValueKey("album-card-${art!.path}"),
                                width: double.infinity,
                                height: double.infinity,
                                child: Image.file(art!, fit: BoxFit.cover),
                              ),
                      ),
                    ),

                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        color: Theme.of(
                          context,
                        ).colorScheme.primaryContainer.withAlpha(150),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.data.album,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                ),
                              ),
                              Text(
                                widget.data.artist,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: SizedBox(
                          width: 30,
                          height: 30,
                          child: GeneralFilterMenu(
                            filter:
                                '(Album == "${widget.data.album.mpdEscape()}")',
                            style: IconButton.styleFrom(
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary.withAlpha(200),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
