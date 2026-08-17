class MpdTags {
  final List<String> artist;
  final List<String> artistSort;
  final List<String> album;
  final List<String> albumSort;
  final List<String> albumArtist;
  final List<String> albumArtistSort;
  final List<String> title;
  final List<String> titleSort;
  final List<String> track;
  final List<String> name;
  final List<String> genre;
  final List<String> mood;
  final List<String> date;
  final List<String> originalDate;
  final List<String> composer;
  final List<String> composerSort;
  final List<String> performer;
  final List<String> conductor;
  final List<String> work;
  final List<String> ensemble;
  final List<String> movement;
  final List<String> movementNumber;
  final List<String> showMovement;
  final List<String> location;
  final List<String> grouping;
  final List<String> comment;
  final List<String> disc;
  final List<String> label;
  final List<String> musicbrainzArtistId;
  final List<String> musicbrainzAlbumId;
  final List<String> musicbrainzAlbumartistId;
  final List<String> musicbrainzTrackId;
  final List<String> musicbrainzReleaseGroupId;
  final List<String> musicbrainzReleaseTrackId;
  final List<String> musicbrainzWorkId;
  const MpdTags({
    this.artist = const [],
    this.artistSort = const [],
    this.album = const [],
    this.albumSort = const [],
    this.albumArtist = const [],
    this.albumArtistSort = const [],
    this.title = const [],
    this.titleSort = const [],
    this.track = const [],
    this.name = const [],
    this.genre = const [],
    this.mood = const [],
    this.date = const [],
    this.originalDate = const [],
    this.composer = const [],
    this.composerSort = const [],
    this.performer = const [],
    this.conductor = const [],
    this.work = const [],
    this.movement = const [],
    this.movementNumber = const [],
    this.ensemble = const [],
    this.location = const [],
    this.grouping = const [],
    this.comment = const [],
    this.disc = const [],
    this.label = const [],
    this.musicbrainzArtistId = const [],
    this.musicbrainzAlbumId = const [],
    this.musicbrainzAlbumartistId = const [],
    this.musicbrainzTrackId = const [],
    this.musicbrainzReleaseTrackId = const [],
    this.musicbrainzWorkId = const [],
    this.musicbrainzReleaseGroupId = const [],
    this.showMovement = const [],
  });

  factory MpdTags.fromJson(Map<String, dynamic> json) {
    return MpdTags(
      artist: List<String>.from(json['artist'] ?? []),
      artistSort: List<String>.from(json['artistSort'] ?? []),
      album: List<String>.from(json['album'] ?? []),
      albumSort: List<String>.from(json['albumSort'] ?? []),
      albumArtist: List<String>.from(json['albumArtist'] ?? []),
      albumArtistSort: List<String>.from(json['albumArtistSort'] ?? []),
      title: List<String>.from(json['title'] ?? []),
      titleSort: List<String>.from(json['titleSort'] ?? []),
      track: List<String>.from(json['track'] ?? []),
      name: List<String>.from(json['name'] ?? []),
      genre: List<String>.from(json['genre'] ?? []),
      mood: List<String>.from(json['mood'] ?? []),
      date: List<String>.from(json['date'] ?? []),
      originalDate: List<String>.from(json['originalDate'] ?? []),
      composer: List<String>.from(json['composer'] ?? []),
      composerSort: List<String>.from(json['composerSort'] ?? []),
      performer: List<String>.from(json['performer'] ?? []),
      conductor: List<String>.from(json['conductor'] ?? []),
      work: List<String>.from(json['work'] ?? []),
      ensemble: List<String>.from(json['ensemble'] ?? []),
      movement: List<String>.from(json['movement'] ?? []),
      movementNumber: List<String>.from(json['movementNumber'] ?? []),
      showMovement: List<String>.from(json['showMovement'] ?? []),
      location: List<String>.from(json['location'] ?? []),
      grouping: List<String>.from(json['grouping'] ?? []),
      comment: List<String>.from(json['comment'] ?? []),
      disc: List<String>.from(json['disc'] ?? []),
      label: List<String>.from(json['label'] ?? []),
      musicbrainzArtistId: List<String>.from(json['musicbrainzArtistId'] ?? []),
      musicbrainzAlbumId: List<String>.from(json['musicbrainzAlbumId'] ?? []),
      musicbrainzAlbumartistId: List<String>.from(
        json['musicbrainzAlbumartistId'] ?? [],
      ),
      musicbrainzTrackId: List<String>.from(json['musicbrainzTrackId'] ?? []),
      musicbrainzReleaseGroupId: List<String>.from(
        json['musicbrainzReleaseGroupId'] ?? [],
      ),
      musicbrainzReleaseTrackId: List<String>.from(
        json['musicbrainzReleaseTrackId'] ?? [],
      ),
      musicbrainzWorkId: List<String>.from(json['musicbrainzWorkId'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (artist.isNotEmpty) map['artist'] = artist;
    if (artistSort.isNotEmpty) map['artistSort'] = artistSort;
    if (album.isNotEmpty) map['album'] = album;
    if (albumSort.isNotEmpty) map['albumSort'] = albumSort;
    if (albumArtist.isNotEmpty) map['albumArtist'] = albumArtist;
    if (albumArtistSort.isNotEmpty) map['albumArtistSort'] = albumArtistSort;
    if (title.isNotEmpty) map['title'] = title;
    if (titleSort.isNotEmpty) map['titleSort'] = titleSort;
    if (track.isNotEmpty) map['track'] = track;
    if (name.isNotEmpty) map['name'] = name;
    if (genre.isNotEmpty) map['genre'] = genre;
    if (mood.isNotEmpty) map['mood'] = mood;
    if (date.isNotEmpty) map['date'] = date;
    if (originalDate.isNotEmpty) map['originalDate'] = originalDate;
    if (composer.isNotEmpty) map['composer'] = composer;
    if (composerSort.isNotEmpty) map['composerSort'] = composerSort;
    if (performer.isNotEmpty) map['performer'] = performer;
    if (conductor.isNotEmpty) map['conductor'] = conductor;
    if (work.isNotEmpty) map['work'] = work;
    if (ensemble.isNotEmpty) map['ensemble'] = ensemble;
    if (movement.isNotEmpty) map['movement'] = movement;
    if (movementNumber.isNotEmpty) map['movementNumber'] = movementNumber;
    if (showMovement.isNotEmpty) map['showMovement'] = showMovement;
    if (location.isNotEmpty) map['location'] = location;
    if (grouping.isNotEmpty) map['grouping'] = grouping;
    if (comment.isNotEmpty) map['comment'] = comment;
    if (disc.isNotEmpty) map['disc'] = disc;
    if (label.isNotEmpty) map['label'] = label;
    if (musicbrainzArtistId.isNotEmpty) {
      map['musicbrainzArtistId'] = musicbrainzArtistId;
    }
    if (musicbrainzAlbumId.isNotEmpty) {
      map['musicbrainzAlbumId'] = musicbrainzAlbumId;
    }
    if (musicbrainzAlbumartistId.isNotEmpty) {
      map['musicbrainzAlbumartistId'] = musicbrainzAlbumartistId;
    }
    if (musicbrainzTrackId.isNotEmpty) {
      map['musicbrainzTrackId'] = musicbrainzTrackId;
    }
    if (musicbrainzReleaseGroupId.isNotEmpty) {
      map['musicbrainzReleaseGroupId'] = musicbrainzReleaseGroupId;
    }
    if (musicbrainzReleaseTrackId.isNotEmpty) {
      map['musicbrainzReleaseTrackId'] = musicbrainzReleaseTrackId;
    }
    if (musicbrainzWorkId.isNotEmpty) {
      map['musicbrainzWorkId'] = musicbrainzWorkId;
    }
    return map;
  }
}
