import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

class U {
  const U();
}

extension ByteExt on Uint8List {
  String hash() {
    final digest = md5.convert(this); // or md5, sha1, sha512
    return digest.toString();
  }
}

extension IntExt on int {
  String formatPlayTime() {
    Duration duration = Duration(seconds: this);

    int days = duration.inDays;
    int hours = duration.inHours % 24;
    int minutes = duration.inMinutes % 60;
    int secs = duration.inSeconds % 60;

    List<String> parts = [];

    if (days > 0) parts.add("${days}d");
    if (hours > 0) parts.add("${hours}h");
    if (minutes > 0) parts.add("${minutes}m");
    if (secs > 0) parts.add("${secs}s");

    return parts.join(" ");
  }
}

extension DurationFormatting on Duration {
  /// Format duration as mm:ss or h:mm:ss if hours exist
  String format() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(inSeconds.remainder(60));

    if (inHours > 0) {
      // Hours are flexible (can be 1, 2, 3+ digits)
      return "$inHours:$twoDigitMinutes:$twoDigitSeconds";
    } else {
      return "$twoDigitMinutes:$twoDigitSeconds";
    }
  }
}

extension ColorBrightness on Color {
  /// Lightens the color by [amount] (0.0 to 1.0).
  Color lighten([double amount = .1]) {
    final hsl = HSLColor.fromColor(this);
    final hslLight = hsl.withLightness(
      (hsl.lightness + amount).clamp(0.0, 1.0),
    );
    return hslLight.toColor();
  }

  /// Darkens the color by [amount] (0.0 to 1.0).
  Color darken([double amount = .1]) {
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
