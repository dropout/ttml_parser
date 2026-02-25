# Karaoke Example App — Implementation Plan

## Current State

- The package (`ttml_parser`) is fully implemented with `TtmlParser`, `TtmlDocument`, `TtmlLine`, `TtmlWord`, and `TtmlAgent`.
- `example/assets/heart_sutra_hu.ttml` and `.mp3` already exist.
- `example/lib/main.dart` is the default Flutter counter stub — everything must be replaced.
- `example/pubspec.yaml` has no relevant dependencies and no asset declarations.

---

## Phase 1 — `pubspec.yaml` Setup

**File:** `example/pubspec.yaml`

Two changes:

1. **Add dependencies** under `dependencies:`:
```/dev/null/pubspec.yaml#L1-6
ttml_parser:
  path: ../
just_audio: ^0.9.0
audio_session: ^0.1.0
```

2. **Declare assets** under `flutter:`:
```/dev/null/pubspec.yaml#L1-3
assets:
  - assets/heart_sutra_hu.ttml
  - assets/heart_sutra_hu.mp3
```

Then run `flutter pub get` in `example/`.

---

## Phase 2 — Directory Scaffold

Create the following directories inside `example/lib/`:

```/dev/null/tree.txt#L1-7
models/
services/
screens/
widgets/
```

---

## Phase 3 — Models

### `example/lib/models/player_state.dart`

An `@immutable` value class. All fields are final. No logic:

```/dev/null/player_state.dart#L1-10
@immutable
class PlayerState {
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final TtmlLine? activeLine;
  final int activeLineIndex; // -1 when none
}
```

Uses `package:flutter/foundation.dart` for `@immutable`. No business logic here.

---

## Phase 4 — Services

### `example/lib/services/lyrics_service.dart`

Stateless. Holds the parsed `TtmlDocument` and exposes three pure query methods:

| Method | Returns |
|--------|---------|
| `activeLine(Duration)` | The `TtmlLine` where `begin <= t < end`, or `null` |
| `activeLineIndex(Duration)` | Index in `document.lines`, or `-1` |
| `agentFor(String?)` | The `TtmlAgent` matching the id, or `null` |

Implementation of `activeLineIndex` uses a simple linear scan — the document has ≤58 lines so O(n) is fine. For robustness, it could also use binary search on `begin` if we ever want it.

### `example/lib/services/audio_service.dart`

Wraps `just_audio`'s `AudioPlayer`. Key design decisions:

- Constructor creates the `AudioPlayer` privately.
- `load(String assetPath)` calls `_player.setAsset(assetPath)` and caches `duration`.
- `positionStream` is exposed directly from `_player.positionStream` (emits ~every 200 ms — sufficient for 4× per second requirement from §6.2).
- `playingStream` exposes `_player.playingStream`.
- `duration` getter returns the cached `Duration` after load.
- `dispose()` calls `_player.dispose()`.

---

## Phase 5 — Entry Points

### `example/lib/main.dart`

Minimal. Calls `WidgetsFlutterBinding.ensureInitialized()`, then `runApp(const KaraokeApp())`.

### `example/lib/app.dart`

`KaraokeApp` is a `StatefulWidget` that orchestrates the initialization sequence:

1. `initState` triggers an async `_initialize()` method.
2. `_initialize()` runs the five steps from §5 in order:
   - Load TTML string via `rootBundle.loadString(...)`.
   - Parse with `const TtmlParser().parse(ttmlContent)` → `TtmlDocument`.
   - Build `LyricsService(document)`.
   - Build `AudioService()`.
   - Configure `AudioSession` → `.music()`.
   - `audioService.load('assets/heart_sutra_hu.mp3')`.
3. Holds `_state` as `AsyncSnapshot`-like: loading / loaded / error.
4. `build` returns a `MaterialApp` with the dark theme from §12, whose `home` is:
   - `CircularProgressIndicator` (centered, black bg) while loading.
   - `KaraokeScreen(lyricsService, audioService)` when loaded.
   - Error screen with message + `Retry` button on failure.
