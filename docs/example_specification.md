# Karaoke Example App Specification

## 1. Overview

This document specifies the `example` Flutter application that ships alongside the `ttml_parser`
package. Its purpose is to demonstrate real-world usage of `TtmlParser`, `TtmlDocument`,
`TtmlLine`, `TtmlWord`, and `TtmlAgent` in a polished, production-quality UI.

The app is a **full-screen karaoke player** inspired by Apple Music's lyrics view. It plays the
bundled `heart_sutra_hu.mp3` audio file while displaying the word-level-timed lyrics parsed from
`heart_sutra_hu.ttml`. Words are highlighted in real time as they are sung.

---

## 2. Assets

Both assets already exist inside `example/assets/`:

| File | Purpose |
|------|---------|
| `assets/heart_sutra_hu.ttml` | TTML lyric source file (58 lines, word-level timing) |
| `assets/heart_sutra_hu.mp3` | Audio track that the lyrics are synchronised to |

Both entries must be declared in `example/pubspec.yaml` under `flutter > assets`.

---

## 3. Dependencies

Add the following to `example/pubspec.yaml`:

| Package | Role |
|---------|------|
| `ttml_parser` (path dependency `../`) | Parses the TTML file |
| `just_audio` (latest stable) | Audio playback, exposes a `Stream<Duration>` position |
| `audio_session` (latest stable) | Configures the OS audio session for music playback |

No other third-party dependencies are required. The standard `flutter/material.dart` library is
sufficient for the entire UI.

---

## 4. File Structure

```
example/
  lib/
    main.dart                        # Entry point; mounts KaraokeApp
    app.dart                         # KaraokeApp (MaterialApp wrapper)
    models/
      player_state.dart              # Immutable snapshot of playback + lyric state
    services/
      audio_service.dart             # Wraps just_audio; exposes streams & controls
      lyrics_service.dart            # Holds TtmlDocument; resolves active line/word
    screens/
      karaoke_screen.dart            # Root screen widget (Scaffold)
    widgets/
      lyrics_view.dart               # Scrollable full-screen lyric list
      lyric_line_widget.dart         # Renders one TtmlLine with word highlighting
      player_controls.dart           # Bottom player bar (seek, play/pause, times)
```

---

## 5. Initialisation Sequence

`main.dart` must call `WidgetsFlutterBinding.ensureInitialized()` before loading anything.

Inside `KaraokeApp` (or a dedicated `SplashScreen`) perform the following steps **before**
showing the player UI:

1. **Load TTML asset** — call `rootBundle.loadString('assets/heart_sutra_hu.ttml')`.
2. **Parse lyrics** — call `const TtmlParser().parse(ttmlContent)`, which returns a
   `TtmlDocument`. Store the document in `LyricsService`.
3. **Configure audio session** — obtain an `AudioSession` instance and call
   `audioSession.configure(const AudioSessionConfiguration.music())`.
4. **Load audio source** — call `AudioService.load('assets/heart_sutra_hu.mp3')` which
   internally calls `audioPlayer.setAsset(...)`.
5. **Mount the player UI** — once steps 1–4 have all completed successfully, navigate to
   `KaraokeScreen`. While loading, show a centered `CircularProgressIndicator` on a black
   background. On error, show the error message in white text.

---

## 6. Services

### 6.1 `LyricsService`

```dart
class LyricsService {
  LyricsService(this.document);
  final TtmlDocument document;

  /// Returns the single TtmlLine that is active at [position], or null if none.
  /// A line is active when line.begin <= position < line.end.
  TtmlLine? activeLine(Duration position);

  /// Returns the index of the active line in document.lines, or -1.
  int activeLineIndex(Duration position);

  /// Returns the agent for a given agentId, or null if not found.
  TtmlAgent? agentFor(String? agentId);
}
```

`LyricsService` is **stateless** — it holds the parsed `TtmlDocument` and exposes pure query
methods. It performs no scrolling or UI logic.

### 6.2 `AudioService`

```dart
class AudioService {
  Future<void> load(String assetPath);
  Future<void> play();
  Future<void> pause();
  Future<void> seekTo(Duration position);
  Future<void> dispose();

  Stream<Duration> get positionStream;      // emits current playback position
  Stream<bool>     get playingStream;       // emits true when playing
  Duration         get duration;            // total track duration (after load)
}
```

Internally wraps a `just_audio` `AudioPlayer`. The position stream should emit at a minimum
frequency of **4 times per second** (use `AudioPlayer.positionStream` directly — just_audio
emits every ~200 ms by default, which is sufficient).

---

## 7. State Model

```dart
@immutable
class PlayerState {
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final TtmlLine? activeLine;
  final int activeLineIndex;   // -1 when no line is active
}
```

`KaraokeScreen` creates a `StreamBuilder` over a combined stream that merges the position,
playing, and active-line data into a `PlayerState`. Use `rxdart`'s `Rx.combineLatest` **or**
a manual `StreamController` that listens to `positionStream` — either approach is acceptable,
but the chosen approach must not introduce extra dependencies beyond those listed in §3. A plain
`StreamBuilder<Duration>` on `positionStream` (re-deriving the rest synchronously on each
build) is the preferred simple approach.

