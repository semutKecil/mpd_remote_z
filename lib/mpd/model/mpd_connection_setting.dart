class MpdConnectionSetting {
  final String host;
  final int port;
  final String? password;
  final String? partition;

  const MpdConnectionSetting({
    required this.host,
    required this.port,
    this.password,
    this.partition,
  });

  factory MpdConnectionSetting.fromJson(Map<String, dynamic> json) =>
      MpdConnectionSetting(
        host: json['host'],
        port: json['port'],
        password: json['password'],
        partition: json['partition'],
      );

  Map<String, dynamic> toJson() => {
    'host': host,
    'port': port,
    'password': password,
    'partition': partition,
  };

  MpdConnectionSetting copyWith({
    String? host,
    int? port,
    String? password,
    String? partition,
  }) => MpdConnectionSetting(
    host: host ?? this.host,
    port: port ?? this.port,
    password: password ?? this.password,
    partition: partition ?? this.partition,
  );
}