5. A **Retry** button calls `setState(() { _state = loading; })` then re-runs `_initialize()`.

**Theme** (from §12):
```/dev/null/theme.dart#L1-11
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

---

## Phase 6 — `KaraokeScreen`

**File:** `example/lib/screens/karaoke_screen.dart`

`StatefulWidget`. Receives `LyricsService` and `AudioService`.

**`initState`:** subscribes to `audioService.positionStream`.

**`dispose`:** cancels subscription, calls `audioService.dispose()`.

**`build`:** wraps in a `StreamBuilder<Duration>` on `positionStream`. On each position tick:
- Calls `lyricsService.activeLineIndex(position)` synchronously.
- Calls `lyricsService.activeLine(position)` synchronously.
- Builds a `PlayerState` on the fly (no separate stream merge needed).

**Scaffold:**
- `backgroundColor: Colors.black`
- `extendBodyBehindAppBar: true`
- No `AppBar`
- Body is a `Column`:
  - `Expanded`: `LyricsView(...)`
  - Fixed height: `PlayerControls(...)`

**Callbacks passed down:**
- `onSeek`: calls `audioService.seekTo(d)`
- `onPlayPause`: calls `audioService.play()` or `audioService.pause()` based on current `isPlaying`

---

## Phase 7 — `LyricsView`

**File:** `example/lib/widgets/lyrics_view.dart`

`StatefulWidget`. Fields from §9.2: `document`, `position`, `activeLineIndex`, `lyricsService`.

**State fields:**
- `ScrollController _scrollController`
- `List<GlobalKey> _keys` — one per line, created in `initState`
- `int _lastActiveIndex = -1`

**`initState`:** creates `_scrollController` and `_keys`.

**`dispose`:** disposes `_scrollController`.

**`didUpdateWidget`:** when `activeLineIndex != _lastActiveIndex`, schedules a post-frame callback that calls `Scrollable.ensureVisible` on `_keys[activeLineIndex]` with `alignment: 0.5`, `duration: 400ms`, `curve: Curves.easeInOut`. Updates `_lastActiveIndex`.

**`build`:** `ListView` (or `CustomScrollView`) containing:
- `SizedBox(height: 40)` top padding
- One `LyricLineWidget` per `document.lines[i]`, keyed with `_keys[i]`
- `SizedBox(height: 40)` bottom padding

Each `LyricLineWidget` receives:
- `line: document.lines[i]`
- `position: position`
- `isActive: i == activeLineIndex`
- `agent: lyricsService.agentFor(line.agentId)`

---

## Phase 8 — `LyricLineWidget`

**File:** `example/lib/widgets/lyric_line_widget.dart`

`StatelessWidget`. No animation controllers needed — all visuals are driven purely by `position`.

**Instrumental detection:** `bool _isInstrumental(TtmlLine) => line.words.every((w) => w.text == '0')`.

**Layout structure:**
```
Padding(h:24, v:8)
  └─ Column(crossAxisAlignment: start|end based on agent.type)
       └─ Wrap(runSpacing: 4)
            └─ [word widgets...]
