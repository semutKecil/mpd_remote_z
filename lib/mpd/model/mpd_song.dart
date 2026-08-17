class MpdDirectory {
  final String directory;
  final DateTime? lastModified;
  const MpdDirectory({required this.directory, this.lastModified});

  String get name => directory.split('/').last;

  factory MpdDirectory.fromJson(Map<String, dynamic> json) {
    return MpdDirectory(
      directory: json['directory'] as String,
      lastModified: json['lastModified'] != null
          ? DateTime.parse(json['lastModified'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'directory': directory,
    'lastModified': lastModified?.toIso8601String(),
  };
}

class MpdPlaylist {
  final String playlist;
  final DateTime? lastModified;
  const MpdPlaylist({required this.playlist, this.lastModified});

  factory MpdPlaylist.fromJson(Map<String, dynamic> json) {
    return MpdPlaylist(
      playlist: json['playlist'] as String,
      lastModified: json['lastModified'] != null
          ? DateTime.parse(json['lastModified'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'playlist': playlist,
    'lastModified': lastModified?.toIso8601String(),
  };
}

class MpdSong {
  final String file;
  final int? pos;
  final int? id;
  final DateTime? lastModified;
  final String? format;
  final double? duration;
  final String? range;
  // final MpdTags tags;
  final Map<String, List<String>> tags;
  final int? time;
  final DateTime? added;

  String get title => tags["title"]?.join(', ') ?? file.split('/').last;
  // tags.title.isNotEmpty ? tags.title.join(', ') : file.split('/').last;

  String get album => tags["album"]?.join(', ') ?? 'unknown';
  // tags.album.isNotEmpty ? tags.album.join(', ') : 'unknown';
  String get artist => tags["artist"]?.join(', ') ?? 'unknown';
  // tags.artist.isNotEmpty ? tags.artist.join(', ') : 'unknown';

  String get albumArtist => tags["albumartist"]?.join(', ') ?? artist;
  // tags.albumArtist.isNotEmpty
  //     ? tags.albumArtist.join(', ')
  //     : tags.artist.isNotEmpty
  //     ? tags.artist.join(', ')
  //     : 'unknown';
  String? get genre => tags["genre"]?.join(
    ', ',
  ); // tags.genre.isNotEmpty ? tags.genre.join(', ') : null;
  String get description => "$artist - $album";

  String get artId => "$album:$albumArtist:${tags["disc"]?.firstOrNull ?? "0"}";

  const MpdSong({
    required this.file,
    this.pos,
    this.id,
    this.tags = const {}, //MpdTags(),
    this.duration,
    this.lastModified,
    this.format,
    this.range,
    this.time,
    this.added,
  });

  factory MpdSong.fromJson(Map<String, dynamic> json) {
    Map<String, List<String>> tagsMapping = {};

    if (json['tags'] != null && json['tags'] is Map) {
      json['tags'].forEach((key, value) {
        if (value is List) {
          tagsMapping[key.toString()] = value.whereType<String>().toList();
        }
      });
    }

    return MpdSong(
      file: json['file'] as String,
      pos: json['pos'] as int?,
      id: json['id'] as int?,
      lastModified: json['lastModified'] != null
          ? DateTime.parse(json['lastModified'] as String)
          : null,
      format: json['format'] as String?,
      duration: (json['duration'] as num?)?.toDouble(),
      range: json['range'] as String?,
      tags: tagsMapping,
      time: json['time'] as int?,
      added: json['added'] != null
          ? DateTime.parse(json['added'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'file': file,
      'pos': pos,
      'id': id,
      'lastModified': lastModified?.toIso8601String(),
      'format': format,
      'duration': duration,
      'range': range,
      'tags': tags,
      'time': time,
      'added': added?.toIso8601String(),
    };
  }
}
