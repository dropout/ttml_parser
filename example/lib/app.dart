import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ttml_parser/ttml_parser.dart';

import 'screens/karaoke_screen.dart';
import 'services/audio_service.dart';
import 'services/lyrics_service.dart';

class KaraokeApp extends StatefulWidget {
  const KaraokeApp({super.key});

  @override
  State<KaraokeApp> createState() => _KaraokeAppState();
}

class _KaraokeAppState extends State<KaraokeApp> {
  _AppState _state = const _Loading();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() {
      _state = const _Loading();
    });
    try {
      final ttmlContent =
          await rootBundle.loadString('assets/heart_sutra_hu.ttml');
      final document = const TtmlParser().parse(ttmlContent);
      final lyricsService = LyricsService(document);
      final audioService = AudioService();
      await AudioService.configureSession();
      await audioService.load('assets/heart_sutra_hu.mp3');
      if (!mounted) return;
      setState(() {
        _state = _Loaded(lyricsService: lyricsService, audioService: audioService);
      });
    } on TtmlParseException catch (e) {
      if (!mounted) return;
      setState(() {
        _state = _Failed(message: e.toString());
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _state = _Failed(message: e.toString());
      });
    }
  }

  ThemeData get _theme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          surface: Colors.black,
        ),
        sliderTheme: const SliderThemeData(
          trackHeight: 3,
          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
          overlayShape: RoundSliderOverlayShape(overlayRadius: 14),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Heart Sutra',
      theme: _theme,
      debugShowCheckedModeBanner: false,
      home: switch (_state) {
        _Loading() => const _LoadingScreen(),
        _Loaded(:final lyricsService, :final audioService) =>
          KaraokeScreen(lyricsService: lyricsService, audioService: audioService),
        _Failed(:final message) => _ErrorScreen(
            message: message,
            onRetry: _initialize,
          ),
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Private state ADT
// ---------------------------------------------------------------------------

sealed class _AppState {
  const _AppState();
}

final class _Loading extends _AppState {
  const _Loading();
}

final class _Loaded extends _AppState {
  const _Loaded({required this.lyricsService, required this.audioService});

  final LyricsService lyricsService;
  final AudioService audioService;
}

final class _Failed extends _AppState {
  const _Failed({required this.message});

  final String message;
}

// ---------------------------------------------------------------------------
// Loading screen
// ---------------------------------------------------------------------------

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) => const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
}

// ---------------------------------------------------------------------------
// Error screen
// ---------------------------------------------------------------------------

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: onRetry,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
}