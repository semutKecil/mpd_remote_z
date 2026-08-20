# Dokumentasi Teknis — MPD Remote (`mpd_remote_z`)

> Dokumen ini menjelaskan arsitektur, alur data, dan struktur kode aplikasi MPD Remote.
> Ditulis berdasarkan inspeksi kode sumber pada tanggal 2026-08-20.

---

## 1. Gambaran Umum

`mpd_remote_z` adalah aplikasi **client MPD (Music Player Daemon)** berbasis **Flutter**. Aplikasi ini terhubung ke server MPD lewat jaringan, memungkinkan pengguna untuk:

- Menjelajah pustaka musik (album, artis, tag, file, playlist)
- Mencari musik
- Mengontrol pemutaran, volume, dan mode (repeat/random/single/consume)
- Mendapatkan notifikasi & kontrol media di background (via `audio_service`)

**Platform yang didukung:**

| Platform | Status |
|---|---|
| Android | ✅ Diuji |
| Windows | ✅ Diuji |
| iOS, macOS, Linux | 🔨 Bisa dibuild, belum diuji |

**Lisensi:** GPL-3.0 · **Package name:** `com.github.semutkecil.mpd_remote_z`

---

## 2. Arsitektur Aplikasi

Aplikasi menggunakan pola **service-oriented** dengan **audio_service** sebagai tulang punggung. Tidak ada state management library eksternal (seperti Provider/Riverpod/Bloc); sebagai gantinya digunakan:

- **`audio_service` streams** (`customEvent`, `mediaItem`, `playbackState`, `queue`) sebagai kanal komunikasi utama.
- **`StreamManager<T>`** — utilitas kecil (getter + broadcast stream) untuk event antar-widget.
- **Global state sederhana** (`playerState`, `playerModeEvent`, dll.).

```mermaid
flowchart TD
    subgraph UI [Lapisan UI — lib/ui]
        Pages[Pages: NowPlaying, Files, Playlist, Album, Artist, Search, Settings, ...]
        Widgets[Widgets: BottomMiniPlayer, DrawerMenu, GlassCard, ...]
    end

    subgraph Router [Routing — auto_route]
        Router[AppRouter + Route Guards]
    end

    subgraph Core [Kontrol — lib/service]
        GAH[GeneralAudioHandler<br/>extends BaseAudioHandler]
        AHC[AudioHandlerCustom]
        CA[CustomAction enum]
        SM[StreamManager]
        DB[Debouncer]
    end

    subgraph MPD [Protokol MPD — lib/mpd]
        MC[MpdClient — Socket TCP]
        MM[MpdMessage]
        AI[MpdAutoIdle]
        MODELS[MpdStatus, MpdSong, MpdStats, ...]
    end

    subgraph Data [Data — lib/model]
        SI[ServerInfo]
        SA[SongArt]
        PS[PlayerState]
    end

    Pages --> Router
    Router --> Pages
    Pages --> GAH
    Pages --> SM
    GAH --> AHC
    AHC --> CA
    GAH --> MC
    CA --> MC
    MC --> MM
    MC --> AI
    AI --> GAH
    MC --> MODELS
    GAH --> SI
    GAH --> SA
    SA --> SI
    GAH --> PS
```

---

## 3. Struktur Direktori

```
lib/
├── main.dart                     # Entry point: init AudioService, window manager, runApp
├── app_router.dart               # Konfigurasi auto_route + route guards
├── app_router.gr.dart            # (Generated) hasil auto_route
│
├── model/                        # Model aplikasi
│   ├── player_state.dart         # State global koneksi (connected)
│   ├── server_info.dart          # Info server MPD (host/port/password/partition)
│   └── song_art.dart             # Cache album art + color scheme
│
├── mpd/                          # Lapisan protokol MPD (murni, tanpa Flutter UI)
│   ├── mpd_client.dart           # Client Socket TCP ke MPD + parsing respons
│   ├── mpd_auto_idle.dart        # Sistem idle MPD (notifikasi realtime)
│   ├── mpd_message.dart          # Representasi perintah MPD
│   ├── list_ext.dart             # Ekstensi parsing list respons
│   ├── string_ext.dart           # Ekstensi string (escape, etc.)
│   ├── uint8_list_ext.dart       # Ekstensi byte
│   └── model/                    # Model protokol (MpdStatus, MpdSong, dll.)
│
├── service/                      # Lapisan layanan (jembatan MPD ↔ audio_service)
│   ├── general_audio_handler.dart# Handler utama audio_service
│   ├── audio_handler_custom.dart # Wrapper API untuk UI (delegasi ke CustomAction)
│   ├── custom_action.dart        # Enum aksi yang dipetakan ke implementasi
│   ├── stream_manager.dart       # State reaktif minimal
│   ├── debouncer.dart            # Debounce (dipakai volume control)
│   ├── media_item_ext.dart       # Konversi MpdSong → MediaItem
│   ├── mpd_song_ext.dart         # Ekstensi MpdSong
│   ├── mpd_status_ext.dart       # MpdStatus → PlaybackState
│   └── u.dart                    # Utilitas (hash, format durasi, warna)
│
└── ui/
    ├── page/                     # Halaman-halaman
    │   ├── background_page.dart
    │   ├── server_list_page.dart
    │   ├── connect_server_page.dart
    │   ├── loader_page.dart
    │   └── connected/            # Halaman utama setelah terhubung
    │       ├── connected_page.dart
    │       ├── now_playing_page.dart
    │       ├── files_page.dart
    │       ├── playlist_page.dart
    │       ├── album_list_page.dart / album_page.dart
    │       ├── artist_list_page.dart / artist_page.dart
    │       ├── search_page.dart
    │       ├── tags_list_page.dart / tags_page.dart
    │       ├── settings_page.dart / partition_page.dart
    │       └── bottom_mini_player.dart
    └── widget/                   # Widget reusable (GlassCard, DrawerMenu, dll.)
```

