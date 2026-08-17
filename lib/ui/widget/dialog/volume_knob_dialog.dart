import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:mpd_remote_z/main.dart';
import 'package:mpd_remote_z/ui/widget/simple_circular_slider.dart';

class VolumeKnobDialog extends StatelessWidget {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      useRootNavigator: false,
      barrierColor: Colors.black.withAlpha(200),
      builder: (BuildContext context) {
        return Center(
          child: Material(
            color: Colors.transparent, // transparent background
            child: VolumeKnobDialog(),
          ),
        );
      },
    );
  }

  const VolumeKnobDialog({super.key});

  @override
  Widget build(BuildContext context) {
    var volume =
        (audioService.androidPlaybackInfo.value as RemoteAndroidPlaybackInfo)
            .volume
            .toDouble();

    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.primaryContainer.withAlpha(80),
      ),
      child: SimpleCircularSlider(
        min: 0,
        max: 100,
        divisions: 100,
        initialValue: volume,
        onChangedEnd: (value) {
          audioService.androidSetRemoteVolume(value.toInt());
        },
        builder: (context, value) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                value == 0
                    ? Icons.volume_off
                    : value > 40
                    ? Icons.volume_up
                    : Icons.volume_down,
                size: 42,
                color: Theme.of(context).colorScheme.primary,
              ),
              Text(
                "${value.toStringAsFixed(0)} %",
                style: TextStyle(
                  fontSize: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
