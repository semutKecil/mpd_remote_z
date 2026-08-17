import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:mpd_remote_z/main.dart';

class NowPlayingDescription extends StatefulWidget {
  final double scale;
  const NowPlayingDescription({super.key, this.scale = 1});

  @override
  State<NowPlayingDescription> createState() => _NowPlayingDescriptionState();
}

class _NowPlayingDescriptionState extends State<NowPlayingDescription> {
  StreamSubscription<MediaItem?>? _sub;
  String title = "";
  String description = "";

  @override
  void initState() {
    super.initState();
    title = audioService.mediaItem.value?.title ?? "Unknown";
    description = audioService.mediaItem.value?.displaySubtitle ?? "Unknown";
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _sub = audioService.mediaItem.listen((value) {
        if (title != (value?.title ?? "Unknown") ||
            description != (value?.displaySubtitle ?? "Unknown")) {
          setState(() {
            title = value?.title ?? "Unknown";
            description = value?.displaySubtitle ?? "Unknown";
          });
        }
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
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 1000),
      child: Column(
        key: ValueKey("desc-$title-$description"),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20 * widget.scale,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Text(
            description,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 16 * widget.scale),
          ),
        ],
      ),
    );
  }
}
