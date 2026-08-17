// class Player {
//   final Server server;
//   final PlayBack playBack;
//   final NowPlaying? nowPlaying;
//   final List<Song> queue;

//   Player({
//     required this.server,
//     this.nowPlaying,
//     this.playBack = const PlayBack(),
//     this.queue = const [],
//   });
// }

// class PlayBack {
//   final bool isPlaying;
//   final bool repeat;
//   final bool shuffle;
//   final bool single;

//   const PlayBack({
//     this.isPlaying = false,
//     this.repeat = false,
//     this.shuffle = false,
//     this.single = false,
//   });
// }

// class Song {
//   final String id;
//   final String title;
//   final String artist;
//   final String album;
//   final String albumArt;
//   final int duration;

//   const Song({
//     required this.id,
//     required this.title,
//     required this.artist,
//     required this.album,
//     required this.albumArt,
//     required this.duration,
//   });
// }

// class NowPlaying {
//   final Song song;
//   final DateTime playedAt;

//   const NowPlaying({required this.song, required this.playedAt});
// }

// class Server {
//   final String id;
//   final String host;
//   final int port;
//   final String? password;

//   const Server({
//     required this.id,
//     required this.host,
//     required this.port,
//     this.password,
//   });
// }
