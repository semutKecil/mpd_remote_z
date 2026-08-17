import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mpd_remote_z/main.dart';
import 'package:mpd_remote_z/mpd/model/mpd_song.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mpd_remote_z/service/u.dart';

class SongArt {
  final String key;
  final String hash;
  final ColorScheme colorScheme;

  SongArt({required this.key, required this.hash, required this.colorScheme});

  Future<Uri> get uri async {
    final directory = await getApplicationSupportDirectory();
    return File('${directory.path}/$hash').uri;
  }

  static Future<SongArt?> saveWithDefault({required MpdSong song}) async {
    var songArt = SongArt(
      key: song.artId,
      hash: defaultCoverHash,
      colorScheme: defaultColorScheme,
    );
    SharedPreferencesAsync prefs = SharedPreferencesAsync();
    await prefs.setStringList(
      "artDb",
      (await prefs.getStringList("artDb") ?? [])..add(jsonEncode(songArt)),
    );
    return songArt;
  }

  static Future<SongArt> create({
    required MpdSong song,
    required Uint8List bytes,
  }) async {
    var exist = await findByData(song: song);
    SharedPreferencesAsync prefs = SharedPreferencesAsync();
    if (exist != null) {
      var uri = await exist.uri;
      if (File.fromUri(uri).existsSync()) {
        return exist;
      } else {
        await prefs.setStringList(
          "artDb",
          (await prefs.getStringList("artDb") ?? []).where((element) {
            return SongArt.fromJson(jsonDecode(element)).key != exist.key;
          }).toList(),
        );
      }
      // return exist;
    }

    final hash = bytes.hash();
    final directory = await getApplicationSupportDirectory();
    final file = File('${directory.path}/$hash');
    if (!await file.exists()) {
      await file.writeAsBytes(bytes, flush: true);
      await FileImage(file).evict();
      if (Platform.isWindows) {
        await Future.delayed(Duration(milliseconds: 200));
      }
    }
    var songArt = SongArt(
      key: song.artId,
      hash: hash,
      colorScheme: await ColorScheme.fromImageProvider(
        provider: FileImage(file),
        brightness: Brightness.dark,
      ),
    );

    // var coverArt = await prefs.getStringList("artDb");

    await prefs.setStringList(
      "artDb",
      (await prefs.getStringList("artDb") ?? [])..add(jsonEncode(songArt)),
    );

    // await prefs.setString(
    //   "SongArt",
    //   jsonEncode((await findAll())..add(songArt)),
    // );
    return songArt;
  }

  factory SongArt.fromJson(Map<String, dynamic> json) {
    return SongArt(
      key: json['key'],
      hash: json['hash'],
      colorScheme: ColorSchemeExt.fromJson(json['colorScheme']),
    );
  }

  Map<String, dynamic> toJson() => {
    'key': key,
    'hash': hash,
    "colorScheme": colorScheme.toJson(),
  };

  static Future<List<SongArt>> findAll() async {
    SharedPreferencesAsync prefs = SharedPreferencesAsync();
    var artsDb = await prefs.getStringList("artDb");
    if (artsDb != null) {
      try {
        return artsDb.map((e) => SongArt.fromJson(jsonDecode(e))).toList();
      } catch (e, s) {
        debugPrintStack(stackTrace: s, label: e.toString());
        return [];
      }
    }
    return [];
  }

  static Future<SongArt?> findByData({required MpdSong song}) async {
    List<SongArt> db = await findAll();
    var exist = db.where((e) => e.key == song.artId).firstOrNull;
    if (exist == null) return null;
    return exist;
  }
}

