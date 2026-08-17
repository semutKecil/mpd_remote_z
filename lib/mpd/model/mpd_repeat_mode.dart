enum MpdRepeatMode {
  on(value: "1"),
  off(value: "0");

  final String value;
  const MpdRepeatMode({required this.value});

  static MpdRepeatMode parseMpdRepeatMode(dynamic value) {
    if (value is MpdRepeatMode) return value;
    return MpdRepeatMode.values.firstWhere(
      (e) => e.value == value.toString(),
      orElse: () => MpdRepeatMode.off,
    );
  }
}
