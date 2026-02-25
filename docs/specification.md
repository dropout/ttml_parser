# TTML Parser Package Specification

## 1. Overview

This document specifies the implementation of a Dart/Flutter package named `ttml_parser` that parses TTML (Timed Text Markup Language) files and returns a structured data model suitable for rendering karaoke-style lyrics in a Flutter mobile application.

The parser targets the Apple Music lyric TTML dialect (identified by `itunes:timing="Word"`), which provides word-level timing for each lyric line. The output data model exposes timing information at both the line and word level, enabling smooth karaoke-style highlight animations.

---

## 2. TTML Format Reference

### 2.1 Namespaces

The following XML namespaces appear in the target TTML files:

| Prefix | URI | Purpose |
|--------|-----|---------|
| _(default)_ | `http://www.w3.org/ns/ttml` | Core TTML elements |
| `ttm` | `http://www.w3.org/ns/ttml#metadata` | TTML metadata extensions |
| `amll` | `http://www.example.com/ns/amll` | AMLL extensions (ignored by this parser) |
| `itunes` | `http://music.apple.com/lyric-ttml-internal` | Apple Music extensions |

### 2.2 Document Structure

```ttml_parser/assets/heart_sutra.ttml#L1-1
<tt xmlns="http://www.w3.org/ns/ttml"
    xmlns:ttm="http://www.w3.org/ns/ttml#metadata"
    xmlns:itunes="http://music.apple.com/lyric-ttml-internal"
    itunes:timing="Word">
  <head>
    <metadata>
      <ttm:agent type="person" xml:id="v1"/>
      <ttm:agent type="other"  xml:id="v2"/>
    </metadata>
  </head>
  <body dur="05:26.915">
    <div begin="00:01.448" end="05:26.915">
      <p begin="00:07.733" end="00:41.898"
         ttm:agent="v1"
         itunes:key="L2">
        <span begin="00:07.733" end="00:12.124">Mahá</span>
        <span begin="00:12.814" end="00:18.949">Prádzsnyá</span>
        <span begin="00:19.107" end="00:27.700">Párámitá</span>
      </p>
    </div>
  </body>
</tt>
```

### 2.3 Key Elements and Attributes

#### `<tt>` (root)
| Attribute | Required | Description |
|-----------|----------|-------------|
| `itunes:timing` | No | When `"Word"`, word-level timing is present on each `<span>` |

#### `<ttm:agent>` (inside `<head><metadata>`)
| Attribute | Required | Description |
|-----------|----------|-------------|
| `xml:id` | Yes | Unique agent identifier (e.g., `"v1"`) |
| `type` | Yes | One of `"person"` or `"other"` |

#### `<body>`
| Attribute | Required | Description |
|-----------|----------|-------------|
| `dur` | No | Total duration of the lyric track |

#### `<div>`
| Attribute | Required | Description |
|-----------|----------|-------------|
| `begin` | No | Start time of this section |
| `end` | No | End time of this section |

#### `<p>` (one lyric line)
| Attribute | Required | Description |
|-----------|----------|-------------|
| `begin` | Yes | Line start time |
| `end` | Yes | Line end time |
| `ttm:agent` | No | Reference to an agent `xml:id` |
| `itunes:key` | No | Unique line key (e.g., `"L1"`) |

#### `<span>` (one word or syllable within a line)
| Attribute | Required | Description |
|-----------|----------|-------------|
| `begin` | Yes | Word start time |
| `end` | Yes | Word end time |

The text content of each `<span>` is the word or syllable to display.

### 2.4 Time Format

All time values follow the pattern `[HH:]MM:SS.mmm`:

- `HH` — hours (optional)
- `MM` — two-digit minutes
- `SS` — two-digit seconds
- `mmm` — three-digit milliseconds

Examples:
- `"00:07.500"` → 7 seconds, 500 ms → 7500 ms
- `"01:04.097"` → 1 minute, 4 seconds, 97 ms → 64097 ms
- `"05:26.915"` → 5 minutes, 26 seconds, 915 ms → 326915 ms

### 2.5 Whitespace Between Spans

`<span>` elements within a `<p>` are frequently separated by literal space characters (plain text nodes in the XML). These text nodes must be **ignored** during parsing; spacing between displayed words is a concern of the rendering layer, not the parser.

### 2.6 Agent Types

| Type | Meaning | Suggested rendering |
|------|---------|---------------------|
| `"person"` | A human vocalist | Primary lyric colour; left-aligned |
| `"other"` | Background vocals, choir, etc. | Secondary colour; right-aligned or smaller |

