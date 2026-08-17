import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mpd_remote_z/main.dart';
import 'package:mpd_remote_z/mpd/model/mpd_status.dart';
import 'package:mpd_remote_z/service/general_audio_handler.dart';
import 'package:mpd_remote_z/ui/widget/input_setting.dart';

class StatusInputSetting extends StatefulWidget {
  final String titleText;
  final Widget leading;
  final String Function(MpdStatus status) condition;
  final FutureOr<void> Function(String value) action;
  final String? prefixText;
  final String? suffixText;
  final String? initialValue;
  final TextInputType? keyboardType;
  final String? Function(String? value)? validator;
  const StatusInputSetting({
    super.key,
    required this.titleText,
    required this.leading,
    required this.condition,
    required this.action,
    this.prefixText,
    this.suffixText,
    this.initialValue,
    this.keyboardType,
    this.validator,
  });

  @override
  State<StatusInputSetting> createState() => _StatusInputSettingState();
}

class _StatusInputSettingState extends State<StatusInputSetting> {
  late final StreamSubscription _sub;
  MpdStatus? mpdStatus;

  @override
  void initState() {
    super.initState();
    mpdStatus = audioService.mpdStatus;
    _sub = audioService.customEvent.listen((value) {
      if (value == AudioHandlerEvent.statusUpdate) {
        if (!mounted) return;
        mpdStatus = audioService.mpdStatus;
      }
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  // void statusChange() async {
  //   mpdStatus = await audioService.custom.mpdStatus();
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    return InputSetting(
      titleText: widget.titleText,
      leading: widget.leading,
      initialValue: mpdStatus == null ? "" : widget.condition(mpdStatus!),
      prefixText: widget.prefixText,
      suffixText: widget.suffixText,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      onChanged: (value) {
        widget.action(value);
      },
    );
  }
}
