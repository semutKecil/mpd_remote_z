enum MpdRandomMode {
  on(value: "1"),
  off(value: "0");

  final String value;
  const MpdRandomMode({required this.value});

  static MpdRandomMode parseMpdRandomMode(dynamic value) {
    if (value is MpdRandomMode) return value;
    return MpdRandomMode.values.firstWhere(
      (e) => e.value == value.toString(),
      orElse: () => MpdRandomMode.off,
    );
  }
}
