import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mpd_remote_z/main.dart';

class PlayButton extends StatefulWidget {
  final double iconSize;
  final Color? iconColor;
  final Color? backgroundColor;
  const PlayButton({
    super.key,
    this.iconSize = 60,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  State<PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<PlayButton>
    with SingleTickerProviderStateMixin {
  late final StreamSubscription _sub;
  late AnimationController _controller;
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _sub = audioService.playbackState.listen((value) {
      setState(() {
        _playing = value.playing;
      });

      if (_playing) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: IconButton(
        icon: AnimatedIcon(
          icon: AnimatedIcons.play_pause,
          progress: _controller,
        ),
        // icon: _playing ? const Icon(Icons.pause) : const Icon(Icons.play_arrow),
        color:
            widget.iconColor ?? Theme.of(context).colorScheme.primaryContainer,
        iconSize: widget.iconSize,
        style: IconButton.styleFrom(
          backgroundColor:
              widget.backgroundColor ??
              Theme.of(context).colorScheme.primaryFixed,
        ),
        onPressed: () => _playing ? audioService.pause() : audioService.play(),
      ),
    );
  }
}
