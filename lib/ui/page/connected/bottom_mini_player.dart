import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mpd_remote_z/ui/page/connected/connected_page.dart';
import 'package:mpd_remote_z/ui/widget/playback/mini_player.dart';

class BottomMiniPlayer extends StatefulWidget {
  final double paddingBottom;
  final VoidCallback onTap;
  const BottomMiniPlayer({
    super.key,
    required this.paddingBottom,
    required this.onTap,
  });

  @override
  State<BottomMiniPlayer> createState() => _BottomMiniPlayerState();
}

class _BottomMiniPlayerState extends State<BottomMiniPlayer> {
  bool _isOpen = false;
  StreamSubscription<bool>? _subShowMini;

  @override
  void initState() {
    super.initState();
    _subShowMini = miniPlayerShowStream.stream.listen((value) {
      if (mounted && context.mounted) {
        setState(() {
          _isOpen = value;
        });
      }
    });
  }

  @override
  void dispose() {
    _subShowMini?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Material(
        color: Colors.transparent,
        child: AnimatedAlign(
          alignment: Alignment.topCenter,
          duration: const Duration(milliseconds: 500),
          heightFactor: _isOpen ? 1.0 : 0.0,
          curve: Curves.fastOutSlowIn,
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 500),
            offset: _isOpen ? Offset.zero : const Offset(0, 1),
            curve: Curves.easeOutCubic,
            child: ClipRRect(
              borderRadius: BorderRadiusGeometry.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                height: 110,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 10,
                    left: 10,
                    right: 10,
                    bottom: widget.paddingBottom,
                  ),
                  child: MiniPlayer(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