---

## 8. Screen Layout — `KaraokeScreen`

```
┌─────────────────────────────────┐
│                                 │  ← Status bar (dark, transparent)
│                                 │
│         LYRICS VIEW             │  ← Expanded, takes all remaining space
│   (scrollable, full-screen)     │
│                                 │
│                                 │
├─────────────────────────────────┤
│         PLAYER CONTROLS         │  ← Fixed-height bottom bar (~160 dp)
└─────────────────────────────────┘
```

`Scaffold` properties:
- `backgroundColor: Colors.black`
- `extendBodyBehindAppBar: true`
- No `AppBar`.

The body is a `Column`:
- `Expanded` child: `LyricsView`
- Fixed child: `PlayerControls`

---

## 9. `LyricsView` Widget

### 9.1 Purpose

Displays all `TtmlLine` entries from the `TtmlDocument` in a vertically scrollable list.
Auto-scrolls so the **active line is centred** on screen whenever the active line changes.

### 9.2 Inputs

```dart
class LyricsView extends StatefulWidget {
  final TtmlDocument document;
  final Duration position;
  final int activeLineIndex;   // -1 when none
  final LyricsService lyricsService;
}
```

### 9.3 Scrolling Behaviour

- Use a `ScrollController` with one `GlobalKey` per lyric line.
- When `activeLineIndex` changes (compared to the previous build), call
  `Scrollable.ensureVisible(context, alignment: 0.5, duration: Duration(milliseconds: 400),
  curve: Curves.easeInOut)` on the key for the new active line.
- Do **not** scroll on every position tick — only scroll when the index changes.

### 9.4 List Contents

- Render every line in the document using `LyricLineWidget`.
- Add `SliverPadding` (or simple `Padding`) of `EdgeInsets.symmetric(vertical: 40)` above the
  first item and below the last item so lines can scroll to the centre of the screen.

---

## 10. `LyricLineWidget` Widget

This widget renders a single `TtmlLine` with per-word highlight animation.

### 10.1 Inputs

```dart
class LyricLineWidget extends StatelessWidget {
  final TtmlLine line;
  final Duration position;
  final bool isActive;      // true when this line is the currently active line
  final TtmlAgent? agent;   // resolved from LyricsService.agentFor(line.agentId)
}
```

### 10.2 Layout per Agent Type

Resolve layout from `agent.type` (or default to `"person"` when agent is `null`):

| `agent.type` | Alignment | Text style |
|---|---|---|
| `"person"` | `CrossAxisAlignment.start` (left) | Primary (see §10.3) |
| `"other"` | `CrossAxisAlignment.end` (right) | Secondary (see §10.3) |

Wrap each line in a `Padding` of `EdgeInsets.symmetric(horizontal: 24, vertical: 8)`.

### 10.3 Text Styles

**Inactive line:**
- `fontSize: 26`
- `fontWeight: FontWeight.w700`
- `color: Colors.white.withOpacity(0.35)`

**Active line — past or future word (within an active line):**
- `fontSize: 28`
- `fontWeight: FontWeight.w800`
- `color: Colors.white.withOpacity(0.45)` (unsung, pending words)

**Active line — currently singing word (progress-animated):**
- Render as a `Stack`:
  - Bottom layer: the word text in `color: Colors.white.withOpacity(0.45)` (unfilled)
  - Top layer: the word text in `color: Colors.white`, clipped by a `ClipRect` whose width is
    `word.text.length * charWidth * progress` (left-to-right fill animation)
  - `progress = ((position - word.begin).inMicroseconds /
     word.duration.inMicroseconds).clamp(0.0, 1.0)`

**Active line — already-sung word:**
- `color: Colors.white` (fully filled, no clip needed)

### 10.4 Word Rendering Algorithm

For each word in `line.words`:

1. Determine the word's **state**:
   - `sung`: `position >= word.end`
   - `singing`: `position >= word.begin && position < word.end`
   - `pending`: `position < word.begin`

2. Build the appropriate widget per state (see §10.3).

3. Append a `Text(' ')` spacer between consecutive words (or bake the space into the word
   text rendering).

4. Arrange all word widgets in a `Wrap` with `runSpacing: 4` so long lines reflow naturally.

### 10.5 Instrumental / Placeholder Lines

Line `L1` (agent `v2`) contains words whose text value is `"0"`. These are instrumental
placeholders. Render them as an animated ellipsis or a simple musical note icon
(`Icons.music_note`) in the secondary style rather than displaying the raw `"0"` text.

Detection: if every word in the line has `text == "0"`, treat the line as instrumental.

---

## 11. `PlayerControls` Widget

### 11.1 Inputs

```dart
class PlayerControls extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final ValueChanged<Duration> onSeek;
  final VoidCallback onPlayPause;
}
```

### 11.2 Visual Layout

