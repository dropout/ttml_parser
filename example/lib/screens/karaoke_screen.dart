import 'dart:async';

import 'package:flutter/material.dart';

import '../models/player_state.dart';
import '../services/audio_service.dart';
import '../services/lyrics_service.dart';
import '../widgets/lyrics_view.dart';
import '../widgets/player_controls.dart';

/// The root screen of the karaoke player.
///
/// Subscribes to [AudioService.positionStream] and [AudioService.playingStream]
/// and derives a [PlayerState] synchronously on each tick, passing the relevant
/// pieces down to [LyricsView] and [PlayerControls].
class KaraokeScreen extends StatefulWidget {
  const KaraokeScreen({
    super.key,
    required this.lyricsService,
    required this.audioService,
  });

  final LyricsService lyricsService;
  final AudioService audioService;

  @override
  State<KaraokeScreen> createState() => _KaraokeScreenState();
}

class _KaraokeScreenState extends State<KaraokeScreen> {
  Duration _position = Duration.zero;
  bool _isPlaying = false;

  late final StreamSubscription<Duration> _positionSub;
  late final StreamSubscription<bool> _playingSub;

  @override
  void initState() {
    super.initState();
    _positionSub = widget.audioService.positionStream.listen(
      (position) {
        if (mounted) {
          setState(() {
            _position = position;
          });
        }
      },
      onError: (Object error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Playback error: $error')),
          );
        }
      },
    );
    _playingSub = widget.audioService.playingStream.listen(
      (playing) {
        if (mounted) {
          setState(() {
            _isPlaying = playing;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _positionSub.cancel();
    _playingSub.cancel();
    widget.audioService.dispose();
    super.dispose();
  }

  PlayerState get _playerState {
    final activeIndex =
        widget.lyricsService.activeLineIndex(_position);
    return PlayerState(
      position: _position,
      duration: widget.audioService.duration,
      isPlaying: _isPlaying,
      activeLine: widget.lyricsService.activeLine(_position),
      activeLineIndex: activeIndex,
    );
  }

  void _onPlayPause() {
    if (_isPlaying) {
      widget.audioService.pause();
    } else {
      widget.audioService.play();
    }
  }

  void _onSeek(Duration position) {
    widget.audioService.seekTo(position);
  }

  @override
  Widget build(BuildContext context) {
    final state = _playerState;
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          Expanded(
            child: LyricsView(
              document: widget.lyricsService.document,
              position: state.position,
              activeLineIndex: state.activeLineIndex,
              lyricsService: widget.lyricsService,
            ),
          ),
          PlayerControls(
            position: state.position,
            duration: state.duration,
            isPlaying: state.isPlaying,
            onSeek: _onSeek,
            onPlayPause: _onPlayPause,
          ),
        ],
      ),
    );
  }
}