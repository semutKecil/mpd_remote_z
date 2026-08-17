enum MpdState {
  play,
  pause,
  stop;

  static MpdState parseMpdState(dynamic value) {
    if (value is MpdState) return value;
    return MpdState.values.firstWhere(
      (e) => e.name == value.toString(),
      orElse: () => MpdState.stop,
    );
  }
}
