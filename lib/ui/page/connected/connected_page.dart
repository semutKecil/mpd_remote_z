import 'dart:async';
import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mpd_remote_z/app_router.gr.dart';
import 'package:mpd_remote_z/main.dart';
import 'package:mpd_remote_z/service/general_audio_handler.dart';
import 'package:mpd_remote_z/service/stream_manager.dart';
import 'package:mpd_remote_z/ui/page/connected/bottom_mini_player.dart';
import 'package:mpd_remote_z/ui/page/connected/now_playing_page.dart';
import 'package:mpd_remote_z/ui/widget/drawer/drawer_menu.dart';

enum PageMode { portrait, big, landscape }

final miniPlayerShowStream = StreamManager<bool>(false);
final miniPlayerTapEvent = StreamManager<bool>(false);
final playerModeEvent = StreamManager<PageMode>(PageMode.portrait);
// final menuOpenEvent = StreamManager<bool>(false);

@RoutePage()
class ConnectedPage extends StatefulWidget {
  const ConnectedPage({super.key});

  @override
  State<ConnectedPage> createState() => _ConnectedPageState();
}

class _ConnectedPageState extends State<ConnectedPage> {
  Timer? _timer;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();

    _sub = audioService.customEvent.listen((value) {
      if (value == AudioHandlerEvent.preDisconnet) {
        _timer?.cancel();
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!playerState.connected ||
          (audioService.mediaItem.value == null &&
              audioService.mpdSong != null)) {
        _timer?.cancel();
        if (!mounted) return;
        AutoRouter.of(context).replace(
          LoaderRoute(
            onConnect: (context) {
              AutoRouter.of(context).replace(NowPlayingRoute());
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sub?.cancel();
    super.dispose();
  }

  final double breakpoint = 600;
  double _menuWidth = 300;

  @override
  Widget build(BuildContext context) {
    var padding = MediaQuery.paddingOf(context);
    var size = MediaQuery.sizeOf(context);
    var width = size.width;
    _menuWidth = width * .8;
    if (_menuWidth > 300) {
      _menuWidth = 300;
    }
    if (width < breakpoint) {
      playerModeEvent.emit(PageMode.portrait);
    } else {
      playerModeEvent.emit(PageMode.big);
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      drawer: DrawerMenu(),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: Platform.isAndroid || Platform.isIOS
              ? EdgeInsets.zero
              : EdgeInsets.only(top: 10, bottom: 10),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: width >= breakpoint
                      ? const EdgeInsets.symmetric(horizontal: 10)
                      : EdgeInsets.zero,
                  child: Column(
                    children: [
                      Expanded(child: SafeArea(child: const AutoRouter())),
                      width < breakpoint
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: BottomMiniPlayer(
                                paddingBottom: padding.bottom,
                                onTap: () async {
                                  await AutoRouter.of(
                                    context,
                                  ).replaceAll([NowPlayingRoute()]);
                                  miniPlayerTapEvent.emit(true);
                                },
                              ),
                            )
                          : SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
              width >= breakpoint
                  ? Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: SafeArea(
                        child: SizedBox(
                          width: size.height / 2.2,
                          height: size.height,
                          child: const PortraitPlayer(),
                        ),
                      ),
                    )
                  : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
