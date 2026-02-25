## Implementation Plan: `ttml_parser` Flutter Package

### Current State

| Item | Status |
|------|--------|
| `pubspec.yaml` | Missing `xml: ^6.0.0` dependency |
| `lib/ttml_parser.dart` | Placeholder `Calculator` class |
| `test/ttml_parser_test.dart` | Placeholder test |
| `assets/heart_sutra.ttml` | ✅ Already present |

---

### Phase 1 — Dependencies & Project Setup

**File: `pubspec.yaml`**
- Add `xml: ^6.0.0` to `dependencies`
- Register `assets/heart_sutra.ttml` under the `flutter: assets:` section so it can be loaded in tests

Run `flutter pub get` after editing.

---

### Phase 2 — File Structure Scaffold

Create the following directory tree under `lib/`:

```/dev/null/structure.txt#L1-14
lib/
  ttml_parser.dart          ← replace Calculator placeholder
  src/
    models/
      ttml_document.dart
      ttml_agent.dart
      ttml_line.dart
      ttml_word.dart
    parser/
      ttml_parser.dart      ← replaces the public class
      time_parser.dart
    exceptions/
      ttml_parse_exception.dart
```

---

### Phase 3 — Exception Class

**File: `lib/src/exceptions/ttml_parse_exception.dart`**

Implements `TtmlParseException implements Exception` with:
- `final String message`
- `final Object? cause`
- `const TtmlParseException(this.message, {this.cause})`
- `toString()` that includes the message (and cause if present)

This is implemented first because every other layer depends on it.

---

### Phase 4 — Data Models (bottom-up)

#### 4a. `TtmlWord` — `lib/src/models/ttml_word.dart`
- `final Duration begin`
- `final Duration end`
- `final String text`
- Computed getter: `Duration get duration => end - begin`
- `const` constructor
- `==` / `hashCode` override (useful for tests)

#### 4b. `TtmlLine` — `lib/src/models/ttml_line.dart`
- `final Duration begin`
- `final Duration end`
- `final String? agentId`
- `final String? key`
- `final List<TtmlWord> words` — stored as `List.unmodifiable(...)`
- Computed getter: `String get text => words.map((w) => w.text).join(' ')`
- Computed getter: `Duration get duration => end - begin`
- `const`-friendly constructor

#### 4c. `TtmlAgent` — `lib/src/models/ttml_agent.dart`
- `final String id`
- `final String type`
- `const` constructor

#### 4d. `TtmlDocument` — `lib/src/models/ttml_document.dart`
- `final Duration? totalDuration`
- `final List<TtmlAgent> agents` — stored as `List.unmodifiable(...)`
- `final List<TtmlLine> lines` — stored as `List.unmodifiable(...)`
- Constructor-level unmodifiable wrapping

---

### Phase 5 — Time Parser

**File: `lib/src/parser/time_parser.dart`**

Internal-only helper (not exported). Implements the §6 algorithm:

1. Split on `":"`
2. Two parts → `MM:SS.mmm`; three parts → `HH:MM:SS.mmm`
3. Parse the last segment as a `double` (seconds + fraction), multiply by 1000, round to int → milliseconds
4. Parse preceding parts as `int` minutes (and optionally hours)
5. Compute `hours * 3_600_000 + minutes * 60_000 + milliseconds`
6. Return `Duration(milliseconds: total)`
7. Wrap any `FormatException` as `TtmlParseException`

Expose a single top-level function: `Duration parseTime(String s)`.

> **Edge cases to handle:** leading zeros on `MM` and `SS` (standard `int.parse` handles these), three-digit milliseconds (after the `double` multiply-and-round), and an invalid segment count (1 or 4+ colons → throw).

---

### Phase 6 — Main Parser

**File: `lib/src/parser/ttml_parser.dart`**

`class TtmlParser { const TtmlParser(); TtmlDocument parse(String ttmlContent); }`

Follows the §5 algorithm exactly:

| Step | Details |
|------|---------|
| **1. Parse XML** | `XmlDocument.parse(ttmlContent)` — wrap `XmlParserException` → `TtmlParseException` |
| **2. Find `<tt>`** | `doc.findElements('tt')` (or using the TTML namespace URI). Throw if absent. |
| **3. Extract agents** | Traverse `tt > head > metadata`, find `ttm:agent` elements. Read `xml:id` and `type`. Both required. Namespace-aware attribute lookup needed (`xml:id` is in the XML namespace `http://www.w3.org/XML/1998/namespace`). |
| **4. Body `dur`** | Read `dur` attribute on `<body>`. Parse with `parseTime()` if present; else `null`. |
| **5. Collect `<p>`** | Iterate all `<div>` children of `<body>`, collect their `<p>` children in document order. |
| **6. Parse `<p>` → `TtmlLine`** | Read `begin` (required), `end` (required), `ttm:agent` (optional), `itunes:key` (optional). Namespace-aware lookups for the prefixed attributes. |
| **7. Parse `<span>` → `TtmlWord`** | Direct child `<span>` elements only. Read `begin`/`end` (required), trim text content, discard if empty. |
| **8. Assemble** | Return `TtmlDocument(totalDuration, agents, lines)` |

