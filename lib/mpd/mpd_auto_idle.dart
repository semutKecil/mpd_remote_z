part of 'mpd_client.dart';

class MpdAutoIdle {
  final MpdConnectionSetting connectionSetting;
  final VoidCallback? onDatabase;
  final VoidCallback? onUpdate;
  final VoidCallback? onStoredPlaylist;
  final VoidCallback? onPlaylist;
  final VoidCallback? onPlayer;
  final VoidCallback? onMixer;
  final VoidCallback? onOutput;
  final VoidCallback? onOptions;
  final VoidCallback? onPartition;
  final VoidCallback? onSticker;
  final VoidCallback? onSubscription;
  final VoidCallback? onMessage;
  final VoidCallback? onNeighbor;
  final VoidCallback? onMount;
  final VoidCallback? onConnectionError;
  late final MpdClient _mpdClient;
  bool _stop = false;
  MpdAutoIdle._({
    required this.connectionSetting,
    this.onDatabase,
    this.onUpdate,
    this.onStoredPlaylist,
    this.onPlaylist,
    this.onPlayer,
    this.onMixer,
    this.onOutput,
    this.onOptions,
    this.onPartition,
    this.onSticker,
    this.onSubscription,
    this.onMessage,
    this.onNeighbor,
    this.onMount,
    this.onConnectionError,
  }) : assert(
         !(onDatabase == null &&
             onUpdate == null &&
             onStoredPlaylist == null &&
             onPlaylist == null &&
             onPlayer == null &&
             onMixer == null &&
             onOutput == null &&
             onOptions == null &&
             onPartition == null &&
             onSticker == null &&
             onSubscription == null &&
             onMessage == null &&
             onNeighbor == null &&
             onMount == null),
         "All callbacks are null",
       );
  Future<void> initialize() async {
    _mpdClient = await MpdClient.connect(
      host: connectionSetting.host,
      port: connectionSetting.port,
      password: connectionSetting.password,
      partition: connectionSetting.partition,
    );
    idle();
  }

  Future<void> noIdle() async {
    _stop = true;
    await _mpdClient.noIdle();
  }

  Future<void> idle() async {
    List<String> args = [];
    if (onDatabase != null) args.add("database");
    if (onUpdate != null) args.add("update");
    if (onStoredPlaylist != null) args.add("stored_playlist");
    if (onPlaylist != null) args.add("playlist");
    if (onPlayer != null) args.add("player");
    if (onMixer != null) args.add("mixer");
    if (onOutput != null) args.add("output");
    if (onOptions != null) args.add("options");
    if (onPartition != null) args.add("partition");
    if (onSticker != null) args.add("sticker");
    if (onSubscription != null) args.add("subscription");
    if (onMessage != null) args.add("message");
    if (onNeighbor != null) args.add("neighbor");
    if (onMount != null) args.add("mount");

    try {
      var response = (await _mpdClient.send("idle", args: args)).toMpdMap();
      for (var e in response["changed"] ?? []) {
        if (e is String) {
          switch (e) {
            case "database":
              onDatabase?.call();
              break;
            case "update":
              onUpdate?.call();
              break;
            case "stored_playlist":
              onStoredPlaylist?.call();
              break;
            case "playlist":
              onPlaylist?.call();
              break;
            case "player":
              onPlayer?.call();
              break;
            case "mixer":
              onMixer?.call();
              break;
            case "output":
              onOutput?.call();
              break;
            case "options":
              onOptions?.call();
              break;
            case "partition":
              onPartition?.call();
              break;
            case "sticker":
              onSticker?.call();
              break;
            case "subscription":
              onSubscription?.call();
              break;
            case "message":
              onMessage?.call();
              break;
            case "neighbor":
              onNeighbor?.call();
              break;
            case "mount":
              onMount?.call();
              break;
            default:
              break;
          }
        }
      }
      if (!_stop) {
        idle();
      } else {
        _mpdClient.disconnect();
      }
    } catch (e) {
      onConnectionError?.call();
    }
  }
}
