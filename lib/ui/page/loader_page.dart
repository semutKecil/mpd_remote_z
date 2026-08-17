import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mpd_remote_z/app_router.gr.dart';
import 'package:mpd_remote_z/main.dart';
import 'package:mpd_remote_z/model/server_info.dart';
import 'package:mpd_remote_z/ui/widget/loading_display.dart';

@RoutePage()
class LoaderPage extends StatefulWidget {
  final FutureOr<void> Function(BuildContext context)? onConnect;
  const LoaderPage({super.key, this.onConnect});

  @override
  State<LoaderPage> createState() => _LoaderPageState();
}

class _LoaderPageState extends State<LoaderPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      var current = await ServerInfo.getCurrentServer();
      try {
        await audioService.custom.connect(current!);
        if (!mounted) return;
        widget.onConnect?.call(context);
      } catch (e, s) {
        debugPrint("error please select server");
        debugPrintStack(stackTrace: s, label: e.toString());
        if (!mounted) return;
        AutoRouter.of(
          context,
        ).replace(ServerListRoute(onConnect: widget.onConnect));
        return;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: LoadingDisplay()));
  }
}
