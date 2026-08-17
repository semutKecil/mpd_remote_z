import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:mpd_remote_z/main.dart';
import 'package:mpd_remote_z/service/u.dart';

class Seeker extends StatefulWidget {
  final double scale;
  const Seeker({super.key, this.scale = 1.0});

  @override
  State<Seeker> createState() => _SeekerState();
}

class _SeekerState extends State<Seeker> with SingleTickerProviderStateMixin {
  late final StreamSubscription<PlaybackState> _subPlayback;
  late final AnimationController _controller;
  late final Animation<double> _animation;
  double _sliderValue = 0.0;
  bool _sliderTouched = false;
  Duration _duration = Duration(milliseconds: 300000);
  Duration _position = Duration.zero;
  DateTime _updateTime = DateTime.now();
  int _dif = 0;

  late final Timer _syncData;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: _duration);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _subPlayback = audioService.playbackState.listen((value) {
      _sliderTouched = false;
      var durationState = audioService.mediaItem.value?.duration;
      if (durationState == null) {
        _controller.value = 0;
        _controller.stop();
        return;
      }

      if (!value.playing) {
        _controller.stop();
        return;
      }

      _duration = durationState;
      _controller.duration = _duration;
      _updateTime = value.updateTime;

      _position = value.position;
      _dif = DateTime.now().difference(_updateTime).inMilliseconds;

      updatePosition();
    });

    _syncData = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (!audioService.playbackState.value.playing) {
        _controller.stop();
        return;
      }
      syncSeeker();
    });
  }

  void updatePosition() {
    _controller.forward(
      from:
          (_position.inMilliseconds + _dif) /
          _duration.inMilliseconds.toDouble(),
    );
  }

  Future<void> syncSeeker() async {
    var nDif = DateTime.now().difference(_updateTime).inMilliseconds;
    if ((nDif - _dif).abs() > 300) {
      _dif = nDif;
      updatePosition();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _subPlayback.cancel();
    _syncData.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TickerMode(
      enabled: ModalRoute.of(context)?.isCurrent ?? true,

      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    Duration(
                      milliseconds:
                          (_duration.inMilliseconds.toDouble() *
                                  _controller.value)
                              .toInt(),
                    ).format(),
                    style: TextStyle(fontSize: 14 * widget.scale),
                  ),
                  const Spacer(),
                  CurrentSongDuration(scale: widget.scale),
                ],
              ),
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 4 * widget.scale,
                  thumbShape: RoundSliderThumbShape(
                    enabledThumbRadius: 12.0 * widget.scale,
                  ),
                ),
                child: Slider(
                  padding: EdgeInsets.only(
                    top: 5 * widget.scale,
                    bottom: 5 * widget.scale,
                    right: 10 * widget.scale,
                    left: 10 * widget.scale,
                  ),

                  value: _sliderTouched ? _sliderValue : _animation.value,
                  inactiveColor: Theme.of(context).colorScheme.primaryContainer,
                  onChanged: (value) {
                    if (_sliderTouched) {
                      setState(() {
                        _sliderValue = value;
                      });
                    }
                  },
                  onChangeStart: (value) =>
                      setState(() => _sliderTouched = true),
                  onChangeEnd: (value) {
                    audioService.seek(
                      Duration(
                        milliseconds:
                            (_duration.inMilliseconds.toDouble() * value)
                                .toInt(),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class CurrentSongDuration extends StatefulWidget {
  final double scale;
  const CurrentSongDuration({super.key, this.scale = 1.0});

  @override
  State<CurrentSongDuration> createState() => _CurrentSongDurationState();
}

class _CurrentSongDurationState extends State<CurrentSongDuration> {
  late final StreamSubscription<PlaybackState> _subPlayback;
  Duration _duration = Duration(milliseconds: 300000);

  @override
  void initState() {
    super.initState();
    _subPlayback = audioService.playbackState.listen((value) {
      var durationState = audioService.mediaItem.value?.duration;
      if (durationState == null) {
        return;
      }

      setState(() {
        _duration = durationState;
      });
    });
  }

  @override
  void dispose() {
    _subPlayback.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _duration.format(),
      style: TextStyle(fontSize: 14 * widget.scale),
    );
  }
}