extension ColorSchemeExt on ColorScheme {
  static ColorScheme fromJson(Map<String, dynamic> json) {
    return ColorScheme(
      brightness: Brightness.values[json['brightness']],
      primary: Color(json['primary']),
      onPrimary: Color(json['onPrimary']),
      primaryContainer: json['primaryContainer'] == null
          ? null
          : Color(json['primaryContainer']),
      onPrimaryContainer: json['onPrimaryContainer'] == null
          ? null
          : Color(json['onPrimaryContainer']),
      primaryFixed: json['primaryFixed'] == null
          ? null
          : Color(json['primaryFixed']),
      primaryFixedDim: json['primaryFixedDim'] == null
          ? null
          : Color(json['primaryFixedDim']),
      onPrimaryFixed: json['onPrimaryFixed'] == null
          ? null
          : Color(json['onPrimaryFixed']),
      onPrimaryFixedVariant: json['onPrimaryFixedVariant'] == null
          ? null
          : Color(json['onPrimaryFixedVariant']),
      secondary: Color(json['secondary']),
      onSecondary: Color(json['onSecondary']),
      secondaryContainer: json['secondaryContainer'] == null
          ? null
          : Color(json['secondaryContainer']),
      onSecondaryContainer: json['onSecondaryContainer'] == null
          ? null
          : Color(json['onSecondaryContainer']),
      secondaryFixed: json['secondaryFixed'] == null
          ? null
          : Color(json['secondaryFixed']),
      secondaryFixedDim: json['secondaryFixedDim'] == null
          ? null
          : Color(json['secondaryFixedDim']),
      onSecondaryFixed: json['onSecondaryFixed'] == null
          ? null
          : Color(json['onSecondaryFixed']),
      onSecondaryFixedVariant: json['onSecondaryFixedVariant'] == null
          ? null
          : Color(json['onSecondaryFixedVariant']),
      tertiary: json['tertiary'] == null ? null : Color(json['tertiary']),
      onTertiary: json['onTertiary'] == null ? null : Color(json['onTertiary']),
      tertiaryContainer: json['tertiaryContainer'] == null
          ? null
          : Color(json['tertiaryContainer']),
      onTertiaryContainer: json['onTertiaryContainer'] == null
          ? null
          : Color(json['onTertiaryContainer']),
      tertiaryFixed: json['tertiaryFixed'] == null
          ? null
          : Color(json['tertiaryFixed']),
      tertiaryFixedDim: json['tertiaryFixedDim'] == null
          ? null
          : Color(json['tertiaryFixedDim']),
      onTertiaryFixed: json['onTertiaryFixed'] == null
          ? null
          : Color(json['onTertiaryFixed']),
      onTertiaryFixedVariant: json['onTertiaryFixedVariant'] == null
          ? null
          : Color(json['onTertiaryFixedVariant']),
      error: Color(json['error']),
      onError: Color(json['onError']),
      errorContainer: json['errorContainer'] == null
          ? null
          : Color(json['errorContainer']),
      onErrorContainer: json['onErrorContainer'] == null
          ? null
          : Color(json['onErrorContainer']),
      surface: Color(json['surface']),
      onSurface: Color(json['onSurface']),
      surfaceDim: json['surfaceDim'] == null ? null : Color(json['surfaceDim']),
      surfaceBright: json['surfaceBright'] == null
          ? null
          : Color(json['surfaceBright']),
      surfaceContainerLowest: json['surfaceContainerLowest'] == null
          ? null
          : Color(json['surfaceContainerLowest']),
      surfaceContainerLow: json['surfaceContainerLow'] == null
          ? null
          : Color(json['surfaceContainerLow']),
      surfaceContainer: json['surfaceContainer'] == null
          ? null
          : Color(json['surfaceContainer']),
      surfaceContainerHigh: json['surfaceContainerHigh'] == null
          ? null
          : Color(json['surfaceContainerHigh']),
      surfaceContainerHighest: json['surfaceContainerHighest'] == null
          ? null
          : Color(json['surfaceContainerHighest']),
      onSurfaceVariant: json['onSurfaceVariant'] == null
          ? null
          : Color(json['onSurfaceVariant']),
      outline: json['outline'] == null ? null : Color(json['outline']),
      outlineVariant: json['outlineVariant'] == null
          ? null
          : Color(json['outlineVariant']),
      shadow: json['shadow'] == null ? null : Color(json['shadow']),
      scrim: json['scrim'] == null ? null : Color(json['scrim']),
      inverseSurface: json['inverseSurface'] == null
          ? null
          : Color(json['inverseSurface']),
      onInverseSurface: json['onInverseSurface'] == null
          ? null
          : Color(json['onInverseSurface']),
      inversePrimary: json['inversePrimary'] == null
          ? null
          : Color(json['inversePrimary']),
      surfaceTint: json['surfaceTint'] == null
          ? null
          : Color(json['surfaceTint']),
      // background: json['background'] == null ? null : Color(json['background']),
      // onBackground: json['onBackground'] == null
      //     ? null
      //     : Color(json['onBackground']),
      // surfaceVariant: json['surfaceVariant'] == null
      //     ? null
      //     : Color(json['surfaceVariant']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "brightness": brightness.index,
      "primary": primary.toARGB32(),
      "onPrimary": onPrimary.toARGB32(),
      "primaryContainer": primaryContainer.toARGB32(),
      "onPrimaryContainer": onPrimaryContainer.toARGB32(),
      "primaryFixed": primaryFixed.toARGB32(),
      "primaryFixedDim": primaryFixedDim.toARGB32(),
      "onPrimaryFixed": onPrimaryFixed.toARGB32(),
      "onPrimaryFixedVariant": onPrimaryFixedVariant.toARGB32(),
      "secondary": secondary.toARGB32(),
      "onSecondary": onSecondary.toARGB32(),
      "secondaryContainer": secondaryContainer.toARGB32(),
      "onSecondaryContainer": onSecondaryContainer.toARGB32(),
      "secondaryFixed": secondaryFixed.toARGB32(),
      "secondaryFixedDim": secondaryFixedDim.toARGB32(),
      "onSecondaryFixed": onSecondaryFixed.toARGB32(),
      "onSecondaryFixedVariant": onSecondaryFixedVariant.toARGB32(),
      "tertiary": tertiary.toARGB32(),
      "onTertiary": onTertiary.toARGB32(),
      "tertiaryContainer": tertiaryContainer.toARGB32(),
      "onTertiaryContainer": onTertiaryContainer.toARGB32(),
      "tertiaryFixed": tertiaryFixed.toARGB32(),
      "tertiaryFixedDim": tertiaryFixedDim.toARGB32(),
      "onTertiaryFixed": onTertiaryFixed.toARGB32(),
      "onTertiaryFixedVariant": onTertiaryFixedVariant.toARGB32(),
      "error": error.toARGB32(),
      "onError": onError.toARGB32(),
      "errorContainer": errorContainer.toARGB32(),
      "onErrorContainer": onErrorContainer.toARGB32(),
      "surface": surface.toARGB32(),
      "onSurface": onSurface.toARGB32(),
      "surfaceDim": surfaceDim.toARGB32(),
      "surfaceBright": surfaceBright.toARGB32(),
      "surfaceContainerLowest": surfaceContainerLowest.toARGB32(),
      "surfaceContainerLow": surfaceContainerLow.toARGB32(),
      "surfaceContainer": surfaceContainer.toARGB32(),
      "surfaceContainerHigh": surfaceContainerHigh.toARGB32(),
      "surfaceContainerHighest": surfaceContainerHighest.toARGB32(),
      "onSurfaceVariant": onSurfaceVariant.toARGB32(),
      "outline": outline.toARGB32(),
      "outlineVariant": outlineVariant.toARGB32(),
      "shadow": shadow.toARGB32(),
      "scrim": scrim.toARGB32(),
      "inverseSurface": inverseSurface.toARGB32(),
      "onInverseSurface": onInverseSurface.toARGB32(),
      "inversePrimary": inversePrimary.toARGB32(),
      "surfaceTint": surfaceTint.toARGB32(),
      // "background": background.toARGB32(),
      // "onBackground": onBackground.toARGB32(),
      // "surfaceVariant": surfaceVariant.toARGB32(),
    };
  }
}