---

## 3. Output Data Model

All classes are immutable (every field is `final`). All durations are represented as Dart `Duration` objects.

### 3.1 Class Hierarchy

```/dev/null/diagram.txt#L1-7
TtmlDocument
├── totalDuration : Duration
├── agents        : List<TtmlAgent>
└── lines         : List<TtmlLine>
                       ├── begin, end : Duration
                       ├── agentId    : String?
                       ├── key        : String?
                       └── words      : List<TtmlWord>
                                          ├── begin, end : Duration
                                          └── text       : String
```

### 3.2 `TtmlDocument`

```/dev/null/model.dart#L1-10
class TtmlDocument {
  /// Total playback duration of the track, sourced from <body dur="…">.
  /// Null when the attribute is absent.
  final Duration? totalDuration;

  /// All agents declared in <head><metadata>.
  final List<TtmlAgent> agents;

  /// All lyric lines in document order.
  final List<TtmlLine> lines;
}
```

### 3.3 `TtmlAgent`

```/dev/null/model.dart#L12-20
class TtmlAgent {
  /// The value of xml:id on the <ttm:agent> element (e.g. "v1").
  final String id;

  /// The value of the type attribute (e.g. "person" or "other").
  final String type;
}
```

### 3.4 `TtmlLine`

```/dev/null/model.dart#L22-42
class TtmlLine {
  /// Timestamp at which this line begins, from the begin attribute of <p>.
  final Duration begin;

  /// Timestamp at which this line ends, from the end attribute of <p>.
  final Duration end;

  /// The xml:id of the ttm:agent responsible for this line.
  /// Null when the ttm:agent attribute is absent from the <p> element.
  final String? agentId;

  /// The value of the itunes:key attribute (e.g. "L1", "L42").
  /// Null when the attribute is absent.
  final String? key;

  /// The words (or syllables) that make up this line, in document order.
  final List<TtmlWord> words;
}
```

Convenience getters that SHOULD be implemented on `TtmlLine`:

| Getter | Return type | Description |
|--------|-------------|-------------|
| `text` | `String` | All `word.text` values joined with a single space |
| `duration` | `Duration` | `end - begin` |

### 3.5 `TtmlWord`

```/dev/null/model.dart#L44-56
class TtmlWord {
  /// Timestamp at which this word begins, from the begin attribute of <span>.
  final Duration begin;

  /// Timestamp at which this word ends, from the end attribute of <span>.
  final Duration end;

  /// The raw text content of the <span> element, trimmed of leading/trailing
  /// whitespace. Never empty; spans whose trimmed text is empty are discarded.
  final String text;
}
```

Convenience getters that SHOULD be implemented on `TtmlWord`:

| Getter | Return type | Description |
|--------|-------------|-------------|
| `duration` | `Duration` | `end - begin` |

---

## 4. Parser API

### 4.1 `TtmlParser`

```/dev/null/parser.dart#L1-14
class TtmlParser {
  const TtmlParser();

  /// Parses a TTML document from its raw XML string.
  ///
  /// Throws [TtmlParseException] if the input is not valid XML or if required
  /// TTML attributes are missing or malformed.
  ///
  /// Returns a fully populated [TtmlDocument]. The [TtmlDocument.lines] list
  /// is in document order and is never null (may be empty).
  TtmlDocument parse(String ttmlContent);
}
```

The parser MUST be stateless; the same `TtmlParser` instance MUST be reusable across multiple calls to `parse`.

### 4.2 `TtmlParseException`

```/dev/null/exception.dart#L1-10
class TtmlParseException implements Exception {
  /// Human-readable description of what went wrong.
  final String message;

  /// The original exception that caused this error, if any.
  final Object? cause;

  const TtmlParseException(this.message, {this.cause});
}
```

---

## 5. Parsing Algorithm

The implementation MUST follow these steps, in order:

### Step 1 — Parse XML
Use Dart's `xml` package (available on pub.dev) to parse the raw string into a DOM. If parsing fails, wrap and rethrow as `TtmlParseException`.

### Step 2 — Locate the root `<tt>` element
Find the single `<tt>` element in the document. Throw `TtmlParseException` if absent.

### Step 3 — Extract agents from `<head>`
Traverse `tt > head > metadata > ttm:agent` elements. For each element, read `xml:id` (mapped to `TtmlAgent.id`) and `type` (mapped to `TtmlAgent.type`). Both attributes are required; throw `TtmlParseException` if either is missing. Collect results into a list preserving document order.

