enum MpdSingleMode {
  off(value: "0"),
  on(value: "1"),
  oneshot(value: "oneshot");

  final String value;
  const MpdSingleMode({required this.value});

  static MpdSingleMode parseMpdSingleMode(dynamic value) {
    if (value is MpdSingleMode) return value;
    return MpdSingleMode.values.firstWhere(
      (e) => e.value == value.toString(),
      orElse: () => MpdSingleMode.off,
    );
  }
}