```
┌────────────────────────────────────────────────────┐
│  Heart Sutra (Hungarian)          [album art icon] │  ← Track info row
│  ────────────────────────────────────────────────  │
│  0:00 ══════════════●─────────────────────── 5:26  │  ← Seek bar row
│              ⏮   ▶/⏸   ⏭                          │  ← Transport row
└────────────────────────────────────────────────────┘
```

- Background: `Colors.black.withOpacity(0.85)` with a `BackdropFilter` blur of sigma 20, OR
  simply a solid `Color(0xFF111111)` if blur causes performance concerns.
- Top padding respects `MediaQuery.of(context).padding.bottom` (safe area).

#### Track Info Row
- Leading: `Icon(Icons.music_note_rounded, color: Colors.white70, size: 40)`
- Title: `"Heart Sutra"` in `TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)`
- Subtitle: `"Hungarian Translation"` in `TextStyle(color: Colors.white54, fontSize: 13)`

#### Seek Bar Row
- Use a `SliderTheme`-wrapped `Slider`:
  - `value`: `position.inMilliseconds.toDouble()`
  - `min`: `0`
  - `max`: `duration.inMilliseconds.toDouble().clamp(1, double.infinity)`
  - `onChanged`: call `onSeek(Duration(milliseconds: value.round()))`
  - `activeColor: Colors.white`
  - `inactiveColor: Colors.white24`
  - `thumbColor: Colors.white`
- Below the slider, a `Row` with `MainAxisAlignment.spaceBetween` showing:
  - `_formatDuration(position)` on the left
  - `_formatDuration(duration)` on the right
  - Both in `TextStyle(color: Colors.white54, fontSize: 12)`

#### Transport Row
- Three `IconButton`s centred in a `Row`:
  - Skip-back: `Icons.skip_previous_rounded`, size 36 — seeks to `Duration.zero`
  - Play/Pause: `Icons.play_circle_filled_rounded` / `Icons.pause_circle_filled_rounded`,
    size 64, `color: Colors.white`
  - Skip-forward: `Icons.skip_next_rounded`, size 36 — seeks to `duration`

#### `_formatDuration` helper

```dart
String _formatDuration(Duration d) {
  final minutes = d.inMinutes.remainder(60);
  final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
```

---

## 12. Theming

The app uses a `ThemeData.dark()` base. Override:

```dart
ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Colors.black,
  colorScheme: ColorScheme.dark(
    primary: Colors.white,
    surface: Colors.black,
  ),
  sliderTheme: SliderThemeData(
    trackHeight: 3,
    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
    overlayShape: RoundSliderOverlayShape(overlayRadius: 14),
  ),
)
```

No custom fonts are required. The system default font (Roboto on Android, SF Pro on iOS) is
appropriate.

---

## 13. Rendering Guidance (from package §11)

The implementation **must** follow the four rendering rules stated in the package specification's
§11:

1. **Line activation** — display all lines where `line.begin <= t < line.end`.
2. **Word highlighting** — within an active line, highlight words where
   `word.begin <= t < word.end`; words before this range are fully highlighted (sung), words
   after are unhighlighted (pending).
3. **Voice differentiation** — `"person"` agents: primary style, left-aligned;
   `"other"` agents: secondary style, right-aligned.
4. **Sub-word progress** — compute `progress = (t - word.begin) / word.duration` clamped to
   `[0.0, 1.0]` and use it to drive a left-to-right fill animation on the word's text.

---

## 14. Error Handling

| Scenario | Behaviour |
|---|---|
| Asset not found | Show error screen: `"Failed to load lyrics: <error>"` in white on black |
| `TtmlParseException` thrown | Show error screen with the exception message |
| Audio load failure | Show error screen: `"Failed to load audio: <error>"` |
| Audio playback error | Log to console; show a `SnackBar` with the error message |

All error screens provide a **Retry** `TextButton` that re-runs the initialisation sequence.

---

## 15. Lifecycle Management

- `AudioService.dispose()` must be called in the `State.dispose()` of `KaraokeScreen`.
- The `ScrollController` must be disposed in the `State.dispose()` of `LyricsView`.
- Do not use `AudioPlayer` outside of `AudioService`.

---

## 16. Acceptance Criteria

The example is considered complete when:

1. The app launches to a loading indicator, then transitions to the karaoke screen without
   manual interaction.
2. Tapping Play starts audio. The seek bar advances in real time. Tapping Pause stops audio.
3. Dragging the seek bar seeks audio and the lyrics view immediately reflects the new position.
4. The active lyric line scrolls to the vertical centre of the screen automatically.
5. Words within the active line animate left-to-right from dim to white as they are sung.
6. Past words within the active line are rendered fully white; future words are dim.
7. Inactive lines above the active line are dim; inactive lines below are dim.
8. Line `L1` (instrumental, agent `v2`) renders as a music-note icon, not as `"0"` tokens.
9. Agent `v2` lines are right-aligned; agent `v1` lines are left-aligned.
10. `flutter analyze` in the `example/` directory reports zero errors and zero warnings.
11. The app runs correctly on iOS, Android, and macOS targets.
