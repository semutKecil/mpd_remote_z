import 'dart:convert';
import 'dart:typed_data';

extension Uint8ListExt on Uint8List {
  // MapEntry<String, String> toEntryString() {
  //   var splitData = String.fromCharCodes(this).split(": ");
  //   return MapEntry(splitData.removeAt(0), splitData.join(": "));
  // }

  // MapEntry<String, int> toEntryInt() {
  //   var splitData = String.fromCharCodes(this).split(": ");
  //   return MapEntry(splitData[0], int.parse(splitData[1]));
  // }

  // MapEntry<String, double> toEntryDouble() {
  //   var splitData = String.fromCharCodes(this).split(": ");
  //   return MapEntry(splitData[0], double.parse(splitData[1]));
  // }

  // MapEntry<String, DateTime> toEntryDatetime() {
  //   var splitData = String.fromCharCodes(this).split(": ");
  //   return MapEntry(splitData[0], DateTime.parse(splitData[1]));
  // }

  List<Uint8List> splitUint8List(int delimiter) {
    List<Uint8List> parts = [];
    int start = 0;

    for (int i = 0; i < length; i++) {
      if (this[i] == delimiter) {
        parts.add(Uint8List.sublistView(this, start, i));
        start = i + 1;
      }
    }

    if (start < length) {
      parts.add(Uint8List.sublistView(this, start));
    }

    return parts;
  }

  bool startsWithString(String prefix) {
    // Convert string to UTF-8 bytes
    Uint8List prefixBytes = Uint8List.fromList(utf8.encode(prefix));

    // If data is shorter than prefix, it can't match
    if (length < prefixBytes.length) return false;

    // Compare byte by byte
    for (int i = 0; i < prefixBytes.length; i++) {
      if (this[i] != prefixBytes[i]) return false;
    }
    return true;
  }
}
