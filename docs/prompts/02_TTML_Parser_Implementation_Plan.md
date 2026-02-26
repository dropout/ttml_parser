## User

Let's create an implementation plan for the Flutter package described in the [@specification.md](file:///Users/adam/Projects/ttml_parser/specification.md) document.

**Tool Call: Read file `specification.md`**
Status: Completed

```json
{
  "Text": "SUCCESS: File outline retrieved. This file is too large to read all at once, so the outline below shows the file's structure with line numbers.\n\nIMPORTANT: Do NOT retry this call without line numbers - you will get the same outline.\nInstead, use the line numbers below to read specific sections by calling this tool again with start_line and end_line parameters.\n\n# File outline for /Users/adam/Projects/ttml_parser/specification.md\n\n# TTML Parser Package Specification [L1-456]\n ## 1. Overview [L3-11]\n ## 2. TTML Format Reference [L11-118]\n  ### 2.1 Namespaces [L13-24]\n  ### 2.2 Document Structure [L24-51]\n  ### 2.3 Key Elements and Attributes [L51-91]\n   #### `<tt>` (root) [L53-58]\n   #### `<ttm:agent>` (inside `<head><metadata>`) [L58-64]\n   #### `<body>` [L64-69]\n   #### `<div>` [L69-75]\n   #### `<p>` (one lyric line) [L75-83]\n   #### `<span>` (one word or syllable within a line) [L83-91]\n  ### 2.4 Time Format [L91-105]\n  ### 2.5 Whitespace Between Spans [L105-109]\n  ### 2.6 Agent Types [L109-118]\n ## 3. Output Data Model [L118-219]\n  ### 3.1 Class Hierarchy [L122-137]\n  ### 3.2 `TtmlDocument` [L137-153]\n  ### 3.3 `TtmlAgent` [L153-165]\n  ### 3.4 `TtmlLine` [L165-195]\n  ### 3.5 `TtmlWord` [L195-219]\n ## 4. Parser API [L219-256]\n  ### 4.1 `TtmlParser` [L221-240]\n  ### 4.2 `TtmlParseException` [L240-256]\n ## 5. Parsing Algorithm [L256-299]\n  ### Step 1 — Parse XML [L260-263]\n  ### Step 2 — Locate the root `<tt>` element [L263-266]\n  ### Step 3 — Extract agents from `<head>` [L266-269]\n  ### Step 4 — Extract total duration from `<body>` [L269-272]\n  ### Step 5 — Collect all `<p>` elements [L272-275]\n  ### Step 6 — Parse each `<p>` into a `TtmlLine` [L275-285]\n  ### Step 7 — Parse each `<span>` into a `TtmlWord` [L285-294]\n  ### Step 8 — Assemble and return [L294-299]\n ## 6. Time-Parsing Algorithm [L299-314]\n ## 7. File Structure [L314-345]\n ## 8. Dependencies [L345-360]\n ## 9. Error Handling Summary [L360-378]\n ## 10. Test Requirements [L378-426]\n  ### 10.1 Document-level tests [L382-390]\n  ### 10.2 Line-level tests (using `heart_sutra.ttml`) [L390-398]\n  ### 10.3 Word-level tests [L398-403]\n  ### 10.4 Time-parser unit tests (using inline strings) [L403-411]\n  ### 10.5 Error-handling tests (using inline XML strings) [L411-419]\n  ### 10.6 Whitespace-handling tests [L419-426]\n ## 11. Rendering Guidance (Non-Normative) [L426-442]\n ## 12. Sample Data [L442-448]\n ## 13. Acceptance Criteria [L448-456]\n\nShowing symbols 1-47 (total symbols: 47)\n\n\nNEXT STEPS: To read a specific symbol's implementation, call read_file with the same path plus start_line and end_line from the outline above.\nFor example, to read a function shown as [L100-150], use start_line: 100 and end_line: 150."
}
```

**Tool Call: Read file `specification.md` (lines 1-120)**
Status: Completed

