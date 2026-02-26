import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

/// Wraps a [AudioPlayer] from `just_audio` and exposes a simplified
/// interface for loading, controlling, and observing audio playback.
class AudioService {
  AudioService() : _player = AudioPlayer();

  final AudioPlayer _player;
  Duration _duration = Duration.zero;

  /// The total duration of the loaded track.
  Duration get duration => _duration;

  /// A stream that emits the current playback position approximately every
  /// 200 ms (just_audio default — sufficient for ≥4 updates per second).
  Stream<Duration> get positionStream => _player.positionStream;

  /// A stream that emits `true` when playing and `false` when paused/stopped.
  Stream<bool> get playingStream => _player.playingStream;

  /// Configures the OS audio session for music playback.
  ///
  /// Call this once during app initialisation, before [load].
  static Future<void> configureSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  /// Loads the asset at [assetPath] and caches the track [duration].
  Future<void> load(String assetPath) async {
    final d = await _player.setAsset(assetPath);
    _duration = d ?? Duration.zero;
  }

  /// Starts or resumes playback.
  Future<void> play() => _player.play();

  /// Pauses playback.
  Future<void> pause() => _player.pause();

  /// Seeks to [position].
  Future<void> seekTo(Duration position) => _player.seek(position);

  /// Releases all resources held by the underlying [AudioPlayer].
  Future<void> dispose() => _player.dispose();
}