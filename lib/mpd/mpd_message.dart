import 'dart:async';
import 'dart:typed_data';
import 'package:mpd_remote_z/mpd/string_ext.dart';

class MpdMessage {
  final String command;
  final List<String> args;
  late final Completer<List<Uint8List>> response;
  MpdMessage({required this.command, this.args = const []}) {
    response = Completer<List<Uint8List>>();
  }

  String toCmdString() {
    if (args.isEmpty) return "$command\n";
    return "$command ${args.map((e) => '"${e.mpdEscape()}"').join(' ')}\n";
  }
}
