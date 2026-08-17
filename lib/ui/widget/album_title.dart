import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mpd_remote_z/main.dart';
import 'package:mpd_remote_z/model/song_art.dart';
import 'package:mpd_remote_z/mpd/model/mpd_count.dart';
import 'package:mpd_remote_z/mpd/model/mpd_song.dart';
import 'package:mpd_remote_z/mpd/string_ext.dart';
import 'package:mpd_remote_z/service/u.dart';
import 'package:path_provider/path_provider.dart';

class AlbumTitle extends StatefulWidget {
  final MpdSong song;
  const AlbumTitle({super.key, required this.song});

  @override
  State<AlbumTitle> createState() => _AlbumTitleState();
}

class _AlbumTitleState extends State<AlbumTitle> {
  File? art;
  MpdCount? count;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      loadData();
    });
    loadData();
  }

  Future<void> loadData() async {
    count = (await audioService.custom.count(
      '(Album == "${widget.song.album.mpdEscape()}")',
    )).first;

    if (!mounted) return;
    setState(() {});
    final docDir = await getApplicationSupportDirectory();
    art = File('${docDir.path}/$defaultCoverHash');
    var loadedArt = await ((await SongArt.findByData(song: widget.song))?.uri);

    if (loadedArt != null && mounted) {
      art = File.fromUri(loadedArt);
    } else {
      art = File('${docDir.path}/$defaultCoverHash');
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: .3,
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 1000),
                child: art == null
                    ? const SizedBox.shrink()
                    : SizedBox(
                        key: ValueKey("bg-${art!.path}"),
                        width: double.infinity,
                        height: double.infinity,
                        child: Image.file(art!, fit: BoxFit.cover),
                      ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                height: 120,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    spacing: 10,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadiusGeometry.circular(10),
                        child: SizedBox(
                          width: 100,
                          height: 100,
                          child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 1000),
                            child: art == null
                                ? const SizedBox.shrink()
                                : SizedBox(
                                    key: ValueKey("bg-${art!.path}"),
                                    width: double.infinity,
                                    height: double.infinity,
                                    child: Image.file(
                                      key: ValueKey("cov-${art!.path}"),
                                      art!,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              overflow: TextOverflow.ellipsis,
                              "Artist: ${widget.song.albumArtist}",
                            ),
                            count == null
                                ? const SizedBox.shrink()
                                : Text("Songs: ${count!.songs}"),
                            count == null
                                ? const SizedBox.shrink()
                                : Text("Duration: ${count!.duration.format()}"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