---

## 4. Alur Startup (`main.dart`)

Urutan inisialisasi di `main()`:

1. **`AudioService.init`** — memuat `GeneralAudioHandler` sebagai handler background audio. Menentukan `androidNotificationChannelId` & nama channel.
2. **Persiapan default cover art** — menyalin `assets/images/default-cover2.png` ke `getApplicationSupportDirectory()` dengan nama `defaultCoverHash` bila belum ada.
3. **`ColorScheme.fromImageProvider`** — menghasilkan skema warna tema aplikasi dari sampul lagu (fitur khas: tema dinamis mengikuti warna album art).
4. **`window_manager`** — khusus non-Android (desktop): membuat jendela 800×600, center, transparent, dengan `TitleBarStyle.normal`.
5. **`runApp(MyApp)`** — `MyApp` mendengarkan `audioService.customEvent` untuk memperbarui `playerState.connected` (event `connect`/`disconnet`).

> Catatan: `audioService` dideklarasikan sebagai `late final` global — diakses langsung dari mana pun di aplikasi.

---

## 5. Routing (`app_router.dart`)

Menggunakan **`auto_route`** dengan route tree bertingkat:

```
/  (BackgroundRoute — halaman dasar)
├── /servers            (ServerListRoute)
├── /form               (ConnectServerRoute)
├── /loader             (LoaderRoute)
└── /connected          (ConnectedRoute — root setelah terhubung)
    ├── /connected/playing         (NowPlayingRoute — initial)
    ├── /connected/files/:parent   (FilesRoute)
    ├── /connected/playlists/:name (PlaylistRoute)
    ├── /connected/artists         (ArtistListRoute)
    ├── /connected/artists/:artist (ArtistRoute)
    ├── /connected/albums          (AlbumListRoute)
    ├── /connected/albums/:album   (AlbumRoute)
    ├── /connected/search/:tags    (SearchRoute)
    ├── /connected/tags/:tag/:title/:value (TagsListRoute, TagsRoute)
    ├── /connected/settings        (SettingsRoute)
    └── /connected/settings/partitions (PartitionRoute)
```

**Route Guard:** `conCheck` memastikan pengguna sudah terhubung ke server MPD. Jika `playerState.connected == false`, semua route di dalam `ConnectedRoute` akan diarahkan ulang ke `LoaderRoute` (dengan callback `onConnect` yang melanjutkan navigasi).

**Transisi:** custom slide transition (kiri↔kanan) selama 300ms, bukan transisi default.

---

## 6. Lapisan Protokol MPD (`lib/mpd/`)

### `MpdClient`

Client protokol MPD murni berbasis **`dart:io Socket`** (TCP). Poin penting:

- **Koneksi:** `Socket.connect(host, port, timeout: 5s)` — mendukung password & partition.
- **Command queue:** Setiap perintah dibungkus `MpdMessage` yang punya `Completer<List<Uint8List>>`; respons `OK`/`ACK` diselesaikan secara FIFO dari antrian.
- **Parsing respons biner:** Mendukung respons `binary:` dari MPD (dipakai untuk mengambil **album art** lewat `readPicture`). Ada penanganan khusus untuk data biner yang terpecah antar paket (`_binaryLength`, `_unfinishedBinnary`).
- **`AsyncLock`:** Serialisasi akses socket agar aman untuk concurrent request.
- **Auto-idle:** Bekerja sama dengan `MpdAutoIdle`.