### Step 4 — Extract total duration from `<body>`
Read the `dur` attribute on the `<body>` element. If present, parse it with the time-parsing algorithm (§6). Store as `TtmlDocument.totalDuration`. If absent, store `null`.

### Step 5 — Collect all `<p>` elements
Descend into `body > div` (one or more `<div>` elements may exist). Collect every `<p>` element from all `<div>` children, preserving document order.

### Step 6 — Parse each `<p>` into a `TtmlLine`
For each `<p>` element:

1. Read and parse `begin` — **required**; throw `TtmlParseException` if absent or unparseable.
2. Read and parse `end` — **required**; throw `TtmlParseException` if absent or unparseable.
3. Read `ttm:agent` — optional; store as `TtmlLine.agentId` or `null`.
4. Read `itunes:key` — optional; store as `TtmlLine.key` or `null`.
5. Collect child `<span>` elements (ignoring text nodes and other element types — see §5 Step 7).
6. Construct a `TtmlLine`.

### Step 7 — Parse each `<span>` into a `TtmlWord`
For each direct child `<span>` of the `<p>`:

1. Read and parse `begin` — **required**; throw `TtmlParseException` if absent or unparseable.
2. Read and parse `end` — **required**; throw `TtmlParseException` if absent or unparseable.
3. Read the element's text content and trim whitespace.
4. **Discard** the span if the trimmed text is empty.
5. Otherwise, construct a `TtmlWord`.

### Step 8 — Assemble and return
Assemble the `TtmlDocument` from the collected agents, total duration, and lines. Return it to the caller.

---

## 6. Time-Parsing Algorithm

Given a time string `s`:

1. Split `s` on `":"`.
2. If two parts result → format is `MM:SS.mmm` (no hours component).
3. If three parts result → format is `HH:MM:SS.mmm`.
4. Parse the final part as a `double` (seconds with fractional milliseconds); convert to milliseconds by multiplying by 1000 and rounding to the nearest integer.
5. Parse the preceding part as integer minutes (and optionally the part before that as integer hours).
6. Compute total milliseconds: `hours * 3_600_000 + minutes * 60_000 + milliseconds`.
7. Return `Duration(milliseconds: total)`.
8. If any step fails, throw `TtmlParseException` with the offending string.

---

## 7. File Structure

The package MUST be structured as follows:

```/dev/null/structure.txt#L1-14
lib/
  ttml_parser.dart          ← public barrel export
  src/
    models/
      ttml_document.dart    ← TtmlDocument
      ttml_agent.dart       ← TtmlAgent
      ttml_line.dart        ← TtmlLine
      ttml_word.dart        ← TtmlWord
    parser/
      ttml_parser.dart      ← TtmlParser
      time_parser.dart      ← internal time-parsing helper
    exceptions/
      ttml_parse_exception.dart  ← TtmlParseException
```

All `src/` contents are private to the package. Only the following symbols MUST be exported from `ttml_parser.dart`:

- `TtmlDocument`
- `TtmlAgent`
- `TtmlLine`
- `TtmlWord`
- `TtmlParser`
- `TtmlParseException`

---

## 8. Dependencies

Add the following to `pubspec.yaml`:

```/dev/null/pubspec_fragment.yaml#L1-3
dependencies:
  xml: ^6.0.0   # XML parsing
  flutter:
    sdk: flutter
```

No other third-party dependencies are permitted.

---

## 9. Error Handling Summary

| Situation | Behaviour |
|-----------|-----------|
| Input string is not valid XML | Throw `TtmlParseException` |
| `<tt>` root element not found | Throw `TtmlParseException` |
| `<ttm:agent>` missing `xml:id` or `type` | Throw `TtmlParseException` |
| `<p>` missing `begin` or `end` | Throw `TtmlParseException` |
| `<span>` missing `begin` or `end` | Throw `TtmlParseException` |
| Time string in unrecognised format | Throw `TtmlParseException` |
| `<body>` missing `dur` | Store `null`; do not throw |
| `<p>` missing `ttm:agent` | Store `null`; do not throw |
| `<p>` missing `itunes:key` | Store `null`; do not throw |
| `<span>` with empty text content | Discard silently |
| No `<p>` elements in document | Return `TtmlDocument` with empty `lines` list |

---

## 10. Test Requirements

Tests MUST be placed in `test/ttml_parser_test.dart` and MUST cover the following scenarios using the bundled `assets/heart_sutra.ttml` file as well as inline XML strings:

