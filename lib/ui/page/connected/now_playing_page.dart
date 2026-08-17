import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mpd_remote_z/main.dart';
import 'package:mpd_remote_z/ui/page/connected/connected_page.dart';
import 'package:mpd_remote_z/ui/widget/info/album_cover.dart';
import 'package:mpd_remote_z/ui/widget/info/now_playing_description.dart';
import 'package:mpd_remote_z/ui/widget/playback/play_button.dart';
import 'package:mpd_remote_z/ui/widget/playback/player_controller_button.dart';
import 'package:mpd_remote_z/ui/widget/queue_sliver.dart';
import 'package:mpd_remote_z/ui/widget/playback/seeker.dart';
import 'package:mpd_remote_z/ui/widget/playback/playback_switch.dart';
import 'package:mpd_remote_z/ui/widget/dialog/volume_knob_dialog.dart';

@RoutePage()
class NowPlayingPage extends StatefulWidget {
  const NowPlayingPage({super.key});

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage> with AutoRouteAware {
  final ScrollController _scrollController = ScrollController();
  bool _overScroll = false;
  AutoRouteObserver? _observer;
  StreamSubscription<bool>? _subMiniPlayerTap;
  StreamSubscription<PageMode>? _subPageMode;
  // double? _height;
  // PageMode _playerMode = PageMode.portrait;
  bool _active = true;

  @override
  void initState() {
    super.initState();

    _subMiniPlayerTap = miniPlayerTapEvent.stream.listen((event) {
      if (_active) {
        var duration = (_scrollController.position.pixels / 100).ceil() * 15;
        _scrollController.animateTo(
          0,
          duration: Duration(milliseconds: duration),
          curve: Curves.easeIn,
        );
      }
    });
    // playerModeEvent.stream.listen((value) {
    //   if (mounted == false) return;
    //   if (context.mounted == false) return;
    //   // setState(() {});
    // });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _scrollController.addListener(_scrollListener);
      // if (audioService.mediaItem.value == null &&
      //     audioService.mpdSong != null) {
      //   //need reload
      // }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Daftarkan halaman ini ke observer milik AutoRoute
    _observer = RouterScope.of(
      context,
    ).firstObserverOfType<AutoRouteObserver>();
    if (_observer != null) {
      _observer!.subscribe(this, context.routeData);
    }
  }

  void _scrollListener() {
    double currentScroll = _scrollController.position.pixels;
    double halfScreen = _scrollController.position.viewportDimension / 2;
    if (currentScroll >= halfScreen && !miniPlayerShowStream.value) {
      miniPlayerShowStream.emit(true);
      _overScroll = true;
    } else if (currentScroll < halfScreen && miniPlayerShowStream.value) {
      miniPlayerShowStream.emit(false);
      _overScroll = false;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _observer?.unsubscribe(this);
    _subPageMode?.cancel();
    _subMiniPlayerTap?.cancel();
    super.dispose();
  }

  @override
  void didPushNext() {
    if (!miniPlayerShowStream.value) miniPlayerShowStream.emit(true);
    _active = false;
  }

  @override
  void didPopNext() {
    if (!_overScroll && miniPlayerShowStream.value) {
      miniPlayerShowStream.emit(false);
    }
    _active = true;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          backgroundColor: Colors.transparent,
          title: const Text("Now Playing"),
          actions: [
            IconButton(
              onPressed: () async {
                VolumeKnobDialog.show(context);
              },
              icon: Icon(Icons.volume_up),
            ),
          ],
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              var height = constraints.maxHeight;
              var width = constraints.maxWidth;
              return CustomScrollView(
                controller: _scrollController,
                slivers: [
                  playerModeEvent.value == PageMode.portrait
                      ? SliverAppBar(
                          expandedHeight: height,
                          pinned: false,
                          forceMaterialTransparency: true,
                          automaticallyImplyLeading: false,
                          flexibleSpace: FlexibleSpaceBar(
                            collapseMode: CollapseMode.parallax,
                            expandedTitleScale: 1,
                            background: SizedBox(
                              height: height,
                              width: width,
                              child: const PortraitPlayer(),
                            ),
                          ),
                        )
                      : SliverToBoxAdapter(child: SizedBox.shrink()),
                  // const SliverToBoxAdapter(
                  //   child: Padding(
                  //     padding: EdgeInsets.symmetric(horizontal: 20),
                  //     child: Divider(),
                  //   ),
                  // ),
                  QueueSliver(),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class PortraitPlayer extends StatelessWidget {
  const PortraitPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        var height = constraints.maxHeight;
        var width = constraints.maxWidth;
        var usedWidth = width;
        var scale = 1.0;
        if (height < 600) {
          scale = height / 600;
        }

        if (usedWidth / height > 0.5) {
          usedWidth = height / 2;
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: usedWidth,
              child: Column(
                children: [
                  // const Spacer(flex: 1),
                  Card(
                    elevation: 5,
                    clipBehavior: Clip.antiAlias,
                    child: SizedBox(
                      width: usedWidth * 0.9,
                      height: usedWidth * 0.9,
                      child: const AlbumCover(),
                    ),
                  ),
                  const Spacer(flex: 2),
                  SizedBox(
                    width: usedWidth * 0.9,
                    child: NowPlayingDescription(scale: scale),
                  ),
                  const Spacer(flex: 2),
                  SizedBox(
                    width: usedWidth * 0.6,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: const PlaybackSwitch(),
                    ),
                  ),
                  const Spacer(flex: 2),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Seeker(scale: scale),
                  ),
                  const Spacer(flex: 2),
                  SizedBox(
                    width: usedWidth * 0.8,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        spacing: 10,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          PlayerControllerButton(
                            onPressed: () => audioService.skipToPrevious(),
                            icon: Icons.skip_previous_rounded,
                          ),
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: PlayButton(iconSize: 60),
                          ),
                          PlayerControllerButton(
                            onPressed: () => audioService.skipToNext(),
                            icon: Icons.skip_next_rounded,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
