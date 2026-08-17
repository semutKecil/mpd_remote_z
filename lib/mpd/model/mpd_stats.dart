class MpdStats {
  /// From mpd doc
  /// - artists: number of artists
  /// - albums: number of albums
  /// - songs: number of songs
  /// - uptime: daemon uptime in seconds
  /// - db_playtime: sum of all song times in the database in seconds
  /// - db_update: last db update in UNIX time (seconds since 1970-01-01 UTC)
  /// - playtime: time length of music played

  final int artists, albums, songs, uptime, dbPlaytime, playtime;
  final DateTime dbUpdate;
  const MpdStats({
    required this.artists,
    required this.albums,
    required this.songs,
    required this.uptime,
    required this.dbPlaytime,
    required this.dbUpdate,
    required this.playtime,
  });

  factory MpdStats.fromJson(Map<String, dynamic> json) {
    return MpdStats(
      artists: json['artists'] as int,
      albums: json['albums'] as int,
      songs: json['songs'] as int,
      uptime: json['uptime'] as int,
      dbPlaytime: json['dbPlaytime'] as int,
      dbUpdate: DateTime.parse(json['dbUpdate'] as String),
      playtime: json['playtime'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'artists': artists,
      'albums': albums,
      'songs': songs,
      'uptime': uptime,
      'dbPlaytime': dbPlaytime,
      'dbUpdate': dbUpdate.toIso8601String(),
      'playtime': playtime,
    };
  }
}
