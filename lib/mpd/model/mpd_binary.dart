import 'dart:typed_data';

class MpdBinary {
  final int? size;
  final String? type;
  final int binary;
  final Uint8List data;

  MpdBinary({this.size, required this.binary, this.type, required this.data});
}
