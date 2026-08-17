class MpdCount {
  final int songs;
  final Duration duration;
  final String? group;
  const MpdCount({required this.songs, required this.duration, this.group});

  factory MpdCount.fromJson(Map<String, dynamic> json) => MpdCount(
    songs: json['songs'],
    duration: Duration(seconds: json['duration']),
  );

  Map<String, dynamic> toJson() => {
    'songs': songs,
    'duration': duration.inSeconds,
  };
}
