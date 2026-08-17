import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:mpd_remote_z/main.dart';
import 'package:mpd_remote_z/ui/widget/info/album_cover.dart';
import 'package:mpd_remote_z/ui/widget/playback/play_button.dart';
import 'package:mpd_remote_z/ui/widget/playback/playback_switch.dart';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  StreamSubscription<MediaItem?>? _sub;
  String title = "Unknown";
  String description = "Unknown";

  @override
  void initState() {
    super.initState();
    title = audioService.mediaItem.value?.title ?? "Unknown";
    description = audioService.mediaItem.value?.displaySubtitle ?? "Unknown";
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _sub = audioService.mediaItem.listen((value) {
        setState(() {
          title = value?.title ?? "Unknown";
          description = value?.displaySubtitle ?? "Unknown";
        });
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              children: [
                Center(child: AlbumCover()),
                PlayButton(
                  iconSize: 60,
                  backgroundColor: Colors.transparent,
                  iconColor: Theme.of(
                    context,
                  ).colorScheme.primary.withAlpha(200),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Text(description, overflow: TextOverflow.ellipsis),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: PlaybackSwitch(withSkipButton: true),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
