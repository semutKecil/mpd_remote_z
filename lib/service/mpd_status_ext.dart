import 'package:audio_service/audio_service.dart';
import 'package:mpd_remote_z/mpd/model/mpd_random_mode.dart';
import 'package:mpd_remote_z/mpd/model/mpd_repeat_mode.dart';
import 'package:mpd_remote_z/mpd/model/mpd_single_mode.dart';
import 'package:mpd_remote_z/mpd/model/mpd_state.dart';
import 'package:mpd_remote_z/mpd/model/mpd_status.dart';

extension MpdStatusExt on MpdStatus {
  PlaybackState toPlaybackState() {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        state == MpdState.play ? MediaControl.pause : MediaControl.play,
        MediaControl.skipToNext,
        MediaControl.stop,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.skipToNext,
        MediaAction.skipToPrevious,
        MediaAction.stop,
      },

      androidCompactActionIndices: [0, 1, 2],
      processingState: AudioProcessingState.ready,
      updatePosition: Duration(
        milliseconds: ((elapsed ?? 0.0) * 1000.0).toInt(),
      ),
      playing: state == MpdState.play,
      queueIndex: song,
      // captioningEnabled: true,
      bufferedPosition: Duration.zero,
      speed: 1.0,
      repeatMode: repeat == MpdRepeatMode.on && single == MpdSingleMode.on
          ? AudioServiceRepeatMode.one
          : repeat == MpdRepeatMode.on && single == MpdSingleMode.off
          ? AudioServiceRepeatMode.all
          : AudioServiceRepeatMode.none,
      shuffleMode: random == MpdRandomMode.on
          ? AudioServiceShuffleMode.all
          : AudioServiceShuffleMode.none,
    );
  }
}
