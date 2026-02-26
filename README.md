# ttml_parser

A Dart/Flutter package for parsing TTML (Timed Text Markup Language) lyric files into a structured data model, designed for building karaoke-style lyric experiences.

Targets the Apple Music TTML dialect (`itunes:timing="Word"`), which provides word-level timing for smooth highlight animations.

## Features

- Parses TTML XML into typed Dart objects
- Exposes timing at both the **line** and **word** level
- Identifies multiple vocal agents (lead vocals, background vocals, etc.)
- Extracts total track duration from the document
- Stateless, reusable parser — safe to call multiple times
- Clear error reporting via `TtmlParseException`

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  ttml_parser:
    path: ../ttml_parser  # adjust to your local path
```

Then run:

```sh
flutter pub get
```

## Usage

```dart
import 'package:ttml_parser/ttml_parser.dart';

const parser = TtmlParser();

// Pass the raw TTML string to parse()
final TtmlDocument doc = parser.parse(ttmlString);

// Total track duration (from <body dur="…">)
print(doc.totalDuration); // e.g. Duration(minutes: 5, seconds: 26, ...)

// Agents (voices) declared in the document
for (final agent in doc.agents) {
  print('${agent.id}: ${agent.type}'); // e.g. "v1: person"
}

// Lyric lines and their words
for (final line in doc.lines) {
  print(line.text);   // full line text, words joined by spaces
  print(line.begin);  // Duration when the line starts
  print(line.end);    // Duration when the line ends

  for (final word in line.words) {
    print('  ${word.text} [${word.begin} → ${word.end}]');
  }
}
```

### Error handling

```dart
try {
  final doc = parser.parse(ttmlString);
} on TtmlParseException catch (e) {
  print('Parse failed: ${e.message}');
  if (e.cause != null) print('Caused by: ${e.cause}');
}
```

## Data model

```
TtmlDocument
├── totalDuration : Duration?
├── agents        : List<TtmlAgent>
│     ├── id      : String          // e.g. "v1"
│     └── type    : String          // "person" or "other"
└── lines         : List<TtmlLine>
      ├── begin   : Duration
      ├── end     : Duration
      ├── agentId : String?         // references an agent id
      ├── key     : String?         // e.g. "L1"
      ├── text    : String          // convenience getter
      ├── duration: Duration        // convenience getter
      └── words   : List<TtmlWord>
            ├── begin    : Duration
            ├── end      : Duration
            ├── text     : String
            └── duration : Duration // convenience getter
```

### Agent types

| Type       | Meaning                        |
|------------|--------------------------------|
| `"person"` | Lead vocalist                  |
| `"other"`  | Background vocals / choir      |

## Time format

All `begin`, `end`, and `dur` attributes follow the `[HH:]MM:SS.mmm` pattern and are converted to Dart `Duration` objects.

## Dependencies

| Package | Purpose        |
|---------|----------------|
| [`xml`](https://pub.dev/packages/xml) | XML parsing |

## License

See [LICENSE](LICENSE).