### 10.1 Document-level tests
- Parsing `heart_sutra.ttml` succeeds without throwing.
- `TtmlDocument.totalDuration` equals `Duration(minutes: 5, seconds: 26, milliseconds: 915)`.
- `TtmlDocument.agents` has exactly two entries.
- Agent `"v1"` has type `"person"`.
- Agent `"v2"` has type `"other"`.
- `TtmlDocument.lines` is non-empty.

### 10.2 Line-level tests (using `heart_sutra.ttml`)
- The second `<p>` (key `"L2"`) has `begin` equal to `Duration(seconds: 7, milliseconds: 733)`.
- The second `<p>` (key `"L2"`) has `end` equal to `Duration(seconds: 41, milliseconds: 898)`.
- The second `<p>` (key `"L2"`) has `agentId` equal to `"v1"`.
- The second `<p>` (key `"L2"`) has exactly five words.
- The first word of line `"L2"` has `text` equal to `"Mahá"`.
- The `text` convenience getter on line `"L2"` equals `"Mahá Prádzsnyá Párámitá Hridájá Szútra"`.

### 10.3 Word-level tests
- The first word of line `"L2"` has `begin` equal to `Duration(seconds: 7, milliseconds: 733)`.
- The first word of line `"L2"` has `end` equal to `Duration(seconds: 12, milliseconds: 124)`.
- The `duration` convenience getter on that word equals `Duration(seconds: 4, milliseconds: 391)`.

### 10.4 Time-parser unit tests (using inline strings)
- `"00:00.000"` → `Duration.zero`
- `"00:07.500"` → `Duration(seconds: 7, milliseconds: 500)`
- `"01:04.097"` → `Duration(minutes: 1, seconds: 4, milliseconds: 97)`
- `"05:26.915"` → `Duration(minutes: 5, seconds: 26, milliseconds: 915)`
- `"01:02:03.456"` → `Duration(hours: 1, minutes: 2, seconds: 3, milliseconds: 456)`
- An invalid string (e.g., `"abc"`) throws `TtmlParseException`.

### 10.5 Error-handling tests (using inline XML strings)
- Malformed XML throws `TtmlParseException`.
- A `<p>` missing `begin` throws `TtmlParseException`.
- A `<p>` missing `end` throws `TtmlParseException`.
- A `<span>` missing `begin` throws `TtmlParseException`.
- A `<ttm:agent>` missing `xml:id` throws `TtmlParseException`.
- A document with no `<p>` elements returns an empty `lines` list without throwing.

### 10.6 Whitespace-handling tests
- Literal space text nodes between `<span>` elements are not parsed as words.
- Leading/trailing whitespace in `<span>` text content is trimmed.
- A `<span>` whose text content is only whitespace is discarded.

---

## 11. Rendering Guidance (Non-Normative)

This section is informational and does not affect the parser implementation.

A karaoke renderer consuming `TtmlDocument` can use the following approach:

1. **Line activation**: At playback position `t`, display all lines where `line.begin <= t < line.end`. Lines outside this window may be shown as upcoming or past lyrics.

2. **Word highlighting**: Within an active line, highlight each word where `word.begin <= t < word.end`. Words before this range are fully highlighted (sung); words after are unhighlighted (pending).

3. **Voice differentiation**: Use `line.agentId` to look up the corresponding `TtmlAgent`. Render `"person"` agents with the primary lyric style (e.g., left-aligned, white fill) and `"other"` agents with a secondary style (e.g., right-aligned, grey fill).

4. **Progress within a word**: For smooth sub-word animation, compute `progress = (t - word.begin) / word.duration` (clamped to `[0.0, 1.0]`) and use it to drive a fill or clip animation on the word's text widget.

---

## 12. Sample Data

The file `assets/heart_sutra.ttml` is bundled with the package for use in tests. It contains a Hungarian translation of the Heart Sutra set to music, with word-level timing across 58 lyric lines (`L1`–`L58`). Line `L1` (agent `v2`) is an instrumental placeholder whose span text values are all `"0"` and must be parsed without special-casing.

---

## 13. Acceptance Criteria

The implementation is considered complete when:

1. All tests described in §10 pass with `flutter test`.
2. `flutter analyze` reports zero errors and zero warnings.
3. The public API surface matches exactly the symbols listed in §7.
4. The parser correctly round-trips the bundled `heart_sutra.ttml` file: every line and every word is present, in order, with correct timing.
5. No mutable state is held by `TtmlParser` between calls to `parse`.