### `MpdMessage`

Membungkus `command` + `args` dan menghasilkan string perintah MPD dengan escaping yang benar (`mpdEscape()`).

### `MpdAutoIdle`

Mengirim perintah `idle <subsystem>` MPD. Saat ada perubahan (player, playlist, database, mixer, options, output, partition, dll.), MPD mengirimkan nama subsistem yang berubah, lalu `MpdAutoIdle` memicu callback yang sesuai dan langsung mengirim `idle` lagi (loop). Digunakan `noIdle()` untuk menghentikan saat disconnect.

### Model protokol (`lib/mpd/model/`)

`MpdStatus` (state play/pause/stop, volume, repeat, dll.), `MpdSong` (file, tags, duration, id), `MpdStats`, `MpdResponse`, `MpdCount`, `MpdOutput`, mode enum (`MpdRepeatMode`, `MpdRandomMode`, dll.), dan `MpdConnectionSetting`.

---

## 7. Lapisan Audio Service (`lib/service/`)

### `GeneralAudioHandler` (`general_audio_handler.dart`)

`extends BaseAudioHandler with QueueHandler, SeekHandler` — jembatan utama antara MPD dan `audio_service`. Stream yang dipublikasikan:

| Stream | Isi |
|---|---|
| `customEvent` | Event aplikasi (`AudioHandlerEvent`) |
| `mediaItem` | Lagu yang sedang diputar |
| `playbackState` | State pemutaran (playing, position, dll.) |
| `queue` | Antrian lagu |
| `androidPlaybackInfo` | Info volume remote (Android) |

**Event (`AudioHandlerEvent`):** `connect`, `disconnet`, `preDisconnet`, `statusUpdate`, `statsUpdate`, `storedPlaylistUpdate`, `stop`, `outputUpdate`, `partitionChange`.

**Metode internal utama:**

- `_updateStatus()` / `_updateStats()` — polling status & statistik MPD.
- `_mpdUpdateCurrentSong()` — update `mediaItem` + trigger update album art.
- `_mpdUpdateQueue()` — update antrian dari `playlistInfo`.
- `_playOrPause()` — toggle play/pause (menunggu `_playPauseCompleter` sampai status benar-benar berubah).
- `_disconnect()` — reset semua stream, hentikan idle, putus socket.
- `_initAutoIdle()` — menghubungkan callback idle MPD ke handler.
- `_cacheData<T>()` — **cache query MPD** ke `SharedPreferencesAsync`, key: `serverId-dbDate-command-args`. Cache otomatis valid jika `dbUpdate` (timestamp update database MPD) berubah.

**Override `BaseAudioHandler`:** `play`, `pause`, `stop`, `skipToNext`, `skipToPrevious`, `seek`, `playFromMediaId`, `skipToQueueItem`, `addQueueItem`, `insertQueueItem`, `androidSetRemoteVolume`, `androidAdjustRemoteVolume`, `customAction`. Semuanya diterjemahkan ke perintah MPD (`playId`, `seekCur`, `setVol`, `add`, `next`, `previous`, dst.).

### `AudioHandlerCustom` + `CustomAction`

`AudioHandlerCustom` adalah **API publik untuk UI** — setiap metode memanggil `CustomAction.<aksi>.call(handler, extras)`, yang melewati `customAction()` milik `audio_service` lalu dieksekusi oleh fungsi yang terdaftar di enum `CustomAction`. Daftar aksi meliputi: `connect`, `disconnect`, `toggleRepeat/Random/Single/Consume`, `moveId`, `deleteId`, `playlistAdd`, `lsInfo`, `listPlaylists`, `clear`, `playId`, `addId`, `load`, `find`, `search`, `count`, `crossFade`, `replayGain*`, `update`, `rescan`, `listPartitions`, `toggleOutput`, `partition`, `setFavorite`, `deleteFavorite`, dll.

### `Debouncer`

Menggabungkan event volume (dari tombol volume sistem Android) agar perintah `setVol` MPD tidak dikirim berlebihan (delay 300ms).

---

## 8. State Management & Data

### `StreamManager<T>` (`stream_manager.dart`)

Primitif state reaktif sederhana:

- `value` — baca state sinkron
- `stream` — broadcast stream untuk listener
- `emit(newData)` — update state + notifikasi listener
- `dispose()`

Dipakai misalnya di `connected_page.dart` untuk `miniPlayerShowStream`, `miniPlayerTapEvent`, `playerModeEvent`.

### Global state

