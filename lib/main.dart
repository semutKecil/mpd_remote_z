import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mpd_remote_z/app_router.dart';
import 'package:mpd_remote_z/model/player_state.dart';
import 'package:mpd_remote_z/service/general_audio_handler.dart';
import 'package:mpd_remote_z/service/media_item_ext.dart';
import 'package:orient_text_field/orient_text_field.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';

late final GeneralAudioHandler audioService;
// final String defaultCoverHash = "4acbeb00e646d1dcb58f695810d43737";
final String defaultCoverHash = "21ede6060ba419fdc565cfdf8b231971";
late final ColorScheme defaultColorScheme;
PlayerState playerState = PlayerState(connected: false);

// Photo by <a href="https://unsplash.com/@omilaev?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Igor Omilaev</a> on <a href="https://unsplash.com/photos/a-pair-of-headphones-hanging-from-a-wall-DDTOKmL1ykA?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>

// dart run lean_builder build
void main() async {
  audioService = await AudioService.init(
    builder: () => GeneralAudioHandler(),
    config: AudioServiceConfig(
      androidNotificationChannelId:
          'com.github.semutkecil.mpd_remote_z.channel.audio',
      androidNotificationChannelName: 'Music playback',
    ),
  );
  final docDir = await getApplicationSupportDirectory();
  final file = File('${docDir.path}/$defaultCoverHash');

  if (!File('${docDir.path}/$defaultCoverHash').existsSync()) {
    final byteData = await rootBundle.load('assets/images/default-cover2.png');
    final buffer = byteData.buffer;
    await file.writeAsBytes(
      buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
      flush: true,
    );
    await FileImage(file).evict();
    if (Platform.isWindows) {
      await Future.delayed(Duration(milliseconds: 200));
    }
  }

  defaultColorScheme = await ColorScheme.fromImageProvider(
    provider: FileImage(file),
    brightness: Brightness.dark,
  );

  if (!Platform.isAndroid) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = WindowOptions(
      size: Size(800, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      windowButtonVisibility: true,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final StreamSubscription<dynamic> _subEvent;
  late final StreamSubscription<MediaItem?> _subMediaItem;
  ColorScheme _colorScheme = defaultColorScheme;
  Uri? _artUri;

  @override
  void initState() {
    super.initState();
    _subEvent = audioService.customEvent.listen((value) {
      if (value == AudioHandlerEvent.disconnet) {
        playerState = PlayerState(connected: false);
      } else if (value == AudioHandlerEvent.connect) {
        playerState = PlayerState(connected: true);
      }
    });
    _artUri = audioService.mediaItem.value?.artUri;
    _colorScheme =
        audioService.mediaItem.value?.colorScheme ?? defaultColorScheme;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _subMediaItem = audioService.mediaItem.listen((value) async {
        if (value?.artUri != null &&
            _artUri != value?.artUri &&
            mounted &&
            context.mounted) {
          setState(() {
            _artUri = value?.artUri;
            _colorScheme = value!.colorScheme ?? defaultColorScheme;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _subMediaItem.cancel();
    _subEvent.cancel();
    super.dispose();
  }

  final _appRouter = AppRouter();

  ThemeData _buildTheme(ColorScheme colorScheme) {
    return ThemeData(
      colorScheme: _colorScheme,
      fontFamily: 'sans serif',
      useMaterial3: true,
      listTileTheme: ListTileThemeData(
        selectedTileColor: _colorScheme.primary.withAlpha(30),
        titleTextStyle: TextStyle(color: _colorScheme.primary, fontSize: 16),
        iconColor: _colorScheme.primary,
        contentPadding: EdgeInsets.only(left: 16, right: 16),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: _colorScheme.onSurface,
        actionsPadding: EdgeInsets.only(right: 10),
        scrolledUnderElevation: 0,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _colorScheme.onSurface.withAlpha(50),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: _colorScheme.primaryContainer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardStatusProvider(
      child: MaterialApp.router(
        title: 'MPD Remote',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(_colorScheme),
        routerConfig: _appRouter.config(
          navigatorObservers: () => [AutoRouteObserver()],
        ),
      ),
    );
  }
}
