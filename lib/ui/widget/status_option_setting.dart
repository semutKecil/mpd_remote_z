import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mpd_remote_z/main.dart';
import 'package:mpd_remote_z/mpd/model/mpd_status.dart';
import 'package:mpd_remote_z/service/general_audio_handler.dart';
import 'package:mpd_remote_z/ui/widget/tile/list_tile_default.dart';

class StatusOptionSetting<T> extends StatefulWidget {
  final Widget title;
  final FutureOr<T> Function(MpdStatus status) condition;
  final FutureOr<void> Function(T value) action;
  final Map<T, String> options;
  final Widget leading;
  const StatusOptionSetting({
    super.key,
    required this.title,
    required this.condition,
    required this.action,
    required this.leading,
    required this.options,
  });

  @override
  State<StatusOptionSetting<T>> createState() => _StatusOptionSettingState<T>();
}

class _StatusOptionSettingState<T> extends State<StatusOptionSetting<T>> {
  late final StreamSubscription _sub;
  MpdStatus? mpdStatus;

  String? _initialValue;

  @override
  void initState() {
    super.initState();
    _sub = audioService.customEvent.listen((value) {
      if (value == AudioHandlerEvent.statusUpdate) {
        statusChange();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => statusChange());
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  void statusChange() async {
    mpdStatus = audioService.mpdStatus;
    _initialValue = mpdStatus == null
        ? widget.options.entries.first.value
        : widget.options[await widget.condition(mpdStatus!)] ??
              widget.options.entries.first.value;

    if (mounted && context.mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListTileDefault(
      leading: widget.leading,
      title: widget.title,
      trailing: PopupMenuButton<T>(
        color: Theme.of(context).colorScheme.primaryContainer,
        elevation: 10,
        child: Row(
          spacing: 10,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _initialValue ?? widget.options.entries.first.value,
              textAlign: TextAlign.start,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            Icon(Icons.arrow_drop_down),
          ],
        ),
        onSelected: (value) => widget.action(value),
        itemBuilder: (context) => widget.options.entries.map((e) {
          return PopupMenuItem<T>(
            value: e.key,
            child: Text(
              e.value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
