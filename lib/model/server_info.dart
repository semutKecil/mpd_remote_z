import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ServerInfo {
  final String id;
  final String name;
  final String host;
  final int port;
  final String? password;
  final String? version;
  final String? partition;

  ServerInfo({
    required this.id,
    required this.name,
    required this.host,
    required this.port,
    this.password,
    this.version,
    this.partition,
  });

  ServerInfo copyWith({
    String? name,
    String? host,
    int? port,
    String? password,
    String? version,
    String? partition,
  }) => ServerInfo(
    id: id,
    name: name ?? this.name,
    host: host ?? this.host,
    port: port ?? this.port,
    password: password ?? this.password,
    version: version ?? this.version,
    partition: partition ?? this.partition,
  );

  factory ServerInfo.create({
    required String name,
    required String host,
    required int port,
    String? password,
    String? partition,
  }) => ServerInfo(
    id: Uuid().v4(),
    name: name,
    host: host,
    port: port,
    password: password,
    partition: partition,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'host': host,
    'port': port,
    'password': password,
    'version': version,
    'partition': partition,
  };

  factory ServerInfo.fromJson(Map<String, dynamic> json) => ServerInfo(
    id: json['id'],
    name: json['name'],
    host: json['host'],
    port: json['port'],
    password: json['password'],
    version: json['version'],
    partition: json['partition'],
  );

  static Future<List<ServerInfo>> findAll() async {
    SharedPreferencesAsync prefs = SharedPreferencesAsync();
    return ((await prefs.getStringList("serverInfo")) ?? [])
        .map((e) {
          try {
            return ServerInfo.fromJson(jsonDecode(e));
          } catch (_) {
            return null;
          }
        })
        .whereType<ServerInfo>()
        .toList();
  }

  static Future<ServerInfo?> getCurrentServer() async {
    SharedPreferencesAsync prefs = SharedPreferencesAsync();
    var json = await prefs.getString("currentServerInfo");
    if (json == null) return null;
    return ServerInfo.fromJson(jsonDecode(json));
  }

  static Future deleteCurrentServer() async {
    SharedPreferencesAsync prefs = SharedPreferencesAsync();
    await prefs.remove("currentServerInfo");
  }

  static Future delete(ServerInfo info) async {
    SharedPreferencesAsync prefs = SharedPreferencesAsync();
    await prefs.setStringList(
      "serverInfo",
      (await findAll())
          .where((e) => e.id != info.id)
          .map((e) => jsonEncode(e))
          .toList(),
    );
  }

  static Future saveCurrentServer(ServerInfo info) async {
    SharedPreferencesAsync prefs = SharedPreferencesAsync();
    await prefs.setString("currentServerInfo", jsonEncode(info));
    await prefs.setStringList(
      "serverInfo",
      ((await findAll())
            ..removeWhere((e) => e.id == info.id)
            ..add(info))
          .map((e) => jsonEncode(e))
          .toList(),
    );
  }
}