```

**Per-word widget factory** (`_buildWord(word, position, isActive)`):
- Compute state: `sung` / `singing` / `pending` (or `inactive` if `!isActive`).
- **Inactive line:** `Text(word.text, style: TextStyle(fontSize:26, fontWeight:w700, color: white.withOpacity(0.35)))`
- **Active pending:** `Text(..., style: TextStyle(fontSize:28, fontWeight:w800, color: white.withOpacity(0.45)))`
- **Active sung:** `Text(..., style: TextStyle(fontSize:28, fontWeight:w800, color: white))`
- **Active singing:** `Stack` with two `Text` layers — bottom is `0.45` opacity, top is full white clipped with `ClipRect` + `Align(alignment: Alignment.centerLeft, widthFactor: progress)`. `progress = ((position - word.begin).inMicroseconds / word.duration.inMicroseconds).clamp(0.0, 1.0)`.

**Instrumental rendering:** replaces the whole `Wrap` with a `Row` containing `Icon(Icons.music_note, color: Colors.white54)` in the appropriate alignment.

---

## Phase 9 — `PlayerControls`

**File:** `example/lib/widgets/player_controls.dart`

`StatelessWidget`. Inputs from §11.1.

**Background:** `Container(color: Color(0xFF111111))` (solid, avoids any `BackdropFilter` performance concerns).

**Safe area:** wrap in `Padding(bottom: MediaQuery.of(context).padding.bottom)`.

**Internal column (3 rows):**

1. **Track info row** — `ListTile`-style with `Icon(Icons.music_note_rounded)` leading, title `"Heart Sutra"`, subtitle `"Hungarian Translation"`.
2. **Seek bar row** — `SliderTheme`-wrapped `Slider` with `activeColor: Colors.white`, `inactiveColor: Colors.white24`, and a `Row` below it showing `_formatDuration(position)` left and `_formatDuration(duration)` right.
3. **Transport row** — `Row(mainAxisAlignment: center)` with three `IconButton`s: skip-back (→ `Duration.zero`), play/pause (64px), skip-forward (→ `duration`).

`_formatDuration` is a private top-level helper as specified in §11 of the spec.

---

## Phase 10 — Error Handling

Every error screen (in `app.dart`) must:
- Show the error message in `TextStyle(color: Colors.white)` centered on a `Colors.black` scaffold.
- Show a `TextButton("Retry", ...)` that re-runs `_initialize()`.

Playback errors (stream errors from `just_audio`) are caught in `KaraokeScreen` and shown via `ScaffoldMessenger.of(context).showSnackBar(...)`.

---

## Implementation Order (recommended)

| Step | Task | Risk |
|------|------|------|
| 1 | Update `pubspec.yaml`, run `flutter pub get` | Low |
| 2 | Create directory structure | Trivial |
| 3 | `player_state.dart` | Trivial |
| 4 | `lyrics_service.dart` | Low |
| 5 | `audio_service.dart` | Medium (just_audio API) |
| 6 | `main.dart` + `app.dart` (init + loading UI) | Medium |
| 7 | `karaoke_screen.dart` (StreamBuilder skeleton) | Medium |
| 8 | `player_controls.dart` | Low |
| 9 | `lyric_line_widget.dart` (word states + Stack clip) | High (most nuanced) |
| 10 | `lyrics_view.dart` (scroll logic) | Medium |
| 11 | Wire everything together, smoke-test | — |
| 12 | `flutter analyze` in `example/`, fix all warnings | — |

The `lyric_line_widget.dart` word-clipping animation (the `Stack`/`ClipRect`/`Align(widthFactor:)` pattern) is the single most complex piece — it should be built and tested in isolation before integrating into `LyricsView`.

---

## Key Technical Notes

- **No `rxdart`** — use a plain `StreamBuilder<Duration>` on `positionStream` and derive `PlayerState` synchronously inside `build`, as §7 suggests.
- **`Align(widthFactor: progress)`** is the idiomatic Flutter way to clip a child to a fraction of its natural width without needing `CustomPainter` — cleaner than a raw `ClipRect` with a `Size` calculation.
- **`Scrollable.ensureVisible`** requires the key's `BuildContext`, not the key itself — call it via `_keys[i].currentContext!`.
- **`just_audio` on macOS** requires network entitlements in `macos/Runner/DebugProfile.entitlements` and `Release.entitlements` (`com.apple.security.network.client = true`) if it tries to fetch anything remotely — but since we're using a local asset, this should not be an issue.
- **`audio_session`** only needs to be configured once (in `_initialize`). It does not need to be disposed.
