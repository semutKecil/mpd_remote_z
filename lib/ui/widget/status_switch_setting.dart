import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mpd_remote_z/main.dart';
import 'package:mpd_remote_z/mpd/model/mpd_status.dart';
import 'package:mpd_remote_z/service/general_audio_handler.dart';
import 'package:mpd_remote_z/ui/widget/tile/list_tile_default.dart';

class StatusSwitchSetting extends StatefulWidget {
  final Widget title;
  final bool Function(MpdStatus status) condition;
  final FutureOr<void> Function(bool value) action;
  final Widget leading;
  const StatusSwitchSetting({
    super.key,
    required this.title,
    required this.condition,
    required this.action,
    required this.leading,
  });

  @override
  State<StatusSwitchSetting> createState() => _StatusSwitchSettingState();
}

class _StatusSwitchSettingState extends State<StatusSwitchSetting> {
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
        // statusChange();
      }
    });
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) => statusChange());
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  // void statusChange() async {
  //   mpdStatus = audioService.mpdStatus;
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    return ListTileDefault(
      leading: widget.leading,
      title: widget.title,
      onTap: () {
        widget.action(mpdStatus == null ? false : widget.condition(mpdStatus!));
      },
      trailing: Switch(
        value: mpdStatus == null ? false : widget.condition(mpdStatus!),
        onChanged: (value) {
          widget.action(value);
        },
      ),
    );
  }
}
