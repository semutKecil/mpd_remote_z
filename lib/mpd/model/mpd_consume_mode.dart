enum MpdReplayGainMode { off, track, album, auto }

enum MpdConsumeMode {
  off(value: "0"),
  on(value: "1"),
  oneshot(value: "oneshot");

  final String value;
  const MpdConsumeMode({required this.value});

  static MpdConsumeMode parseMpdConsumeMode(dynamic value) {
    if (value is MpdConsumeMode) return value;
    return MpdConsumeMode.values.firstWhere(
      (e) => e.value == value.toString(),
      orElse: () => MpdConsumeMode.off,
    );
  }
}
