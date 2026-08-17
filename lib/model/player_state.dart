class PlayerState {
  final bool connected;
  const PlayerState({this.connected = false});

  // Future<ServerInfo?> get currentServer async => ServerInfo.getCurrentServer();

  // Future saveCurrentServer(ServerInfo info) async {
  //   ServerInfo.saveCurrentServer(info);
  // }

  PlayerState copyWith({bool? connected}) =>
      PlayerState(connected: connected ?? this.connected);
}
