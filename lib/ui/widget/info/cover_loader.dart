import 'dart:async';
import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:mpd_remote_z/main.dart';

class CoverLoader extends StatefulWidget {
  final Widget Function(BuildContext context, File? file) builder;
  const CoverLoader({super.key, required this.builder});

  @override
  State<CoverLoader> createState() => _CoverLoaderState();
}

class _CoverLoaderState extends State<CoverLoader> {
  StreamSubscription<MediaItem?>? _sub;
  StreamSubscription<List<MediaItem>?>? _subQueue;
  File? artUri;

  @override
  void initState() {
    super.initState();

    var value = audioService.mediaItem.value;
    if (value?.artUri != null &&
        artUri?.uri != value?.artUri &&
        File.fromUri(value!.artUri!).existsSync()) {
      artUri = File.fromUri(value.artUri!);
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _sub = audioService.mediaItem.listen((value) {
        setState(() {
          if (value?.artUri != null &&
              artUri?.uri != value?.artUri &&
              File.fromUri(value!.artUri!).existsSync()) {
            artUri = File.fromUri(value.artUri!);
          }
        });
      });

      _subQueue = audioService.queue.listen((value) {
        if (value.isEmpty) {
          setState(() {
            artUri = null;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _subQueue?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, artUri);
  }
}
