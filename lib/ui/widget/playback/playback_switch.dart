import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mpd_remote_z/main.dart';
import 'package:mpd_remote_z/mpd/model/mpd_consume_mode.dart';
import 'package:mpd_remote_z/mpd/model/mpd_random_mode.dart';
import 'package:mpd_remote_z/mpd/model/mpd_repeat_mode.dart';
import 'package:mpd_remote_z/mpd/model/mpd_single_mode.dart';
import 'package:mpd_remote_z/mpd/model/mpd_status.dart';
import 'package:mpd_remote_z/service/general_audio_handler.dart';

class PlaybackSwitch extends StatefulWidget {
  final bool stretch;
  final double buttonScale;
  final bool withSkipButton;
  const PlaybackSwitch({
    super.key,
    this.stretch = false,
    this.buttonScale = 1,
    this.withSkipButton = false,
  });

  @override
  State<PlaybackSwitch> createState() => _PlaybackSwitchState();
}

class _PlaybackSwitchState extends State<PlaybackSwitch> {
  late final StreamSubscription _sub;
  MpdStatus? mpdStatus;

  @override
  void initState() {
    super.initState();
    mpdStatus = audioService.mpdStatus;
    _sub = audioService.customEvent.listen((value) {
      if (value == AudioHandlerEvent.statusUpdate && mounted) {
        setState(() {
          mpdStatus = audioService.mpdStatus;
        });
      }
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var items = [
      IconButton(
        iconSize: 16,
        onPressed: () => audioService.custom.toggleRandom(),
        color: mpdStatus?.random == MpdRandomMode.off
            ? Theme.of(context).colorScheme.onSurface
            : Theme.of(context).colorScheme.onPrimary,
        style: IconButton.styleFrom(
          visualDensity: VisualDensity.compact,
          backgroundColor: mpdStatus?.random == MpdRandomMode.off
              ? Theme.of(context).colorScheme.surfaceDim.withAlpha(120)
              : Theme.of(context).colorScheme.primary,
        ),
        icon: Icon(Icons.shuffle),
      ),
      IconButton(
        iconSize: 16,
        onPressed: () => audioService.custom.toggleRepeat(),
        color: mpdStatus?.repeat == MpdRepeatMode.off
            ? Theme.of(context).colorScheme.onSurface
            : Theme.of(context).colorScheme.onPrimary,
        style: IconButton.styleFrom(
          visualDensity: VisualDensity.compact,
          backgroundColor: mpdStatus?.repeat == MpdRepeatMode.off
              ? Theme.of(context).colorScheme.surfaceDim.withAlpha(120)
              : Theme.of(context).colorScheme.primary,
        ),
        icon: Icon(Icons.repeat),
      ),
      Stack(
        children: [
          IconButton(
            iconSize: 16,
            onPressed: () => audioService.custom.toggleSingle(),
            color: mpdStatus?.single == MpdSingleMode.off
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).colorScheme.onPrimary,
            style: IconButton.styleFrom(
              visualDensity: VisualDensity.compact,
              backgroundColor: mpdStatus?.single == MpdSingleMode.off
                  ? Theme.of(context).colorScheme.surfaceDim.withAlpha(120)
                  : Theme.of(context).colorScheme.primary,
            ),
            icon: Icon(Icons.looks_one_outlined),
          ),
          mpdStatus?.single == MpdSingleMode.oneshot
              ? Positioned(
                  top: 0,
                  right: 0,
                  child: SizedBox(
                    width: 15,
                    height: 15,
                    child: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(context).colorScheme.onError,

                      child: Text("1", style: TextStyle(fontSize: 10)),
                    ),
                  ),
                )
              : SizedBox.shrink(),
        ],
      ),
      Stack(
        children: [
          IconButton(
            iconSize: 16,
            onPressed: () => audioService.custom.toggleConsume(),
            color: mpdStatus?.consume == MpdConsumeMode.off
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).colorScheme.onPrimary,
            style: IconButton.styleFrom(
              visualDensity: VisualDensity.compact,
              backgroundColor: mpdStatus?.consume == MpdConsumeMode.off
                  ? Theme.of(context).colorScheme.surfaceDim.withAlpha(120)
                  : Theme.of(context).colorScheme.primary,
            ),
            icon: Icon(Icons.playlist_remove),
          ),
          mpdStatus?.consume == MpdConsumeMode.oneshot
              ? Positioned(
                  top: 0,
                  right: 0,
                  child: SizedBox(
                    width: 15,
                    height: 15,
                    child: CircleAvatar(
                      child: Text("1", style: TextStyle(fontSize: 10)),
                    ),
                  ),
                )
              : SizedBox.shrink(),
        ],
      ),
    ];

    if (widget.withSkipButton) {
      items = [
        ...[
          IconButton(
            iconSize: 16,
            onPressed: () => audioService.skipToPrevious(),
            color: Theme.of(context).colorScheme.onSurface,
            style: IconButton.styleFrom(
              visualDensity: VisualDensity.compact,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceDim.withAlpha(120),
            ),
            icon: Icon(Icons.skip_previous),
          ),
          IconButton(
            iconSize: 16,
            onPressed: () => audioService.skipToNext(),
            color: Theme.of(context).colorScheme.onSurface,
            style: IconButton.styleFrom(
              visualDensity: VisualDensity.compact,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceDim.withAlpha(120),
            ),
            icon: Icon(Icons.skip_next),
          ),
        ],
        ...items,
      ];
    }
    return Row(
      mainAxisSize: widget.stretch ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: widget.stretch
          ? MainAxisAlignment.spaceEvenly
          : MainAxisAlignment.center,
      spacing: widget.stretch ? 0 : 8,

      children: items,
    );
  }
}