**Namespace handling note:** The `xml` package requires namespace-aware lookups. Prefixed attributes like `ttm:agent`, `itunes:key`, and `xml:id` must be looked up by their full namespace URI, not just by prefix string. Key URIs:
- `xml:id` → namespace `http://www.w3.org/XML/1998/namespace`, local name `id`
- `ttm:agent` → namespace `http://www.w3.org/ns/ttml#metadata`, local name `agent`
- `itunes:key` → namespace `http://music.apple.com/lyric-ttml-internal`, local name `key`
- `ttm:agent` element → namespace `http://www.w3.org/ns/ttml#metadata`, local name `agent`

---

### Phase 7 — Barrel Export

**File: `lib/ttml_parser.dart`** (replace the placeholder)

```ttml_parser/lib/ttml_parser.dart#L1-6
export 'src/models/ttml_document.dart';
export 'src/models/ttml_agent.dart';
export 'src/models/ttml_line.dart';
export 'src/models/ttml_word.dart';
export 'src/parser/ttml_parser.dart';
export 'src/exceptions/ttml_parse_exception.dart';
```

`time_parser.dart` is **not** exported (internal only).

---

### Phase 8 — Tests

**File: `test/ttml_parser_test.dart`** (replace the placeholder)

Tests load `heart_sutra.ttml` via `File('assets/heart_sutra.ttml').readAsStringSync()` (since this is a package test, not a widget test, we can use `dart:io` directly without asset bundle overhead).

Organised into six `group` blocks matching §10:

| Group | Key assertions |
|-------|---------------|
| **10.1 Document-level** | Parse succeeds; `totalDuration` == 5m 26s 915ms; 2 agents; `v1` is `"person"`; `v2` is `"other"`; lines non-empty |
| **10.2 Line-level** | Line with `key == "L2"`: `begin` == 7s 733ms; `end` == 41s 898ms; `agentId == "v1"`; 5 words; first word text == `"Mahá"`; `text` getter == full sentence |
| **10.3 Word-level** | First word of L2: `begin` == 7s 733ms; `end` == 12s 124ms; `duration` == 4s 391ms |
| **10.4 Time-parser** | Six inline strings (including `HH:MM:SS.mmm`); invalid string throws |
| **10.5 Error-handling** | Malformed XML throws; `<p>` without `begin` throws; `<p>` without `end` throws; `<span>` without `begin` throws; `<ttm:agent>` without `xml:id` throws; no `<p>` → empty lines list |
| **10.6 Whitespace** | Space text-nodes between spans not parsed as words; span text is trimmed; whitespace-only span is discarded |

> **Note:** Time-parser tests call `parseTime()` from `lib/src/parser/time_parser.dart` directly — since it's internal, the test file imports it directly by path (`import 'package:ttml_parser/src/parser/time_parser.dart'`).

---

### Implementation Order (Recommended)

```/dev/null/order.txt#L1-9
1. pubspec.yaml              → add xml dep + asset registration
2. flutter pub get
3. ttml_parse_exception.dart → no dependencies
4. ttml_word.dart            → no dependencies
5. ttml_agent.dart           → no dependencies
6. ttml_line.dart            → depends on TtmlWord
7. ttml_document.dart        → depends on TtmlAgent, TtmlLine
8. time_parser.dart          → depends on TtmlParseException
9. ttml_parser.dart (src)    → depends on everything above
10. ttml_parser.dart (lib)   → barrel export
11. ttml_parser_test.dart    → replaces placeholder
```

---

### Acceptance Checklist

- [ ] `flutter pub get` succeeds
- [ ] `flutter analyze` → zero errors, zero warnings
- [ ] `flutter test` → all §10 tests pass
- [ ] Public API exports exactly: `TtmlDocument`, `TtmlAgent`, `TtmlLine`, `TtmlWord`, `TtmlParser`, `TtmlParseException`
- [ ] `TtmlParser` holds no mutable state between calls
- [ ] `heart_sutra.ttml` round-trips correctly (58 lines, correct timing on all words)
