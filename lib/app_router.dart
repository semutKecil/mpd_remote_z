import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:mpd_remote_z/app_router.gr.dart';
import 'package:mpd_remote_z/main.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  // @override
  // RouteType get defaultRouteType => RouteType.adaptive();

  @override
  RouteType get defaultRouteType => RouteType.custom(
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Your custom slide-in/slide-out logic here
      return SlideTransition(
        position: animation.drive(
          Tween(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeInOut)),
        ),
        child: SlideTransition(
          position: secondaryAnimation.drive(
            Tween(
              begin: Offset.zero,
              end: const Offset(-1, 0),
            ).chain(CurveTween(curve: Curves.easeInOut)),
          ),
          child: child,
        ),
      );
    },
    duration: Duration(milliseconds: 300),
    reverseDuration: Duration(milliseconds: 300),
  );

  final AutoRouteGuard conCheck = AutoRouteGuard.simple((
    resolver,
    router,
  ) async {
    final connected = playerState.connected;
    if (connected) return resolver.next();
    return resolver.redirectUntil(
      LoaderRoute(onConnect: (context) => resolver.next()),
    );
  }); //.cupertino, .adaptive ..etc

  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: BackgroundRoute.page,
      path: '/',
      initial: true,
      children: [
        AutoRoute(page: ServerListRoute.page, path: 'servers'),
        AutoRoute(page: ConnectServerRoute.page, path: 'form'),
        AutoRoute(page: LoaderRoute.page, path: 'loader'),
        AutoRoute(
          page: ConnectedRoute.page,
          initial: true,
          path: 'connected',
          children: [
            AutoRoute(
              page: NowPlayingRoute.page,
              path: 'playing',
              initial: true,
            ),
            AutoRoute(page: FilesRoute.page, path: 'files/:parent'),
            AutoRoute(page: PlaylistRoute.page, path: 'playlists/:name'),
            AutoRoute(page: ArtistListRoute.page, path: 'artists'),
            AutoRoute(page: ArtistRoute.page, path: 'artists/:artist'),
            AutoRoute(page: AlbumListRoute.page, path: 'albums'),
            AutoRoute(page: AlbumRoute.page, path: 'albums/:album'),
            AutoRoute(page: SearchRoute.page, path: 'search/:tags'),
            AutoRoute(page: TagsListRoute.page, path: 'tags/:tag/:title'),
            AutoRoute(page: TagsRoute.page, path: 'tags/:tag/:title/:value'),
            AutoRoute(page: SettingsRoute.page, path: 'settings'),
            AutoRoute(page: PartitionRoute.page, path: 'settings/partitions'),
          ],
          guards: [conCheck],
        ),
      ],
    ),
  ];
}
