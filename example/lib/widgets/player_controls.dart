import 'package:flutter/material.dart';

/// A fixed-height bottom bar showing track info, a seek bar, and transport
/// controls (skip-back, play/pause, skip-forward).
class PlayerControls extends StatelessWidget {
  const PlayerControls({
    super.key,
    required this.position,
    required this.duration,
    required this.isPlaying,
    required this.onSeek,
    required this.onPlayPause,
  });

  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final ValueChanged<Duration> onSeek;
  final VoidCallback onPlayPause;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final clampedMax =
        duration.inMilliseconds.toDouble().clamp(1.0, double.infinity);
    final clampedValue =
        position.inMilliseconds.toDouble().clamp(0.0, clampedMax);

    return Container(
      color: const Color(0xFF111111),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Track info row
            ListTile(
              leading: const Icon(
                Icons.music_note_rounded,
                color: Colors.white70,
                size: 40,
              ),
              title: const Text(
                'Heart Sutra',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text(
                'Hungarian Translation',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                ),
              ),
            ),

            // Seek bar row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape:
                          const RoundSliderOverlayShape(overlayRadius: 14),
                    ),
                    child: Slider(
                      value: clampedValue,
                      min: 0,
                      max: clampedMax,
                      activeColor: Colors.white,
                      inactiveColor: Colors.white24,
                      thumbColor: Colors.white,
                      onChanged: (value) =>
                          onSeek(Duration(milliseconds: value.round())),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(position),
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          _formatDuration(duration),
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Transport row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 36,
                  color: Colors.white,
                  icon: const Icon(Icons.skip_previous_rounded),
                  onPressed: () => onSeek(Duration.zero),
                ),
                IconButton(
                  iconSize: 64,
                  color: Colors.white,
                  icon: Icon(
                    isPlaying
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_circle_filled_rounded,
                  ),
                  onPressed: onPlayPause,
                ),
                IconButton(
                  iconSize: 36,
                  color: Colors.white,
                  icon: const Icon(Icons.skip_next_rounded),
                  onPressed: () => onSeek(duration),
                ),
              ],
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

String _formatDuration(Duration d) {
  final minutes = d.inMinutes.remainder(60);
  final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}