- `playerState` (`PlayerState`) — flag `connected` global, diperbarui oleh `MyApp` saat event `connect`/`disconnet`.
- `defaultColorScheme` — tema default dari cover image.

### Persistence (via `shared_preferences`)

- **`ServerInfo`** — daftar server tersimpan (id UUID, name, host, port, password, partition, version) + `saveCurrentServer()` untuk server yang sedang aktif.
- **`SongArt`** — cache album art: bytes art di-hash (MD5) sebagai nama file di `getApplicationSupportDirectory()`, disimpan di key `artDb` (`SharedPreferencesAsync`). Menyimpan `key`, `hash`, dan `colorScheme` (dipakai untuk tema dinamis). Ada `saveWithDefault()` bila MPD tidak punya art.
- **Cache query** — `_cacheData` (lihat bagian 7).

---

## 9. UI (`lib/ui/`)

### Halaman utama

- **`ConnectedPage`** — Scaffold utama dengan drawer + `AutoRouter` + `BottomMiniPlayer` (mode portrait < 600px) atau mode "big" (≥600px). Ada `Timer.periodic(3s)` yang mengecek koneksi & media item untuk auto-navigasi ke `LoaderRoute` bila koneksi terputus.
- **`NowPlayingPage`** — halaman pemutaran utama (album art, kontrol, progress).
- **Halaman brows** — `FilesPage`, `PlaylistPage`, `AlbumPage`, `ArtistPage`, `SearchPage`, `TagsPage` — semuanya membaca data via `audioService.custom` (API `AudioHandlerCustom`).
- **`SettingsPage` / `PartitionPage`** — pengaturan (termasuk partition MPD).

### Widget reusable

`GlassCard`, `BackgroundContainer`, `DrawerMenu`, `BottomMiniPlayer`, `QueueSliver`, `SimpleCircularSlider`, `FutureWidget`, `LoadingMask`, tile-list, dialog, dll.

---

## 10. Integrasi Platform

- **Android:** `audio_service` menyediakan notifikasi media + kontrol lock screen/headset. Manifest mendeklarasikan `AudioServiceActivity`, `AudioService` (foreground service `mediaPlayback`), `MediaButtonReceiver`, permission `FOREGROUND_SERVICE` & `FOREGROUND_SERVICE_MEDIA_PLAYBACK` (targetSdk 34+), dan `WAKE_LOCK`.
- **Windows:** `audio_service_win` untuk kontrol media; `window_manager` untuk pengaturan jendela; `audio_service` handler tetap dipakai.
- **macOS/iOS:** perlu entitlement/background audio (belum diuji).

---

## 11. Dependensi Utama

| Package | Kegunaan |
|---|---|
| `audio_service` | Background audio, media notification, custom actions |
| `audio_service_win` | Dukungan audio_service di Windows |
| `auto_route` (+ generator) | Routing deklaratif + guards |
| `shared_preferences` | Persistence (server, cache, art DB) |
| `crypto` | MD5 hash untuk nama file album art |
| `path_provider` | Lokasi direktori aplikasi |
| `uuid` | ID server |
| `url_launcher` | Membuka tautan eksternal |
| `window_manager` | Manajemen jendela desktop |
| `orient_text_field` | Input teks (host/port) |
| `flutter_spinkit` | Indikator loading |
| `build_runner` | Generator (auto_route) |

---

## 12. Build & Run

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # regenerasi app_router.gr.dart
flutter run                                               # atau
flutter build apk --release
```

> Catatan: file `app_router.gr.dart` di-generate oleh `auto_route` — perlu dijalankan `build_runner` setelah mengubah `app_router.dart`.

---

## 13. Catatan Penting / Area Perhatian

1. **Tema dinamis dari album art** — `ColorScheme` dibangkitkan dari cover lagu; pastikan cache art (`artDb` + file) tetap konsisten saat cover berubah.
2. **Cache query MPD** — validasi cache bergantung pada `dbUpdate` MPD; jika MPD di-update, cache otomatis invalid.
3. **`player_state.dart`** — sebagian besar logika state lama sudah di-comment out; state aktif hanya `connected`. Ini area yang berpotensi disederhanakan/dibersihkan.
4. **Route guard & loader** — alur koneksi bergantung pada `playerState.connected` yang di-set oleh event `connect`/`disconnet` di `main.dart`.
5. **Splash screen** — dikonfigurasi di `android/app/src/main/res/`; bisa dikelola dengan `flutter_native_splash` (lihat topik terpisah).
6. **`uint8_list_ext.dart`** perlu dicek untuk dukungan parsing biner besar (binary album art) pada MPD yang mengirim data dalam chunk besar.
