extension StringExt on String {
  String mpdEscape() => replaceAll("\\", "\\\\").replaceAll('"', '\\"');
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }

  bool isVersionSupported(String other) {
    List<int> parseVersion(String v) {
      return v.split('.').map((s) => int.parse(s)).toList();
    }

    final v1 = parseVersion(this);
    final v2 = parseVersion(other);
    while (v1.length < 3) {
      v1.add(0);
    }
    while (v2.length < 3) {
      v2.add(0);
    }

    for (int i = 0; i < 3; i++) {
      if (v1[i] < v2[i]) return false;
      if (v1[i] > v2[i]) return true;
    }
    return true;
  }
}