```json
{
  "Text": "# TTML Parser Package Specification\n\n## 1. Overview\n\nThis document specifies the implementation of a Dart/Flutter package named `ttml_parser` that parses TTML (Timed Text Markup Language) files and returns a structured data model suitable for rendering karaoke-style lyrics in a Flutter mobile application.\n\nThe parser targets the Apple Music lyric TTML dialect (identified by `itunes:timing=\"Word\"`), which provides word-level timing for each lyric line. The output data model exposes timing information at both the line and word level, enabling smooth karaoke-style highlight animations.\n\n---\n\n## 2. TTML Format Reference\n\n### 2.1 Namespaces\n\nThe following XML namespaces appear in the target TTML files:\n\n| Prefix | URI | Purpose |\n|--------|-----|---------|\n| _(default)_ | `http://www.w3.org/ns/ttml` | Core TTML elements |\n| `ttm` | `http://www.w3.org/ns/ttml#metadata` | TTML metadata extensions |\n| `amll` | `http://www.example.com/ns/amll` | AMLL extensions (ignored by this parser) |\n| `itunes` | `http://music.apple.com/lyric-ttml-internal` | Apple Music extensions |\n\n### 2.2 Document Structure\n\n```ttml_parser/assets/heart_sutra.ttml#L1-1\n<tt xmlns=\"http://www.w3.org/ns/ttml\"\n    xmlns:ttm=\"http://www.w3.org/ns/ttml#metadata\"\n    xmlns:itunes=\"http://music.apple.com/lyric-ttml-internal\"\n    itunes:timing=\"Word\">\n  <head>\n    <metadata>\n      <ttm:agent type=\"person\" xml:id=\"v1\"/>\n      <ttm:agent type=\"other\"  xml:id=\"v2\"/>\n    </metadata>\n  </head>\n  <body dur=\"05:26.915\">\n    <div begin=\"00:01.448\" end=\"05:26.915\">\n      <p begin=\"00:07.733\" end=\"00:41.898\"\n         ttm:agent=\"v1\"\n         itunes:key=\"L2\">\n        <span begin=\"00:07.733\" end=\"00:12.124\">Mahá</span>\n        <span begin=\"00:12.814\" end=\"00:18.949\">Prádzsnyá</span>\n        <span begin=\"00:19.107\" end=\"00:27.700\">Párámitá</span>\n      </p>\n    </div>\n  </body>\n</tt>\n```\n\n### 2.3 Key Elements and Attributes\n\n#### `<tt>` (root)\n| Attribute | Required | Description |\n|-----------|----------|-------------|\n| `itunes:timing` | No | When `\"Word\"`, word-level timing is present on each `<span>` |\n\n#### `<ttm:agent>` (inside `<head><metadata>`)\n| Attribute | Required | Description |\n|-----------|----------|-------------|\n| `xml:id` | Yes | Unique agent identifier (e.g., `\"v1\"`) |\n| `type` | Yes | One of `\"person\"` or `\"other\"` |\n\n#### `<body>`\n| Attribute | Required | Description |\n|-----------|----------|-------------|\n| `dur` | No | Total duration of the lyric track |\n\n#### `<div>`\n| Attribute | Required | Description |\n|-----------|----------|-------------|\n| `begin` | No | Start time of this section |\n| `end` | No | End time of this section |\n\n#### `<p>` (one lyric line)\n| Attribute | Required | Description |\n|-----------|----------|-------------|\n| `begin` | Yes | Line start time |\n| `end` | Yes | Line end time |\n| `ttm:agent` | No | Reference to an agent `xml:id` |\n| `itunes:key` | No | Unique line key (e.g., `\"L1\"`) |\n\n#### `<span>` (one word or syllable within a line)\n| Attribute | Required | Description |\n|-----------|----------|-------------|\n| `begin` | Yes | Word start time |\n| `end` | Yes | Word end time |\n\nThe text content of each `<span>` is the word or syllable to display.\n\n### 2.4 Time Format\n\nAll time values follow the pattern `[HH:]MM:SS.mmm`:\n\n- `HH` — hours (optional)\n- `MM` — two-digit minutes\n- `SS` — two-digit seconds\n- `mmm` — three-digit milliseconds\n\nExamples:\n- `\"00:07.500\"` → 7 seconds, 500 ms → 7500 ms\n- `\"01:04.097\"` → 1 minute, 4 seconds, 97 ms → 64097 ms\n- `\"05:26.915\"` → 5 minutes, 26 seconds, 915 ms → 326915 ms\n\n### 2.5 Whitespace Between Spans\n\n`<span>` elements within a `<p>` are frequently separated by literal space characters (plain text nodes in the XML). These text nodes must be **ignored** during parsing; spacing between displayed words is a concern of the rendering layer, not the parser.\n\n### 2.6 Agent Types\n\n| Type | Meaning | Suggested rendering |\n|------|---------|---------------------|\n| `\"person\"` | A human vocalist | Primary lyric colour; left-aligned |\n| `\"other\"` | Background vocals, choir, etc. | Secondary colour; right-aligned or smaller |\n\n---\n\n## 3. Output Data Model\n\nAll classes are immutable (every field is `final`). All durations are represented as Dart `Duration` objects.\n"
}
```

**Tool Call: List the `ttml_parser` directory's contents**
Status: Completed

# Folders:
ttml_parser/.dart_tool
ttml_parser/.idea
ttml_parser/assets
ttml_parser/lib
ttml_parser/test

# Files:
ttml_parser/.gitignore
ttml_parser/.metadata
ttml_parser/CHANGELOG.md
ttml_parser/LICENSE
ttml_parser/README.md
ttml_parser/analysis_options.yaml
ttml_parser/pubspec.lock
ttml_parser/pubspec.yaml
ttml_parser/specification.md
ttml_parser/ttml_parser.iml


**Tool Call: Read file `specification.md` (lines 120-260)**
Status: Completed

```json
{
  "Text": "All classes are immutable (every field is `final`). All durations are represented as Dart `Duration` objects.\n\n### 3.1 Class Hierarchy\n\n```/dev/null/diagram.txt#L1-7\nTtmlDocument\n├── totalDuration : Duration\n├── agents        : List<TtmlAgent>\n└── lines         : List<TtmlLine>\n                       ├── begin, end : Duration\n                       ├── agentId    : String?\n                       ├── key        : String?\n                       └── words      : List<TtmlWord>\n                                          ├── begin, end : Duration\n                                          └── text       : String\n```\n\n### 3.2 `TtmlDocument`\n\n```/dev/null/model.dart#L1-10\nclass TtmlDocument {\n  /// Total playback duration of the track, sourced from <body dur=\"…\">.\n  /// Null when the attribute is absent.\n  final Duration? totalDuration;\n\n  /// All agents declared in <head><metadata>.\n  final List<TtmlAgent> agents;\n\n  /// All lyric lines in document order.\n  final List<TtmlLine> lines;\n}\n```\n\n### 3.3 `TtmlAgent`\n\n```/dev/null/model.dart#L12-20\nclass TtmlAgent {\n  /// The value of xml:id on the <ttm:agent> element (e.g. \"v1\").\n  final String id;\n\n  /// The value of the type attribute (e.g. \"person\" or \"other\").\n  final String type;\n}\n```\n\n### 3.4 `TtmlLine`\n\n```/dev/null/model.dart#L22-42\nclass TtmlLine {\n  /// Timestamp at which this line begins, from the begin attribute of <p>.\n  final Duration begin;\n\n  /// Timestamp at which this line ends, from the end attribute of <p>.\n  final Duration end;\n\n  /// The xml:id of the ttm:agent responsible for this line.\n  /// Null when the ttm:agent attribute is absent from the <p> element.\n  final String? agentId;\n\n  /// The value of the itunes:key attribute (e.g. \"L1\", \"L42\").\n  /// Null when the attribute is absent.\n  final String? key;\n\n  /// The words (or syllables) that make up this line, in document order.\n  final List<TtmlWord> words;\n}\n```\n\nConvenience getters that SHOULD be implemented on `TtmlLine`:\n\n| Getter | Return type | Description |\n|--------|-------------|-------------|\n| `text` | `String` | All `word.text` values joined with a single space |\n| `duration` | `Duration` | `end - begin` |\n\n### 3.5 `TtmlWord`\n\n```/dev/null/model.dart#L44-56\nclass TtmlWord {\n  /// Timestamp at which this word begins, from the begin attribute of <span>.\n  final Duration begin;\n\n  /// Timestamp at which this word ends, from the end attribute of <span>.\n  final Duration end;\n\n  /// The raw text content of the <span> element, trimmed of leading/trailing\n  /// whitespace. Never empty; spans whose trimmed text is empty are discarded.\n  final String text;\n}\n```\n\nConvenience getters that SHOULD be implemented on `TtmlWord`:\n\n| Getter | Return type | Description |\n|--------|-------------|-------------|\n| `duration` | `Duration` | `end - begin` |\n\n---\n\n## 4. Parser API\n\n### 4.1 `TtmlParser`\n\n```/dev/null/parser.dart#L1-14\nclass TtmlParser {\n  const TtmlParser();\n\n  /// Parses a TTML document from its raw XML string.\n  ///\n  /// Throws [TtmlParseException] if the input is not valid XML or if required\n  /// TTML attributes are missing or malformed.\n  ///\n  /// Returns a fully populated [TtmlDocument]. The [TtmlDocument.lines] list\n  /// is in document order and is never null (may be empty).\n  TtmlDocument parse(String ttmlContent);\n}\n```\n\nThe parser MUST be stateless; the same `TtmlParser` instance MUST be reusable across multiple calls to `parse`.\n\n### 4.2 `TtmlParseException`\n\n```/dev/null/exception.dart#L1-10\nclass TtmlParseException implements Exception {\n  /// Human-readable description of what went wrong.\n  final String message;\n\n  /// The original exception that caused this error, if any.\n  final Object? cause;\n\n  const TtmlParseException(this.message, {this.cause});\n}\n```\n\n---\n\n## 5. Parsing Algorithm\n\nThe implementation MUST follow these steps, in order:\n\n### Step 1 — Parse XML\n"
}
```

**Tool Call: Read file `specification.md` (lines 260-456)**
Status: Completed

```json
{
  "Text": "### Step 1 — Parse XML\nUse Dart's `xml` package (available on pub.dev) to parse the raw string into a DOM. If parsing fails, wrap and rethrow as `TtmlParseException`.\n\n### Step 2 — Locate the root `<tt>` element\nFind the single `<tt>` element in the document. Throw `TtmlParseException` if absent.\n\n### Step 3 — Extract agents from `<head>`\nTraverse `tt > head > metadata > ttm:agent` elements. For each element, read `xml:id` (mapped to `TtmlAgent.id`) and `type` (mapped to `TtmlAgent.type`). Both attributes are required; throw `TtmlParseException` if either is missing. Collect results into a list preserving document order.\n\n### Step 4 — Extract total duration from `<body>`\nRead the `dur` attribute on the `<body>` element. If present, parse it with the time-parsing algorithm (§6). Store as `TtmlDocument.totalDuration`. If absent, store `null`.\n\n### Step 5 — Collect all `<p>` elements\nDescend into `body > div` (one or more `<div>` elements may exist). Collect every `<p>` element from all `<div>` children, preserving document order.\n\n### Step 6 — Parse each `<p>` into a `TtmlLine`\nFor each `<p>` element:\n\n1. Read and parse `begin` — **required**; throw `TtmlParseException` if absent or unparseable.\n2. Read and parse `end` — **required**; throw `TtmlParseException` if absent or unparseable.\n3. Read `ttm:agent` — optional; store as `TtmlLine.agentId` or `null`.\n4. Read `itunes:key` — optional; store as `TtmlLine.key` or `null`.\n5. Collect child `<span>` elements (ignoring text nodes and other element types — see §5 Step 7).\n6. Construct a `TtmlLine`.\n\n### Step 7 — Parse each `<span>` into a `TtmlWord`\nFor each direct child `<span>` of the `<p>`:\n\n1. Read and parse `begin` — **required**; throw `TtmlParseException` if absent or unparseable.\n2. Read and parse `end` — **required**; throw `TtmlParseException` if absent or unparseable.\n3. Read the element's text content and trim whitespace.\n4. **Discard** the span if the trimmed text is empty.\n5. Otherwise, construct a `TtmlWord`.\n\n### Step 8 — Assemble and return\nAssemble the `TtmlDocument` from the collected agents, total duration, and lines. Return it to the caller.\n\n---\n\n## 6. Time-Parsing Algorithm\n\nGiven a time string `s`:\n\n1. Split `s` on `\":\"`.\n2. If two parts result → format is `MM:SS.mmm` (no hours component).\n3. If three parts result → format is `HH:MM:SS.mmm`.\n4. Parse the final part as a `double` (seconds with fractional milliseconds); convert to milliseconds by multiplying by 1000 and rounding to the nearest integer.\n5. Parse the preceding part as integer minutes (and optionally the part before that as integer hours).\n6. Compute total milliseconds: `hours * 3_600_000 + minutes * 60_000 + milliseconds`.\n7. Return `Duration(milliseconds: total)`.\n8. If any step fails, throw `TtmlParseException` with the offending string.\n\n---\n\n## 7. File Structure\n\nThe package MUST be structured as follows:\n\n```/dev/null/structure.txt#L1-14\nlib/\n  ttml_parser.dart          ← public barrel export\n  src/\n    models/\n      ttml_document.dart    ← TtmlDocument\n      ttml_agent.dart       ← TtmlAgent\n      ttml_line.dart        ← TtmlLine\n      ttml_word.dart        ← TtmlWord\n    parser/\n      ttml_parser.dart      ← TtmlParser\n      time_parser.dart      ← internal time-parsing helper\n    exceptions/\n      ttml_parse_exception.dart  ← TtmlParseException\n```\n\nAll `src/` contents are private to the package. Only the following symbols MUST be exported from `ttml_parser.dart`:\n\n- `TtmlDocument`\n- `TtmlAgent`\n- `TtmlLine`\n- `TtmlWord`\n- `TtmlParser`\n- `TtmlParseException`\n\n---\n\n## 8. Dependencies\n\nAdd the following to `pubspec.yaml`:\n\n```/dev/null/pubspec_fragment.yaml#L1-3\ndependencies:\n  xml: ^6.0.0   # XML parsing\n  flutter:\n    sdk: flutter\n```\n\nNo other third-party dependencies are permitted.\n\n---\n\n## 9. Error Handling Summary\n\n| Situation | Behaviour |\n|-----------|-----------|\n| Input string is not valid XML | Throw `TtmlParseException` |\n| `<tt>` root element not found | Throw `TtmlParseException` |\n| `<ttm:agent>` missing `xml:id` or `type` | Throw `TtmlParseException` |\n| `<p>` missing `begin` or `end` | Throw `TtmlParseException` |\n| `<span>` missing `begin` or `end` | Throw `TtmlParseException` |\n| Time string in unrecognised format | Throw `TtmlParseException` |\n| `<body>` missing `dur` | Store `null`; do not throw |\n| `<p>` missing `ttm:agent` | Store `null`; do not throw |\n| `<p>` missing `itunes:key` | Store `null`; do not throw |\n| `<span>` with empty text content | Discard silently |\n| No `<p>` elements in document | Return `TtmlDocument` with empty `lines` list |\n\n---\n\n## 10. Test Requirements\n\nTests MUST be placed in `test/ttml_parser_test.dart` and MUST cover the following scenarios using the bundled `assets/heart_sutra.ttml` file as well as inline XML strings:\n\n### 10.1 Document-level tests\n- Parsing `heart_sutra.ttml` succeeds without throwing.\n- `TtmlDocument.totalDuration` equals `Duration(minutes: 5, seconds: 26, milliseconds: 915)`.\n- `TtmlDocument.agents` has exactly two entries.\n- Agent `\"v1\"` has type `\"person\"`.\n- Agent `\"v2\"` has type `\"other\"`.\n- `TtmlDocument.lines` is non-empty.\n\n### 10.2 Line-level tests (using `heart_sutra.ttml`)\n- The second `<p>` (key `\"L2\"`) has `begin` equal to `Duration(seconds: 7, milliseconds: 733)`.\n- The second `<p>` (key `\"L2\"`) has `end` equal to `Duration(seconds: 41, milliseconds: 898)`.\n- The second `<p>` (key `\"L2\"`) has `agentId` equal to `\"v1\"`.\n- The second `<p>` (key `\"L2\"`) has exactly five words.\n- The first word of line `\"L2\"` has `text` equal to `\"Mahá\"`.\n- The `text` convenience getter on line `\"L2\"` equals `\"Mahá Prádzsnyá Párámitá Hridájá Szútra\"`.\n\n### 10.3 Word-level tests\n- The first word of line `\"L2\"` has `begin` equal to `Duration(seconds: 7, milliseconds: 733)`.\n- The first word of line `\"L2\"` has `end` equal to `Duration(seconds: 12, milliseconds: 124)`.\n- The `duration` convenience getter on that word equals `Duration(seconds: 4, milliseconds: 391)`.\n\n### 10.4 Time-parser unit tests (using inline strings)\n- `\"00:00.000\"` → `Duration.zero`\n- `\"00:07.500\"` → `Duration(seconds: 7, milliseconds: 500)`\n- `\"01:04.097\"` → `Duration(minutes: 1, seconds: 4, milliseconds: 97)`\n- `\"05:26.915\"` → `Duration(minutes: 5, seconds: 26, milliseconds: 915)`\n- `\"01:02:03.456\"` → `Duration(hours: 1, minutes: 2, seconds: 3, milliseconds: 456)`\n- An invalid string (e.g., `\"abc\"`) throws `TtmlParseException`.\n\n### 10.5 Error-handling tests (using inline XML strings)\n- Malformed XML throws `TtmlParseException`.\n- A `<p>` missing `begin` throws `TtmlParseException`.\n- A `<p>` missing `end` throws `TtmlParseException`.\n- A `<span>` missing `begin` throws `TtmlParseException`.\n- A `<ttm:agent>` missing `xml:id` throws `TtmlParseException`.\n- A document with no `<p>` elements returns an empty `lines` list without throwing.\n\n### 10.6 Whitespace-handling tests\n- Literal space text nodes between `<span>` elements are not parsed as words.\n- Leading/trailing whitespace in `<span>` text content is trimmed.\n- A `<span>` whose text content is only whitespace is discarded.\n\n---\n\n## 11. Rendering Guidance (Non-Normative)\n\nThis section is informational and does not affect the parser implementation.\n\nA karaoke renderer consuming `TtmlDocument` can use the following approach:\n\n1. **Line activation**: At playback position `t`, display all lines where `line.begin <= t < line.end`. Lines outside this window may be shown as upcoming or past lyrics.\n\n2. **Word highlighting**: Within an active line, highlight each word where `word.begin <= t < word.end`. Words before this range are fully highlighted (sung); words after are unhighlighted (pending).\n\n3. **Voice differentiation**: Use `line.agentId` to look up the corresponding `TtmlAgent`. Render `\"person\"` agents with the primary lyric style (e.g., left-aligned, white fill) and `\"other\"` agents with a secondary style (e.g., right-aligned, grey fill).\n\n4. **Progress within a word**: For smooth sub-word animation, compute `progress = (t - word.begin) / word.duration` (clamped to `[0.0, 1.0]`) and use it to drive a fill or clip animation on the word's text widget.\n\n---\n\n## 12. Sample Data\n\nThe file `assets/heart_sutra.ttml` is bundled with the package for use in tests. It contains a Hungarian translation of the Heart Sutra set to music, with word-level timing across 58 lyric lines (`L1`–`L58`). Line `L1` (agent `v2`) is an instrumental placeholder whose span text values are all `\"0\"` and must be parsed without special-casing.\n\n---\n\n## 13. Acceptance Criteria\n\nThe implementation is considered complete when:\n\n1. All tests described in §10 pass with `flutter test`.\n2. `flutter analyze` reports zero errors and zero warnings.\n3. The public API surface matches exactly the symbols listed in §7.\n4. The parser correctly round-trips the bundled `heart_sutra.ttml` file: every line and every word is present, in order, with correct timing.\n5. No mutable state is held by `TtmlParser` between calls to `parse`."
}
```

**Tool Call: Read file `pubspec.yaml`**
Status: Completed

```json
{
  "Text": "name: ttml_parser\ndescription: \"A new Flutter package project.\"\nversion: 0.0.1\nhomepage:\n\nenvironment:\n  sdk: ^3.10.8\n  flutter: \">=1.17.0\"\n\ndependencies:\n  flutter:\n    sdk: flutter\n\ndev_dependencies:\n  flutter_test:\n    sdk: flutter\n  flutter_lints: ^6.0.0\n\n# For information on the generic Dart part of this file, see the\n# following page: https://dart.dev/tools/pub/pubspec\n\n# The following section is specific to Flutter packages.\nflutter:\n\n  # To add assets to your package, add an assets section, like this:\n  # assets:\n  #   - images/a_dot_burr.jpeg\n  #   - images/a_dot_ham.jpeg\n  #\n  # For details regarding assets in packages, see\n  # https://flutter.dev/to/asset-from-package\n  #\n  # An image asset can refer to one or more resolution-specific \"variants\", see\n  # https://flutter.dev/to/resolution-aware-images\n\n  # To add custom fonts to your package, add a fonts section here,\n  # in this \"flutter\" section. Each entry in this list should have a\n  # \"family\" key with the font family name, and a \"fonts\" key with a\n  # list giving the asset and other descriptors for the font. For\n  # example:\n  # fonts:\n  #   - family: Schyler\n  #     fonts:\n  #       - asset: fonts/Schyler-Regular.ttf\n  #       - asset: fonts/Schyler-Italic.ttf\n  #         style: italic\n  #   - family: Trajan Pro\n  #     fonts:\n  #       - asset: fonts/TrajanPro.ttf\n  #       - asset: fonts/TrajanPro_Bold.ttf\n  #         weight: 700\n  #\n  # For details regarding fonts in packages, see\n  # https://flutter.dev/to/font-from-package\n"
}
```

**Tool Call: List the `ttml_parser/assets` directory's contents**
Status: Completed


# Files:
ttml_parser/assets/heart_sutra.ttml


**Tool Call: List the `ttml_parser/lib` directory's contents**
Status: Completed


# Files:
ttml_parser/lib/ttml_parser.dart


**Tool Call: List the `ttml_parser/test` directory's contents**
Status: Completed


# Files:
ttml_parser/test/ttml_parser_test.dart


**Tool Call: Read file `lib/ttml_parser.dart`**
Status: Completed

```json
{
  "Text": "/// A Calculator.\nclass Calculator {\n  /// Returns [value] plus 1.\n  int addOne(int value) => value + 1;\n}\n"
}
```

**Tool Call: Read file `assets/heart_sutra.ttml` (lines 1-60)**
Status: Completed

```json
{
  "Text": "<tt xmlns=\"http://www.w3.org/ns/ttml\" xmlns:ttm=\"http://www.w3.org/ns/ttml#metadata\" xmlns:amll=\"http://www.example.com/ns/amll\" xmlns:itunes=\"http://music.apple.com/lyric-ttml-internal\" itunes:timing=\"Word\"><head><metadata><ttm:agent type=\"person\" xml:id=\"v1\"/><ttm:agent type=\"other\" xml:id=\"v2\"/></metadata></head><body dur=\"05:26.915\"><div begin=\"00:01.448\" end=\"05:26.915\"><p begin=\"00:01.448\" end=\"00:07.500\" ttm:agent=\"v2\" itunes:key=\"L1\"><span begin=\"00:01.427\" end=\"00:01.991\">0</span><span begin=\"00:02.333\" end=\"00:02.622\">0</span><span begin=\"00:02.814\" end=\"00:02.974\">0</span><span begin=\"00:03.127\" end=\"00:03.271\">0</span><span begin=\"00:03.388\" end=\"00:03.527\">0</span><span begin=\"00:03.613\" end=\"00:03.727\">0</span><span begin=\"00:03.807\" end=\"00:03.922\">0</span><span begin=\"00:03.995\" end=\"00:04.098\">0</span><span begin=\"00:04.173\" end=\"00:04.288\">0</span><span begin=\"00:04.351\" end=\"00:04.448\">0</span><span begin=\"00:04.511\" end=\"00:04.630\">0</span><span begin=\"00:04.670\" end=\"00:04.796\">0</span><span begin=\"00:04.853\" end=\"00:04.922\">0</span><span begin=\"00:04.979\" end=\"00:05.059\">0</span><span begin=\"00:05.139\" end=\"00:05.208\">0</span><span begin=\"00:06.403\" end=\"00:06.872\">0</span></p><p begin=\"00:07.733\" end=\"00:41.898\" ttm:agent=\"v1\" itunes:key=\"L2\"><span begin=\"00:07.733\" end=\"00:12.124\">Mahá</span> <span begin=\"00:12.814\" end=\"00:18.949\">Prádzsnyá</span> <span begin=\"00:19.107\" end=\"00:27.700\">Párámitá</span> <span begin=\"00:27.866\" end=\"00:33.665\">Hridájá</span> <span begin=\"00:33.965\" end=\"00:41.898\">Szútra</span></p><p begin=\"00:42.701\" end=\"00:48.997\" ttm:agent=\"v1\" itunes:key=\"L3\"><span begin=\"00:42.701\" end=\"00:46.954\">Avalókitésvara</span> <span begin=\"00:47.027\" end=\"00:48.997\">Bódhiszattva</span></p><p begin=\"00:49.143\" end=\"00:56.759\" ttm:agent=\"v1\" itunes:key=\"L4\"><span begin=\"00:49.143\" end=\"00:49.353\">a</span> <span begin=\"00:49.353\" end=\"00:50.193\">mély</span> <span begin=\"00:50.218\" end=\"00:52.288\">Meghaladó</span> <span begin=\"00:52.308\" end=\"00:54.328\">Bölcsességben</span> <span begin=\"00:54.473\" end=\"00:55.810\">időzvén</span> <span begin=\"00:55.884\" end=\"00:56.759\">látja,</span></p><p begin=\"00:56.957\" end=\"01:04.097\" ttm:agent=\"v1\" itunes:key=\"L5\"><span begin=\"00:56.957\" end=\"00:57.592\">hogy</span> <span begin=\"00:57.592\" end=\"00:58.547\">igaz</span> <span begin=\"00:58.547\" end=\"01:01.155\">természetében</span> <span begin=\"01:01.155\" end=\"01:01.710\">az</span> <span begin=\"01:01.710\" end=\"01:02.120\">öt</span> <span begin=\"01:02.120\" end=\"01:03.140\">szkandha</span> <span begin=\"01:03.140\" end=\"01:04.097\">üres,</span></p><p begin=\"01:04.203\" end=\"01:09.790\" ttm:agent=\"v1\" itunes:key=\"L6\"><span begin=\"01:04.203\" end=\"01:04.923\">és</span> <span begin=\"01:04.923\" end=\"01:05.858\">ezzel</span> <span begin=\"01:05.858\" end=\"01:06.743\">minden</span> <span begin=\"01:06.743\" end=\"01:08.208\">szenvedést</span> <span begin=\"01:08.208\" end=\"01:09.790\">meghalad.</span></p><p begin=\"01:09.875\" end=\"01:11.842\" ttm:agent=\"v1\" itunes:key=\"L7\"><span begin=\"01:09.875\" end=\"01:11.842\">Sáriputra!</span></p><p begin=\"01:11.922\" end=\"01:18.495\" ttm:agent=\"v1\" itunes:key=\"L8\"><span begin=\"01:11.922\" end=\"01:12.467\">A</span> <span begin=\"01:12.488\" end=\"01:13.248\">forma</span> <span begin=\"01:13.356\" end=\"01:14.070\">nem</span> <span begin=\"01:14.116\" end=\"01:16.088\">különbözik</span> <span begin=\"01:16.089\" end=\"01:16.609\">az</span> <span begin=\"01:16.649\" end=\"01:18.495\">ürességtől,</span></p><p begin=\"01:18.606\" end=\"01:25.156\" ttm:agent=\"v1\" itunes:key=\"L9\"><span begin=\"01:18.606\" end=\"01:19.235\">az</span> <span begin=\"01:19.235\" end=\"01:20.610\">üresség</span> <span begin=\"01:20.610\" end=\"01:21.281\">nem</span> <span begin=\"01:21.281\" end=\"01:23.021\">különbözik</span> <span begin=\"01:23.021\" end=\"01:23.278\">a</span> <span begin=\"01:23.278\" end=\"01:25.156\">formától.</span></p><p begin=\"01:25.301\" end=\"01:29.709\" ttm:agent=\"v1\" itunes:key=\"L10\"><span begin=\"01:25.301\" end=\"01:25.879\">A</span> <span begin=\"01:25.879\" end=\"01:26.842\">forma</span> <span begin=\"01:26.842\" end=\"01:28.223\">valóban</span> <span begin=\"01:28.223\" end=\"01:29.709\">üresség,</span></p><p begin=\"01:29.832\" end=\"01:34.512\" ttm:agent=\"v1\" itunes:key=\"L11\"><span begin=\"01:29.832\" end=\"01:30.466\">az</span> <span begin=\"01:30.466\" end=\"01:31.936\">üresség</span> <span begin=\"01:31.936\" end=\"01:33.494\">valóban</span> <span begin=\"01:33.494\" end=\"01:34.512\">forma.</span></p><p begin=\"01:34.541\" end=\"01:40.146\" ttm:agent=\"v1\" itunes:key=\"L12\"><span begin=\"01:34.541\" end=\"01:35.095\">Így</span> <span begin=\"01:35.095\" end=\"01:35.978\">ilyen</span> <span begin=\"01:35.978\" end=\"01:36.587\">az</span> <span begin=\"01:36.587\" end=\"01:37.574\">érzés,</span> <span begin=\"01:37.574\" end=\"01:38.116\">az</span> <span begin=\"01:38.116\" end=\"01:40.146\">érzékelés,</span></p><p begin=\"01:40.188\" end=\"01:45.728\" ttm:agent=\"v1\" itunes:key=\"L13\"><span begin=\"01:40.188\" end=\"01:40.697\">az</span> <span begin=\"01:40.697\" end=\"01:42.178\">akarat</span> <span begin=\"01:42.178\" end=\"01:42.755\">és</span> <span begin=\"01:42.755\" end=\"01:43.275\">a</span> <span begin=\"01:43.275\" end=\"01:45.160\">tudatosság</span> <span begin=\"01:45.160\" end=\"01:45.728\">is.</span></p><p begin=\"01:45.815\" end=\"01:47.861\" ttm:agent=\"v1\" itunes:key=\"L14\"><span begin=\"01:45.815\" end=\"01:47.861\">Sáriputra!</span></p><p begin=\"01:47.925\" end=\"01:54.972\" ttm:agent=\"v1\" itunes:key=\"L15\"><span begin=\"01:47.925\" end=\"01:48.988\">Minden</span> <span begin=\"01:48.988\" end=\"01:50.964\">jelenségnek</span> <span begin=\"01:50.964\" end=\"01:52.548\">üresség</span> <span begin=\"01:52.548\" end=\"01:53.080\">a</span> <span begin=\"01:53.080\" end=\"01:54.972\">természete.</span></p><p begin=\"01:55.063\" end=\"02:00.107\" ttm:agent=\"v1\" itunes:key=\"L16\"><span begin=\"01:55.063\" end=\"01:55.596\">Nem</span> <span begin=\"01:55.596\" end=\"01:57.649\">keletkeznek</span> <span begin=\"01:57.649\" end=\"01:58.209\">és</span> <span begin=\"01:58.209\" end=\"01:58.712\">nem</span> <span begin=\"01:58.712\" end=\"01:59.723\">szűnnek</span> <span begin=\"01:59.723\" end=\"02:00.107\">meg,</span></p><p begin=\"02:00.182\" end=\"02:04.698\" ttm:agent=\"v1\" itunes:key=\"L17\"><span begin=\"02:00.182\" end=\"02:00.723\">nem</span> <span begin=\"02:00.723\" end=\"02:01.789\">tiszták</span> <span begin=\"02:01.789\" end=\"02:02.282\">és</span> <span begin=\"02:02.282\" end=\"02:02.804\">nem</span> <span begin=\"02:02.804\" end=\"02:04.698\">szennyezettek,</span></p><p begin=\"02:04.794\" end=\"02:09.725\" ttm:agent=\"v1\" itunes:key=\"L18\"><span begin=\"02:04.794\" end=\"02:05.331\">nem</span> <span begin=\"02:05.331\" end=\"02:07.331\">növekszenek</span> <span begin=\"02:07.331\" end=\"02:07.912\">és</span> <span begin=\"02:07.912\" end=\"02:08.344\">nem</span> <span begin=\"02:08.344\" end=\"02:09.725\">csökkennek.</span></p><p begin=\"02:09.832\" end=\"02:15.940\" ttm:agent=\"v1\" itunes:key=\"L19\"><span begin=\"02:09.832\" end=\"02:10.901\">Ezért</span> <span begin=\"02:10.901\" end=\"02:11.480\">az</span> <span begin=\"02:11.480\" end=\"02:13.429\">ürességben</span> <span begin=\"02:13.429\" end=\"02:13.947\">nincs</span> <span begin=\"02:13.947\" end=\"02:14.920\">forma,</span> <span begin=\"02:14.920\" end=\"02:15.940\">érzés,</span></p><p begin=\"02:15.940\" end=\"02:22.042\" ttm:agent=\"v1\" itunes:key=\"L20\"><span begin=\"02:16.140\" end=\"02:17.987\">érzékelés,</span> <span begin=\"02:17.987\" end=\"02:19.611\">akarat</span> <span begin=\"02:19.611\" end=\"02:20.087\">és</span> <span begin=\"02:20.087\" end=\"02:22.042\">tudatosság.</span></p><p begin=\"02:22.084\" end=\"02:27.158\" ttm:agent=\"v1\" itunes:key=\"L21\"><span begin=\"02:22.084\" end=\"02:22.622\">Nincs</span> <span begin=\"02:22.622\" end=\"02:23.108\">szem,</span> <span begin=\"02:23.108\" end=\"02:23.625\">fül,</span> <span begin=\"02:23.625\" end=\"02:24.135\">orr,</span> <span begin=\"02:24.135\" end=\"02:24.674\">nyelv,</span> <span begin=\"02:24.674\" end=\"02:25.231\">test</span> <span begin=\"02:25.231\" end=\"02:25.655\">és</span> <span begin=\"02:25.655\" end=\"02:27.158\">értelem,</span></p><p begin=\"02:27.221\" end=\"02:29.779\" ttm:agent=\"v1\" itunes:key=\"L22\"><span begin=\"02:27.221\" end=\"02:27.728\">nincs</span> <span begin=\"02:27.728\" end=\"02:28.231\">szín,</span> <span begin=\"02:28.231\" end=\"02:28.763\">hang,</span> <span begin=\"02:28.763\" end=\"02:29.365\">szag,</span> <span begin=\"02:29.365\" end=\"02:29.779\">íz,</span></p><p begin=\"02:29.826\" end=\"02:34.777\" ttm:agent=\"v1\" itunes:key=\"L23\"><span begin=\"02:29.826\" end=\"02:31.314\">tapintás</span> <span begin=\"02:31.314\" end=\"02:31.810\">és</span> <span begin=\"02:31.810\" end=\"02:33.337\">tudati</span> <span begin=\"02:33.337\" end=\"02:34.777\">folyamat,</span></p><p begin=\"02:34.825\" end=\"02:40.354\" ttm:agent=\"v1\" itunes:key=\"L24\"><span begin=\"02:34.825\" end=\"02:35.412\">nincs</span> <span begin=\"02:35.412\" end=\"02:37.216\">birodalma</span> <span begin=\"02:37.216\" end=\"02:37.998\">az</span> <span begin=\"02:37.998\" end=\"02:40.354\">érzékszerveknek</span></p><p begin=\"02:40.420\" end=\"02:43.916\" ttm:agent=\"v1\" itunes:key=\"L25\"><span begin=\"02:40.420\" end=\"02:40.953\">és</span> <span begin=\"02:40.953\" end=\"02:41.510\">a</span> <span begin=\"02:41.510\" end=\"02:43.916\">tudatosságnak.</span></p><p begin=\"02:43.970\" end=\"02:50.008\" ttm:agent=\"v1\" itunes:key=\"L26\"><span begin=\"02:43.970\" end=\"02:44.553\">Nincs</span> <span begin=\"02:44.553\" end=\"02:45.987\">nemtudás</span> <span begin=\"02:45.987\" end=\"02:46.509\">és</span> <span begin=\"02:46.509\" end=\"02:47.063\">nincs</span> <span begin=\"02:47.063\" end=\"02:47.920\">annak</span> <span begin=\"02:47.920\" end=\"02:50.008\">megszűnése,</span></p><p begin=\"02:50.065\" end=\"02:53.609\" ttm:agent=\"v1\" itunes:key=\"L27\"><span begin=\"02:50.065\" end=\"02:50.665\">nincs</span> <span begin=\"02:50.665\" end=\"02:52.162\">öregség</span> <span begin=\"02:52.162\" end=\"02:52.654\">és</span> <span begin=\"02:52.654\" end=\"02:53.609\">halál</span></p><p begin=\"02:53.649\" end=\"02:58.108\" ttm:agent=\"v1\" itunes:key=\"L28\"><span begin=\"02:53.649\" end=\"02:54.180\">és</span> <span begin=\"02:54.180\" end=\"02:54.666\">nincs</span> <span begin=\"02:54.666\" end=\"02:55.655\">ezek</span> <span begin=\"02:55.655\" end=\"02:57.193\">megszűnése</span> <span begin=\"02:57.193\" end=\"02:58.108\">sem.</span></p><p begin=\"02:58.167\" end=\"03:02.629\" ttm:agent=\"v1\" itunes:key=\"L29\"><span begin=\"02:58.167\" end=\"02:58.676\">Nincs</span> <span begin=\"02:58.676\" end=\"03:00.199\">szenvedés,</span> <span begin=\"03:00.199\" end=\"03:00.692\">nincs</span> <span begin=\"03:00.692\" end=\"03:01.666\">annak</span> <span begin=\"03:01.666\" end=\"03:02.629\">oka,</span></p><p begin=\"03:02.669\" end=\"03:06.129\" ttm:agent=\"v1\" itunes:key=\"L30\"><span begin=\"03:02.669\" end=\"03:03.200\">nincs</span> <span begin=\"03:03.200\" end=\"03:04.218\">annak</span> <span begin=\"03:04.218\" end=\"03:06.129\">megszűnése,</span></p><p begin=\"03:06.181\" end=\"03:11.260\" ttm:agent=\"v1\" itunes:key=\"L31\"><span begin=\"03:06.181\" end=\"03:06.735\">és</span> <span begin=\"03:06.735\" end=\"03:07.256\">nincs</span> <span begin=\"03:07.256\" end=\"03:07.992\">útja</span> <span begin=\"03:07.992\" end=\"03:08.748\">a</span> <span begin=\"03:08.748\" end=\"03:11.260\">megszüntetésnek.</span></p><p begin=\"03:11.295\" end=\"03:17.247\" ttm:agent=\"v1\" itunes:key=\"L32\"><span begin=\"03:11.295\" end=\"03:11.866\">Nincs</span> <span begin=\"03:11.866\" end=\"03:14.382\">megvalósítás</span> <span begin=\"03:14.382\" end=\"03:14.864\">és</span> <span begin=\"03:14.864\" end=\"03:15.362\">nincs</span> <span begin=\"03:15.362\" end=\"03:17.247\">megérkezés,</span></p><p begin=\"03:17.394\" end=\"03:22.971\" ttm:agent=\"v1\" itunes:key=\"L33\"><span begin=\"03:17.394\" end=\"03:18.490\">mivel</span> <span begin=\"03:18.490\" end=\"03:18.972\">nincs,</span> <span begin=\"03:18.972\" end=\"03:20.006\">amit</span> <span begin=\"03:20.006\" end=\"03:20.507\">el</span> <span begin=\"03:20.507\" end=\"03:22.019\">kellene</span> <span begin=\"03:22.019\" end=\"03:22.971\">érni.</span></p><p begin=\"03:22.971\" end=\"03:26.018\" ttm:agent=\"v1\" itunes:key=\"L34\"><span begin=\"03:22.971\" end=\"03:23.580\">A</span> <span begin=\"03:23.580\" end=\"03:26.018\">Bódhiszattvának</span></p><p begin=\"03:26.044\" end=\"03:30.969\" ttm:agent=\"v1\" itunes:key=\"L35\"><span begin=\"03:26.044\" end=\"03:26.582\">a</span> <span begin=\"03:26.582\" end=\"03:28.528\">Meghaladó</span> <span begin=\"03:28.528\" end=\"03:30.049\">Bölcsesség</span> <span begin=\"03:30.049\" end=\"03:30.969\">által</span></p><p begin=\"03:31.019\" end=\"03:36.013\" ttm:agent=\"v1\" itunes:key=\"L36\"><span begin=\"03:31.019\" end=\"03:33.166\">akadálytól</span> <span begin=\"03:33.166\" end=\"03:34.152\">mentes</span> <span begin=\"03:34.152\" end=\"03:34.672\">a</span> <span begin=\"03:34.672\" end=\"03:36.013\">tudata.</span></p><p begin=\"03:36.085\" end=\"03:44.662\" ttm:agent=\"v1\" itunes:key=\"L37\"><span begin=\"03:36.085\" end=\"03:37.159\">Mivel</span> <span begin=\"03:37.159\" end=\"03:39.167\">akadálytól</span> <span begin=\"03:39.167\" end=\"03:40.162\">mentes</span> <span begin=\"03:40.162\" end=\"03:40.693\">a</span> <span begin=\"03:40.693\" end=\"03:42.168\">tudata,</span> <span begin=\"03:42.168\" end=\"03:44.662\">rettenthetetlen,</span></p><p begin=\"03:44.702\" end=\"03:50.091\" ttm:agent=\"v1\" itunes:key=\"L38\"><span begin=\"03:44.702\" end=\"03:45.196\">és</span> <span begin=\"03:45.196\" end=\"03:47.116\">meghaladva</span> <span begin=\"03:47.116\" end=\"03:48.213\">minden</span> <span begin=\"03:48.213\" end=\"03:50.091\">illúziót</span></p><p begin=\"03:50.154\" end=\"03:54.076\" ttm:agent=\"v1\" itunes:key=\"L39\"><span begin=\"03:50.154\" end=\"03:50.669\">az</span> <span begin=\"03:50.669\" end=\"03:52.578\">ellobbanást</span> <span begin=\"03:52.578\" end=\"03:54.076\">eléri.</span></p><p begin=\"03:54.116\" end=\"03:59.095\" ttm:agent=\"v1\" itunes:key=\"L40\"><span begin=\"03:54.116\" end=\"03:54.717\">A</span> <span begin=\"03:54.717\" end=\"03:55.680\">három</span> <span begin=\"03:55.680\" end=\"03:56.723\">világ</span> <span begin=\"03:56.723\" end=\"03:57.679\">összes</span> <span begin=\"03:57.679\" end=\"03:59.095\">Buddhái</span></p><p begin=\"03:59.176\" end=\"04:06.711\" ttm:agent=\"v1\" itunes:key=\"L41\"><span begin=\"03:59.176\" end=\"03:59.685\">a</span> <span begin=\"03:59.685\" end=\"04:01.657\">Meghaladó</span> <span begin=\"04:01.657\" end=\"04:03.190\">Bölcsesség</span> <span begin=\"04:03.190\" end=\"04:04.138\">által</span> <span begin=\"04:04.138\" end=\"04:06.139\">valósítják</span> <span begin=\"04:06.139\" end=\"04:06.711\">meg</span></p><p begin=\"04:06.728\" end=\"04:15.712\" ttm:agent=\"v1\" itunes:key=\"L42\"><span begin=\"04:06.728\" end=\"04:07.208\">a</span> <span begin=\"04:07.208\" end=\"04:09.225\">Tökéletes</span> <span begin=\"04:09.225\" end=\"04:09.753\">és</span> <span begin=\"04:09.753\" end=\"04:12.702\">Felülmúlhatatlan</span> <span begin=\"04:12.702\" end=\"04:15.712\">Felébredettséget.</span></p><p begin=\"04:15.775\" end=\"04:22.799\" ttm:agent=\"v1\" itunes:key=\"L43\"><span begin=\"04:15.775\" end=\"04:16.844\">Ezért</span> <span begin=\"04:16.844\" end=\"04:17.804\">ismerd</span> <span begin=\"04:17.804\" end=\"04:18.356\">fel</span> <span begin=\"04:18.356\" end=\"04:18.860\">a</span> <span begin=\"04:18.860\" end=\"04:20.866\">Meghaladó</span> <span begin=\"04:20.866\" end=\"04:22.799\">Bölcsességet,</span></p><p begin=\"04:22.847\" end=\"04:25.323\" ttm:agent=\"v1\" itunes:key=\"L44\"><span begin=\"04:22.847\" end=\"04:23.379\">a</span> <span begin=\"04:23.379\" end=\"04:23.836\">Nagy</span> <span begin=\"04:23.836\" end=\"04:24.362\">Szent</span> <span begin=\"04:24.362\" end=\"04:25.323\">Eszmét,</span></p><p begin=\"04:25.374\" end=\"04:28.766\" ttm:agent=\"v1\" itunes:key=\"L45\"><span begin=\"04:25.374\" end=\"04:25.867\">a</span> <span begin=\"04:25.867\" end=\"04:26.388\">Nagy</span> <span begin=\"04:26.388\" end=\"04:27.379\">Tudás</span> <span begin=\"04:27.379\" end=\"04:28.766\">Eszméjét,</span></p><p begin=\"04:28.855\" end=\"04:33.372\" ttm:agent=\"v1\" itunes:key=\"L46\"><span begin=\"04:28.855\" end=\"04:29.398\">a</span> <span begin=\"04:29.398\" end=\"04:32.399\">Felülmúlhatatlan</span> <span begin=\"04:32.399\" end=\"04:33.372\">Eszmét,</span></p><p begin=\"04:33.417\" end=\"04:37.781\" ttm:agent=\"v1\" itunes:key=\"L47\"><span begin=\"04:33.417\" end=\"04:33.953\">a</span> <span begin=\"04:33.953\" end=\"04:36.918\">Hasonlíthatatlan</span> <span begin=\"04:36.918\" end=\"04:37.781\">Eszmét,</span></p><p begin=\"04:37.861\" end=\"04:43.853\" ttm:agent=\"v1\" itunes:key=\"L48\"><span begin=\"04:37.861\" end=\"04:38.402\">azt,</span> <span begin=\"04:38.402\" end=\"04:39.414\">ami</span> <span begin=\"04:39.414\" end=\"04:40.375\">véget</span> <span begin=\"04:40.375\" end=\"04:40.912\">vet</span> <span begin=\"04:40.912\" end=\"04:41.816\">minden</span> <span begin=\"04:41.816\" end=\"04:43.853\">szenvedésnek.</span></p><p begin=\"04:43.889\" end=\"04:47.846\" ttm:agent=\"v1\" itunes:key=\"L49\"><span begin=\"04:43.889\" end=\"04:44.381\">Ez</span> <span begin=\"04:44.381\" end=\"04:45.929\">igazság,</span> <span begin=\"04:45.929\" end=\"04:46.387\">nem</span> <span begin=\"04:46.387\" end=\"04:47.846\">hazugság.</span></p><p begin=\"04:47.889\" end=\"04:50.380\" ttm:agent=\"v1\" itunes:key=\"L50\"><span begin=\"04:47.889\" end=\"04:48.905\">Ezért</span> <span begin=\"04:48.905\" end=\"04:50.380\">hangoztasd</span></p><p begin=\"04:50.449\" end=\"04:55.871\" ttm:agent=\"v1\" itunes:key=\"L51\"><span begin=\"04:50.449\" end=\"04:50.941\">a</span> <span begin=\"04:50.941\" end=\"04:52.914\">Meghaladó</span> <span begin=\"04:52.914\" end=\"04:54.458\">Bölcsesség</span> <span begin=\"04:54.458\" end=\"04:55.871\">Eszméjét,</span></p><p begin=\"04:55.926\" end=\"04:57.950\" ttm:agent=\"v1\" itunes:key=\"L52\"><span begin=\"04:55.926\" end=\"04:56.942\">amely</span> <span begin=\"04:56.942\" end=\"04:57.436\">így</span> <span begin=\"04:57.436\" end=\"04:57.950\">szól:</span></p><p begin=\"04:57.979\" end=\"05:01.970\" ttm:agent=\"v1\" itunes:key=\"L53\"><span begin=\"04:57.979\" end=\"04:58.974\">gáté</span> <span begin=\"04:58.974\" end=\"05:00.026\">gáté</span> <span begin=\"05:00.026\" end=\"05:01.970\">párágáté</span></p><p begin=\"05:02.083\" end=\"05:06.113\" ttm:agent=\"v1\" itunes:key=\"L54\"><span begin=\"05:02.083\" end=\"05:04.149\">párászámgáté</span> <span begin=\"05:04.149\" end=\"05:05.004\">bódhi</span> <span begin=\"05:05.004\" end=\"05:06.113\">szváhá</span> </p><p begin=\"05:06.151\" end=\"05:10.182\" ttm:agent=\"v1\" itunes:key=\"L55\"><span begin=\"05:06.151\" end=\"05:07.186\">gáté</span> <span begin=\"05:07.186\" end=\"05:08.187\">gáté</span> <span begin=\"05:08.187\" end=\"05:10.182\">párágáté</span></p><p begin=\"05:10.257\" end=\"05:14.285\" ttm:agent=\"v1\" itunes:key=\"L56\"><span begin=\"05:10.257\" end=\"05:12.306\">párászámgáté</span> <span begin=\"05:12.306\" end=\"05:13.264\">bódhi</span> <span begin=\"05:13.264\" end=\"05:14.285\">szváhá</span></p><p begin=\"05:14.327\" end=\"05:18.330\" ttm:agent=\"v1\" itunes:key=\"L57\"><span begin=\"05:14.327\" end=\"05:15.351\">gáté</span> <span begin=\"05:15.351\" end=\"05:16.352\">gáté</span> <span begin=\"05:16.352\" end=\"05:18.330\">párágáté</span></p><p begin=\"05:18.399\" end=\"05:26.915\" ttm:agent=\"v1\" itunes:key=\"L58\"><span begin=\"05:18.399\" end=\"05:20.449\">párászámgáté</span> <span begin=\"05:20.449\" end=\"05:21.069\">bódhi</span> <span begin=\"05:21.069\" end=\"05:26.915\">szváhá</span></p></div></body></tt>"
}
```

**Tool Call: Read file `test/ttml_parser_test.dart`**
Status: Completed

```json
{
  "Text": "import 'package:flutter_test/flutter_test.dart';\n\nimport 'package:ttml_parser/ttml_parser.dart';\n\nvoid main() {\n  test('adds one to input values', () {\n    final calculator = Calculator();\n    expect(calculator.addOne(2), 3);\n    expect(calculator.addOne(-7), -6);\n    expect(calculator.addOne(0), 1);\n  });\n}\n"
}
```

**Tool Call: thinking**
Status: Completed

Finished thinking.

## Assistant

Now I have a complete picture of the project. Here's the implementation plan:

---

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

---

That covers everything from the spec. Want me to start implementing it, or would you like to adjust anything in the plan first?

