## User

Let's create a specification for an example that will demonstrate how to use `ttml_parser` package. The specification will be used by an ai agent to implement it.

The example application should be a karaoke application that will loads the necessary resources in the initialization process, parses it with `ttml_parser` and displays an apple music like audio player with controls at the bottom and the lyrics full screen.

Apply the guidance from the [@specification.md](file:///Users/adam/Projects/ttml_parser/docs/specification.md) document 11. section.

**Tool Call: Read file `docs/specification.md` (lines 426-456)**
Status: Completed

```json
{
  "Text": "## 11. Rendering Guidance (Non-Normative)\n\nThis section is informational and does not affect the parser implementation.\n\nA karaoke renderer consuming `TtmlDocument` can use the following approach:\n\n1. **Line activation**: At playback position `t`, display all lines where `line.begin <= t < line.end`. Lines outside this window may be shown as upcoming or past lyrics.\n\n2. **Word highlighting**: Within an active line, highlight each word where `word.begin <= t < word.end`. Words before this range are fully highlighted (sung); words after are unhighlighted (pending).\n\n3. **Voice differentiation**: Use `line.agentId` to look up the corresponding `TtmlAgent`. Render `\"person\"` agents with the primary lyric style (e.g., left-aligned, white fill) and `\"other\"` agents with a secondary style (e.g., right-aligned, grey fill).\n\n4. **Progress within a word**: For smooth sub-word animation, compute `progress = (t - word.begin) / word.duration` (clamped to `[0.0, 1.0]`) and use it to drive a fill or clip animation on the word's text widget.\n\n---\n\n## 12. Sample Data\n\nThe file `assets/heart_sutra.ttml` is bundled with the package for use in tests. It contains a Hungarian translation of the Heart Sutra set to music, with word-level timing across 58 lyric lines (`L1`–`L58`). Line `L1` (agent `v2`) is an instrumental placeholder whose span text values are all `\"0\"` and must be parsed without special-casing.\n\n---\n\n## 13. Acceptance Criteria\n\nThe implementation is considered complete when:\n\n1. All tests described in §10 pass with `flutter test`.\n2. `flutter analyze` reports zero errors and zero warnings.\n3. The public API surface matches exactly the symbols listed in §7.\n4. The parser correctly round-trips the bundled `heart_sutra.ttml` file: every line and every word is present, in order, with correct timing.\n5. No mutable state is held by `TtmlParser` between calls to `parse`."
}
```

**Tool Call: List the `ttml_parser` directory's contents**
Status: Completed

# Folders:
ttml_parser/.dart_tool
ttml_parser/.idea
ttml_parser/assets
ttml_parser/build
ttml_parser/docs
ttml_parser/example
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
ttml_parser/ttml_parser.iml


**Tool Call: List the `ttml_parser/lib` directory's contents**
Status: Completed

# Folders:
ttml_parser/lib/src

# Files:
ttml_parser/lib/ttml_parser.dart


**Tool Call: List the `ttml_parser/assets` directory's contents**
Status: Completed


# Files:
ttml_parser/assets/heart_sutra.ttml
ttml_parser/assets/heart_sutra_hu.mp3


**Tool Call: List the `ttml_parser/example` directory's contents**
Status: Completed

# Folders:
ttml_parser/example/.dart_tool
ttml_parser/example/.idea
ttml_parser/example/android
ttml_parser/example/assets
ttml_parser/example/ios
ttml_parser/example/lib
ttml_parser/example/linux
ttml_parser/example/macos
ttml_parser/example/test
ttml_parser/example/web
ttml_parser/example/windows

# Files:
ttml_parser/example/.gitignore
ttml_parser/example/.metadata
ttml_parser/example/README.md
ttml_parser/example/analysis_options.yaml
ttml_parser/example/example.iml
ttml_parser/example/pubspec.lock
ttml_parser/example/pubspec.yaml


**Tool Call: Read file `lib/ttml_parser.dart`**
Status: Completed

```json
{
  "Text": "export 'src/exceptions/ttml_parse_exception.dart';\nexport 'src/models/ttml_agent.dart';\nexport 'src/models/ttml_document.dart';\nexport 'src/models/ttml_line.dart';\nexport 'src/models/ttml_word.dart';\nexport 'src/parser/ttml_parser.dart';"
}
```

**Tool Call: List the `ttml_parser/example/lib` directory's contents**
Status: Completed


# Files:
ttml_parser/example/lib/main.dart


**Tool Call: Read file `example/pubspec.yaml`**
Status: Completed

```json
{
  "Text": "name: example\ndescription: \"A new Flutter project.\"\n# The following line prevents the package from being accidentally published to\n# pub.dev using `flutter pub publish`. This is preferred for private packages.\npublish_to: 'none' # Remove this line if you wish to publish to pub.dev\n\n# The following defines the version and build number for your application.\n# A version number is three numbers separated by dots, like 1.2.43\n# followed by an optional build number separated by a +.\n# Both the version and the builder number may be overridden in flutter\n# build by specifying --build-name and --build-number, respectively.\n# In Android, build-name is used as versionName while build-number used as versionCode.\n# Read more about Android versioning at https://developer.android.com/studio/publish/versioning\n# In iOS, build-name is used as CFBundleShortVersionString while build-number is used as CFBundleVersion.\n# Read more about iOS versioning at\n# https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CoreFoundationKeys.html\n# In Windows, build-name is used as the major, minor, and patch parts\n# of the product and file versions while build-number is used as the build suffix.\nversion: 1.0.0+1\n\nenvironment:\n  sdk: ^3.10.8\n\n# Dependencies specify other packages that your package needs in order to work.\n# To automatically upgrade your package dependencies to the latest versions\n# consider running `flutter pub upgrade --major-versions`. Alternatively,\n# dependencies can be manually updated by changing the version numbers below to\n# the latest version available on pub.dev. To see which dependencies have newer\n# versions available, run `flutter pub outdated`.\ndependencies:\n  flutter:\n    sdk: flutter\n\n  # The following adds the Cupertino Icons font to your application.\n  # Use with the CupertinoIcons class for iOS style icons.\n  cupertino_icons: ^1.0.8\n\ndev_dependencies:\n  flutter_test:\n    sdk: flutter\n\n  # The \"flutter_lints\" package below contains a set of recommended lints to\n  # encourage good coding practices. The lint set provided by the package is\n  # activated in the `analysis_options.yaml` file located at the root of your\n  # package. See that file for information about deactivating specific lint\n  # rules and activating additional ones.\n  flutter_lints: ^6.0.0\n\n# For information on the generic Dart part of this file, see the\n# following page: https://dart.dev/tools/pub/pubspec\n\n# The following section is specific to Flutter packages.\nflutter:\n\n  # The following line ensures that the Material Icons font is\n  # included with your application, so that you can use the icons in\n  # the material Icons class.\n  uses-material-design: true\n\n  # To add assets to your application, add an assets section, like this:\n  # assets:\n  #   - images/a_dot_burr.jpeg\n  #   - images/a_dot_ham.jpeg\n\n  # An image asset can refer to one or more resolution-specific \"variants\", see\n  # https://flutter.dev/to/resolution-aware-images\n\n  # For details regarding adding assets from package dependencies, see\n  # https://flutter.dev/to/asset-from-package\n\n  # To add custom fonts to your application, add a fonts section here,\n  # in this \"flutter\" section. Each entry in this list should have a\n  # \"family\" key with the font family name, and a \"fonts\" key with a\n  # list giving the asset and other descriptors for the font. For\n  # example:\n  # fonts:\n  #   - family: Schyler\n  #     fonts:\n  #       - asset: fonts/Schyler-Regular.ttf\n  #       - asset: fonts/Schyler-Italic.ttf\n  #         style: italic\n  #   - family: Trajan Pro\n  #     fonts:\n  #       - asset: fonts/TrajanPro.ttf\n  #       - asset: fonts/TrajanPro_Bold.ttf\n  #         weight: 700\n  #\n  # For details regarding fonts from package dependencies,\n  # see https://flutter.dev/to/font-from-package\n"
}
```

**Tool Call: Read file `example/lib/main.dart`**
Status: Completed

```json
{
  "Text": "import 'package:flutter/material.dart';\n\nvoid main() {\n  runApp(const MyApp());\n}\n\nclass MyApp extends StatelessWidget {\n  const MyApp({super.key});\n\n  // This widget is the root of your application.\n  @override\n  Widget build(BuildContext context) {\n    return MaterialApp(\n      title: 'Flutter Demo',\n      theme: ThemeData(\n        // This is the theme of your application.\n        //\n        // TRY THIS: Try running your application with \"flutter run\". You'll see\n        // the application has a purple toolbar. Then, without quitting the app,\n        // try changing the seedColor in the colorScheme below to Colors.green\n        // and then invoke \"hot reload\" (save your changes or press the \"hot\n        // reload\" button in a Flutter-supported IDE, or press \"r\" if you used\n        // the command line to start the app).\n        //\n        // Notice that the counter didn't reset back to zero; the application\n        // state is not lost during the reload. To reset the state, use hot\n        // restart instead.\n        //\n        // This works for code too, not just values: Most code changes can be\n        // tested with just a hot reload.\n        colorScheme: .fromSeed(seedColor: Colors.deepPurple),\n      ),\n      home: const MyHomePage(title: 'Flutter Demo Home Page'),\n    );\n  }\n}\n\nclass MyHomePage extends StatefulWidget {\n  const MyHomePage({super.key, required this.title});\n\n  // This widget is the home page of your application. It is stateful, meaning\n  // that it has a State object (defined below) that contains fields that affect\n  // how it looks.\n\n  // This class is the configuration for the state. It holds the values (in this\n  // case the title) provided by the parent (in this case the App widget) and\n  // used by the build method of the State. Fields in a Widget subclass are\n  // always marked \"final\".\n\n  final String title;\n\n  @override\n  State<MyHomePage> createState() => _MyHomePageState();\n}\n\nclass _MyHomePageState extends State<MyHomePage> {\n  int _counter = 0;\n\n  void _incrementCounter() {\n    setState(() {\n      // This call to setState tells the Flutter framework that something has\n      // changed in this State, which causes it to rerun the build method below\n      // so that the display can reflect the updated values. If we changed\n      // _counter without calling setState(), then the build method would not be\n      // called again, and so nothing would appear to happen.\n      _counter++;\n    });\n  }\n\n  @override\n  Widget build(BuildContext context) {\n    // This method is rerun every time setState is called, for instance as done\n    // by the _incrementCounter method above.\n    //\n    // The Flutter framework has been optimized to make rerunning build methods\n    // fast, so that you can just rebuild anything that needs updating rather\n    // than having to individually change instances of widgets.\n    return Scaffold(\n      appBar: AppBar(\n        // TRY THIS: Try changing the color here to a specific color (to\n        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar\n        // change color while the other colors stay the same.\n        backgroundColor: Theme.of(context).colorScheme.inversePrimary,\n        // Here we take the value from the MyHomePage object that was created by\n        // the App.build method, and use it to set our appbar title.\n        title: Text(widget.title),\n      ),\n      body: Center(\n        // Center is a layout widget. It takes a single child and positions it\n        // in the middle of the parent.\n        child: Column(\n          // Column is also a layout widget. It takes a list of children and\n          // arranges them vertically. By default, it sizes itself to fit its\n          // children horizontally, and tries to be as tall as its parent.\n          //\n          // Column has various properties to control how it sizes itself and\n          // how it positions its children. Here we use mainAxisAlignment to\n          // center the children vertically; the main axis here is the vertical\n          // axis because Columns are vertical (the cross axis would be\n          // horizontal).\n          //\n          // TRY THIS: Invoke \"debug painting\" (choose the \"Toggle Debug Paint\"\n          // action in the IDE, or press \"p\" in the console), to see the\n          // wireframe for each widget.\n          mainAxisAlignment: .center,\n          children: [\n            const Text('You have pushed the button this many times:'),\n            Text(\n              '$_counter',\n              style: Theme.of(context).textTheme.headlineMedium,\n            ),\n          ],\n        ),\n      ),\n      floatingActionButton: FloatingActionButton(\n        onPressed: _incrementCounter,\n        tooltip: 'Increment',\n        child: const Icon(Icons.add),\n      ),\n    );\n  }\n}\n"
}
```

**Tool Call: List the `ttml_parser/example/assets` directory's contents**
Status: Completed


# Files:
ttml_parser/example/assets/heart_sutra_hu.mp3
ttml_parser/example/assets/heart_sutra_hu.ttml


**Tool Call: List the `ttml_parser/lib/src` directory's contents**
Status: Completed

# Folders:
ttml_parser/lib/src/exceptions
ttml_parser/lib/src/models
ttml_parser/lib/src/parser


**Tool Call: List the `ttml_parser/lib/src/models` directory's contents**
Status: Completed


# Files:
ttml_parser/lib/src/models/ttml_agent.dart
ttml_parser/lib/src/models/ttml_document.dart
ttml_parser/lib/src/models/ttml_line.dart
ttml_parser/lib/src/models/ttml_word.dart


**Tool Call: List the `ttml_parser/lib/src/exceptions` directory's contents**
Status: Completed


# Files:
ttml_parser/lib/src/exceptions/ttml_parse_exception.dart


**Tool Call: List the `ttml_parser/lib/src/parser` directory's contents**
Status: Completed


# Files:
ttml_parser/lib/src/parser/time_parser.dart
ttml_parser/lib/src/parser/ttml_parser.dart


**Tool Call: Read file `lib/src/models/ttml_document.dart`**
Status: Completed

```json
{
  "Text": "import 'ttml_agent.dart';\nimport 'ttml_line.dart';\n\n/// The top-level result of parsing a TTML lyric document.\nclass TtmlDocument {\n  /// The total duration of the document, taken from the `dur` attribute on\n  /// `<body>`, or `null` if the attribute is absent.\n  final Duration? totalDuration;\n\n  /// The agents (voices) declared in the document's `<head><metadata>` section.\n  final List<TtmlAgent> agents;\n\n  /// The lyric lines parsed from the document's `<body>` section, in document\n  /// order.\n  final List<TtmlLine> lines;\n\n  /// Creates a [TtmlDocument] with the given [totalDuration], [agents], and\n  /// [lines].\n  ///\n  /// Both [agents] and [lines] are stored as unmodifiable views.\n  TtmlDocument({\n    required this.totalDuration,\n    required List<TtmlAgent> agents,\n    required List<TtmlLine> lines,\n  })  : agents = List.unmodifiable(agents),\n        lines = List.unmodifiable(lines);\n\n  @override\n  String toString() =>\n      'TtmlDocument(totalDuration: $totalDuration, agents: ${agents.length}, '\n      'lines: ${lines.length})';\n}"
}
```

**Tool Call: Read file `lib/src/models/ttml_word.dart`**
Status: Completed

```json
{
  "Text": "/// A single timed word or syllable within a lyric line.\nclass TtmlWord {\n  /// The time at which this word begins.\n  final Duration begin;\n\n  /// The time at which this word ends.\n  final Duration end;\n\n  /// The text content of this word.\n  final String text;\n\n  /// The duration of this word, computed as [end] minus [begin].\n  Duration get duration => end - begin;\n\n  /// Creates a [TtmlWord] with the given [begin], [end], and [text].\n  const TtmlWord({\n    required this.begin,\n    required this.end,\n    required this.text,\n  });\n\n  @override\n  bool operator ==(Object other) =>\n      identical(this, other) ||\n      other is TtmlWord &&\n          begin == other.begin &&\n          end == other.end &&\n          text == other.text;\n\n  @override\n  int get hashCode => Object.hash(begin, end, text);\n\n  @override\n  String toString() => 'TtmlWord(text: \"$text\", begin: $begin, end: $end)';\n}"
}
```

**Tool Call: Read file `lib/src/models/ttml_agent.dart`**
Status: Completed

```json
{
  "Text": "/// A participant (voice) in a TTML lyric document.\nclass TtmlAgent {\n  /// The unique identifier for this agent, corresponding to the `xml:id`\n  /// attribute on the `<ttm:agent>` element.\n  final String id;\n\n  /// The type of this agent (e.g. `\"person\"` or `\"other\"`).\n  final String type;\n\n  /// Creates a [TtmlAgent] with the given [id] and [type].\n  const TtmlAgent({required this.id, required this.type});\n\n  @override\n  bool operator ==(Object other) =>\n      identical(this, other) ||\n      other is TtmlAgent && id == other.id && type == other.type;\n\n  @override\n  int get hashCode => Object.hash(id, type);\n\n  @override\n  String toString() => 'TtmlAgent(id: \"$id\", type: \"$type\")';\n}"
}
```

**Tool Call: Read file `lib/src/parser/ttml_parser.dart`**
Status: Completed

```json
{
  "Text": "import 'package:xml/xml.dart';\n\nimport '../exceptions/ttml_parse_exception.dart';\nimport '../models/ttml_agent.dart';\nimport '../models/ttml_document.dart';\nimport '../models/ttml_line.dart';\nimport '../models/ttml_word.dart';\nimport 'time_parser.dart';\n\n// Namespace URIs used in TTML documents.\nconst _ttmlNs = 'http://www.w3.org/ns/ttml';\nconst _ttmlMetaNs = 'http://www.w3.org/ns/ttml#metadata';\n\nconst _itunesNs = 'http://music.apple.com/lyric-ttml-internal';\n\n/// Parses a TTML lyric document into a [TtmlDocument].\n///\n/// [TtmlParser] is stateless — the same instance may be used to parse any\n/// number of documents concurrently or sequentially.\nclass TtmlParser {\n  /// Creates a [TtmlParser].\n  const TtmlParser();\n\n  /// Parses [ttmlContent] and returns a [TtmlDocument].\n  ///\n  /// Throws [TtmlParseException] if the input is malformed XML, is missing\n  /// required elements or attributes, or contains invalid time strings.\n  TtmlDocument parse(String ttmlContent) {\n    // Step 1 — Parse XML.\n    final XmlDocument xmlDoc;\n    try {\n      xmlDoc = XmlDocument.parse(ttmlContent);\n    } on XmlParserException catch (e) {\n      throw TtmlParseException('Malformed XML: ${e.message}', cause: e);\n    }\n\n    // Step 2 — Locate the root <tt> element.\n    final tt = xmlDoc\n        .findElements('tt', namespace: _ttmlNs)\n        .cast<XmlElement?>()\n        .firstWhere((_) => true, orElse: () => null);\n\n    if (tt == null) {\n      throw const TtmlParseException('Missing root <tt> element');\n    }\n\n    // Step 3 — Extract agents from <head><metadata>.\n    final agents = _parseAgents(tt);\n\n    // Step 4 — Extract total duration from <body>.\n    final body = tt\n        .findElements('body', namespace: _ttmlNs)\n        .cast<XmlElement?>()\n        .firstWhere((_) => true, orElse: () => null);\n\n    Duration? totalDuration;\n    if (body != null) {\n      final durAttr = body.getAttribute('dur');\n      if (durAttr != null) {\n        totalDuration = parseTime(durAttr);\n      }\n    }\n\n    // Step 5 — Collect all <p> elements from <div> children of <body>.\n    final pElements = <XmlElement>[];\n    if (body != null) {\n      for (final div in body.findElements('div', namespace: _ttmlNs)) {\n        for (final p in div.findElements('p', namespace: _ttmlNs)) {\n          pElements.add(p);\n        }\n      }\n    }\n\n    // Steps 6 & 7 — Parse each <p> into a TtmlLine (which parses its <span>s).\n    final lines = pElements.map(_parseLine).toList();\n\n    // Step 8 — Assemble and return.\n    return TtmlDocument(\n      totalDuration: totalDuration,\n      agents: agents,\n      lines: lines,\n    );\n  }\n\n  List<TtmlAgent> _parseAgents(XmlElement tt) {\n    final agents = <TtmlAgent>[];\n\n    for (final head in tt.findElements('head', namespace: _ttmlNs)) {\n      for (final metadata in head.findElements('metadata', namespace: _ttmlNs)) {\n        for (final agentEl\n            in metadata.findElements('agent', namespace: _ttmlMetaNs)) {\n          final id = agentEl.getAttribute('xml:id');\n          if (id == null) {\n            throw const TtmlParseException(\n              '<ttm:agent> is missing the required xml:id attribute',\n            );\n          }\n          final type = agentEl.getAttribute('type');\n          if (type == null) {\n            throw TtmlParseException(\n              '<ttm:agent id=\"$id\"> is missing the required type attribute',\n            );\n          }\n          agents.add(TtmlAgent(id: id, type: type));\n        }\n      }\n    }\n\n    return agents;\n  }\n\n  TtmlLine _parseLine(XmlElement p) {\n    final beginStr = p.getAttribute('begin');\n    if (beginStr == null) {\n      throw const TtmlParseException(\n        '<p> is missing the required begin attribute',\n      );\n    }\n\n    final endStr = p.getAttribute('end');\n    if (endStr == null) {\n      throw const TtmlParseException(\n        '<p> is missing the required end attribute',\n      );\n    }\n\n    final begin = parseTime(beginStr);\n    final end = parseTime(endStr);\n\n    final agentId = p.getAttribute('agent', namespace: _ttmlMetaNs);\n    final key = p.getAttribute('key', namespace: _itunesNs);\n\n    // Step 7 — Parse direct child <span> elements into TtmlWord instances.\n    final words = <TtmlWord>[];\n    for (final span in p.findElements('span', namespace: _ttmlNs)) {\n      final word = _parseWord(span);\n      if (word != null) {\n        words.add(word);\n      }\n    }\n\n    return TtmlLine(\n      begin: begin,\n      end: end,\n      agentId: agentId,\n      key: key,\n      words: words,\n    );\n  }\n\n  TtmlWord? _parseWord(XmlElement span) {\n    final beginStr = span.getAttribute('begin');\n    if (beginStr == null) {\n      throw const TtmlParseException(\n        '<span> is missing the required begin attribute',\n      );\n    }\n\n    final endStr = span.getAttribute('end');\n    if (endStr == null) {\n      throw const TtmlParseException(\n        '<span> is missing the required end attribute',\n      );\n    }\n\n    final text = span.innerText.trim();\n    if (text.isEmpty) {\n      return null;\n    }\n\n    return TtmlWord(\n      begin: parseTime(beginStr),\n      end: parseTime(endStr),\n      text: text,\n    );\n  }\n}"
}
```

**Tool Call: Read file `lib/src/models/ttml_line.dart`**
Status: Completed

```json
{
  "Text": "import 'ttml_word.dart';\n\n/// A single lyric line, corresponding to a `<p>` element in the TTML document.\nclass TtmlLine {\n  /// The time at which this line begins.\n  final Duration begin;\n\n  /// The time at which this line ends.\n  final Duration end;\n\n  /// The identifier of the [TtmlAgent] responsible for this line, if present.\n  final String? agentId;\n\n  /// The lyric key for this line (e.g. `\"L2\"`), if present.\n  final String? key;\n\n  /// The words that make up this line.\n  final List<TtmlWord> words;\n\n  /// The full text of this line, formed by joining each word's [TtmlWord.text]\n  /// with a single space.\n  String get text => words.map((w) => w.text).join(' ');\n\n  /// The duration of this line, computed as [end] minus [begin].\n  Duration get duration => end - begin;\n\n  /// Creates a [TtmlLine] with the given timing, optional [agentId] and [key],\n  /// and a list of [words].\n  ///\n  /// The [words] list is stored as an unmodifiable view.\n  TtmlLine({\n    required this.begin,\n    required this.end,\n    this.agentId,\n    this.key,\n    required List<TtmlWord> words,\n  }) : words = List.unmodifiable(words);\n\n  @override\n  bool operator ==(Object other) =>\n      identical(this, other) ||\n      other is TtmlLine &&\n          begin == other.begin &&\n          end == other.end &&\n          agentId == other.agentId &&\n          key == other.key &&\n          _listsEqual(words, other.words);\n\n  @override\n  int get hashCode => Object.hash(begin, end, agentId, key, Object.hashAll(words));\n\n  @override\n  String toString() =>\n      'TtmlLine(key: \"$key\", agentId: \"$agentId\", begin: $begin, end: $end, '\n      'words: ${words.length}, text: $text)';\n\n  static bool _listsEqual(List<TtmlWord> a, List<TtmlWord> b) {\n    if (a.length != b.length) return false;\n    for (var i = 0; i < a.length; i++) {\n      if (a[i] != b[i]) return false;\n    }\n    return true;\n  }\n}"
}
```

**Tool Call: Read file `docs/specification.md` (lines 109-120)**
Status: Completed

```json
{
  "Text": "### 2.6 Agent Types\n\n| Type | Meaning | Suggested rendering |\n|------|---------|---------------------|\n| `\"person\"` | A human vocalist | Primary lyric colour; left-aligned |\n| `\"other\"` | Background vocals, choir, etc. | Secondary colour; right-aligned or smaller |\n\n---\n\n## 3. Output Data Model\n\nAll classes are immutable (every field is `final`). All durations are represented as Dart `Duration` objects.\n"
}
```

**Tool Call: Read file `example/assets/heart_sutra_hu.ttml` (lines 1-40)**
Status: Completed

```json
{
  "Text": "<tt xmlns=\"http://www.w3.org/ns/ttml\" xmlns:ttm=\"http://www.w3.org/ns/ttml#metadata\" xmlns:amll=\"http://www.example.com/ns/amll\" xmlns:itunes=\"http://music.apple.com/lyric-ttml-internal\" itunes:timing=\"Word\"><head><metadata><ttm:agent type=\"person\" xml:id=\"v1\"/><ttm:agent type=\"other\" xml:id=\"v2\"/></metadata></head><body dur=\"05:26.915\"><div begin=\"00:01.448\" end=\"05:26.915\"><p begin=\"00:01.448\" end=\"00:07.500\" ttm:agent=\"v2\" itunes:key=\"L1\"><span begin=\"00:01.427\" end=\"00:01.991\">0</span><span begin=\"00:02.333\" end=\"00:02.622\">0</span><span begin=\"00:02.814\" end=\"00:02.974\">0</span><span begin=\"00:03.127\" end=\"00:03.271\">0</span><span begin=\"00:03.388\" end=\"00:03.527\">0</span><span begin=\"00:03.613\" end=\"00:03.727\">0</span><span begin=\"00:03.807\" end=\"00:03.922\">0</span><span begin=\"00:03.995\" end=\"00:04.098\">0</span><span begin=\"00:04.173\" end=\"00:04.288\">0</span><span begin=\"00:04.351\" end=\"00:04.448\">0</span><span begin=\"00:04.511\" end=\"00:04.630\">0</span><span begin=\"00:04.670\" end=\"00:04.796\">0</span><span begin=\"00:04.853\" end=\"00:04.922\">0</span><span begin=\"00:04.979\" end=\"00:05.059\">0</span><span begin=\"00:05.139\" end=\"00:05.208\">0</span><span begin=\"00:06.403\" end=\"00:06.872\">0</span></p><p begin=\"00:07.733\" end=\"00:41.898\" ttm:agent=\"v1\" itunes:key=\"L2\"><span begin=\"00:07.733\" end=\"00:12.124\">Mahá</span> <span begin=\"00:12.814\" end=\"00:18.949\">Prádzsnyá</span> <span begin=\"00:19.107\" end=\"00:27.700\">Párámitá</span> <span begin=\"00:27.866\" end=\"00:33.665\">Hridájá</span> <span begin=\"00:33.965\" end=\"00:41.898\">Szútra</span></p><p begin=\"00:42.701\" end=\"00:48.997\" ttm:agent=\"v1\" itunes:key=\"L3\"><span begin=\"00:42.701\" end=\"00:46.954\">Avalókitésvara</span> <span begin=\"00:47.027\" end=\"00:48.997\">Bódhiszattva</span></p><p begin=\"00:49.143\" end=\"00:56.759\" ttm:agent=\"v1\" itunes:key=\"L4\"><span begin=\"00:49.143\" end=\"00:49.353\">a</span> <span begin=\"00:49.353\" end=\"00:50.193\">mély</span> <span begin=\"00:50.218\" end=\"00:52.288\">Meghaladó</span> <span begin=\"00:52.308\" end=\"00:54.328\">Bölcsességben</span> <span begin=\"00:54.473\" end=\"00:55.810\">időzvén</span> <span begin=\"00:55.884\" end=\"00:56.759\">látja,</span></p><p begin=\"00:56.957\" end=\"01:04.097\" ttm:agent=\"v1\" itunes:key=\"L5\"><span begin=\"00:56.957\" end=\"00:57.592\">hogy</span> <span begin=\"00:57.592\" end=\"00:58.547\">igaz</span> <span begin=\"00:58.547\" end=\"01:01.155\">természetében</span> <span begin=\"01:01.155\" end=\"01:01.710\">az</span> <span begin=\"01:01.710\" end=\"01:02.120\">öt</span> <span begin=\"01:02.120\" end=\"01:03.140\">szkandha</span> <span begin=\"01:03.140\" end=\"01:04.097\">üres,</span></p><p begin=\"01:04.203\" end=\"01:09.790\" ttm:agent=\"v1\" itunes:key=\"L6\"><span begin=\"01:04.203\" end=\"01:04.923\">és</span> <span begin=\"01:04.923\" end=\"01:05.858\">ezzel</span> <span begin=\"01:05.858\" end=\"01:06.743\">minden</span> <span begin=\"01:06.743\" end=\"01:08.208\">szenvedést</span> <span begin=\"01:08.208\" end=\"01:09.790\">meghalad.</span></p><p begin=\"01:09.875\" end=\"01:11.842\" ttm:agent=\"v1\" itunes:key=\"L7\"><span begin=\"01:09.875\" end=\"01:11.842\">Sáriputra!</span></p><p begin=\"01:11.922\" end=\"01:18.495\" ttm:agent=\"v1\" itunes:key=\"L8\"><span begin=\"01:11.922\" end=\"01:12.467\">A</span> <span begin=\"01:12.488\" end=\"01:13.248\">forma</span> <span begin=\"01:13.356\" end=\"01:14.070\">nem</span> <span begin=\"01:14.116\" end=\"01:16.088\">különbözik</span> <span begin=\"01:16.089\" end=\"01:16.609\">az</span> <span begin=\"01:16.649\" end=\"01:18.495\">ürességtől,</span></p><p begin=\"01:18.606\" end=\"01:25.156\" ttm:agent=\"v1\" itunes:key=\"L9\"><span begin=\"01:18.606\" end=\"01:19.235\">az</span> <span begin=\"01:19.235\" end=\"01:20.610\">üresség</span> <span begin=\"01:20.610\" end=\"01:21.281\">nem</span> <span begin=\"01:21.281\" end=\"01:23.021\">különbözik</span> <span begin=\"01:23.021\" end=\"01:23.278\">a</span> <span begin=\"01:23.278\" end=\"01:25.156\">formától.</span></p><p begin=\"01:25.301\" end=\"01:29.709\" ttm:agent=\"v1\" itunes:key=\"L10\"><span begin=\"01:25.301\" end=\"01:25.879\">A</span> <span begin=\"01:25.879\" end=\"01:26.842\">forma</span> <span begin=\"01:26.842\" end=\"01:28.223\">valóban</span> <span begin=\"01:28.223\" end=\"01:29.709\">üresség,</span></p><p begin=\"01:29.832\" end=\"01:34.512\" ttm:agent=\"v1\" itunes:key=\"L11\"><span begin=\"01:29.832\" end=\"01:30.466\">az</span> <span begin=\"01:30.466\" end=\"01:31.936\">üresség</span> <span begin=\"01:31.936\" end=\"01:33.494\">valóban</span> <span begin=\"01:33.494\" end=\"01:34.512\">forma.</span></p><p begin=\"01:34.541\" end=\"01:40.146\" ttm:agent=\"v1\" itunes:key=\"L12\"><span begin=\"01:34.541\" end=\"01:35.095\">Így</span> <span begin=\"01:35.095\" end=\"01:35.978\">ilyen</span> <span begin=\"01:35.978\" end=\"01:36.587\">az</span> <span begin=\"01:36.587\" end=\"01:37.574\">érzés,</span> <span begin=\"01:37.574\" end=\"01:38.116\">az</span> <span begin=\"01:38.116\" end=\"01:40.146\">érzékelés,</span></p><p begin=\"01:40.188\" end=\"01:45.728\" ttm:agent=\"v1\" itunes:key=\"L13\"><span begin=\"01:40.188\" end=\"01:40.697\">az</span> <span begin=\"01:40.697\" end=\"01:42.178\">akarat</span> <span begin=\"01:42.178\" end=\"01:42.755\">és</span> <span begin=\"01:42.755\" end=\"01:43.275\">a</span> <span begin=\"01:43.275\" end=\"01:45.160\">tudatosság</span> <span begin=\"01:45.160\" end=\"01:45.728\">is.</span></p><p begin=\"01:45.815\" end=\"01:47.861\" ttm:agent=\"v1\" itunes:key=\"L14\"><span begin=\"01:45.815\" end=\"01:47.861\">Sáriputra!</span></p><p begin=\"01:47.925\" end=\"01:54.972\" ttm:agent=\"v1\" itunes:key=\"L15\"><span begin=\"01:47.925\" end=\"01:48.988\">Minden</span> <span begin=\"01:48.988\" end=\"01:50.964\">jelenségnek</span> <span begin=\"01:50.964\" end=\"01:52.548\">üresség</span> <span begin=\"01:52.548\" end=\"01:53.080\">a</span> <span begin=\"01:53.080\" end=\"01:54.972\">természete.</span></p><p begin=\"01:55.063\" end=\"02:00.107\" ttm:agent=\"v1\" itunes:key=\"L16\"><span begin=\"01:55.063\" end=\"01:55.596\">Nem</span> <span begin=\"01:55.596\" end=\"01:57.649\">keletkeznek</span> <span begin=\"01:57.649\" end=\"01:58.209\">és</span> <span begin=\"01:58.209\" end=\"01:58.712\">nem</span> <span begin=\"01:58.712\" end=\"01:59.723\">szűnnek</span> <span begin=\"01:59.723\" end=\"02:00.107\">meg,</span></p><p begin=\"02:00.182\" end=\"02:04.698\" ttm:agent=\"v1\" itunes:key=\"L17\"><span begin=\"02:00.182\" end=\"02:00.723\">nem</span> <span begin=\"02:00.723\" end=\"02:01.789\">tiszták</span> <span begin=\"02:01.789\" end=\"02:02.282\">és</span> <span begin=\"02:02.282\" end=\"02:02.804\">nem</span> <span begin=\"02:02.804\" end=\"02:04.698\">szennyezettek,</span></p><p begin=\"02:04.794\" end=\"02:09.725\" ttm:agent=\"v1\" itunes:key=\"L18\"><span begin=\"02:04.794\" end=\"02:05.331\">nem</span> <span begin=\"02:05.331\" end=\"02:07.331\">növekszenek</span> <span begin=\"02:07.331\" end=\"02:07.912\">és</span> <span begin=\"02:07.912\" end=\"02:08.344\">nem</span> <span begin=\"02:08.344\" end=\"02:09.725\">csökkennek.</span></p><p begin=\"02:09.832\" end=\"02:15.940\" ttm:agent=\"v1\" itunes:key=\"L19\"><span begin=\"02:09.832\" end=\"02:10.901\">Ezért</span> <span begin=\"02:10.901\" end=\"02:11.480\">az</span> <span begin=\"02:11.480\" end=\"02:13.429\">ürességben</span> <span begin=\"02:13.429\" end=\"02:13.947\">nincs</span> <span begin=\"02:13.947\" end=\"02:14.920\">forma,</span> <span begin=\"02:14.920\" end=\"02:15.940\">érzés,</span></p><p begin=\"02:15.940\" end=\"02:22.042\" ttm:agent=\"v1\" itunes:key=\"L20\"><span begin=\"02:16.140\" end=\"02:17.987\">érzékelés,</span> <span begin=\"02:17.987\" end=\"02:19.611\">akarat</span> <span begin=\"02:19.611\" end=\"02:20.087\">és</span> <span begin=\"02:20.087\" end=\"02:22.042\">tudatosság.</span></p><p begin=\"02:22.084\" end=\"02:27.158\" ttm:agent=\"v1\" itunes:key=\"L21\"><span begin=\"02:22.084\" end=\"02:22.622\">Nincs</span> <span begin=\"02:22.622\" end=\"02:23.108\">szem,</span> <span begin=\"02:23.108\" end=\"02:23.625\">fül,</span> <span begin=\"02:23.625\" end=\"02:24.135\">orr,</span> <span begin=\"02:24.135\" end=\"02:24.674\">nyelv,</span> <span begin=\"02:24.674\" end=\"02:25.231\">test</span> <span begin=\"02:25.231\" end=\"02:25.655\">és</span> <span begin=\"02:25.655\" end=\"02:27.158\">értelem,</span></p><p begin=\"02:27.221\" end=\"02:29.779\" ttm:agent=\"v1\" itunes:key=\"L22\"><span begin=\"02:27.221\" end=\"02:27.728\">nincs</span> <span begin=\"02:27.728\" end=\"02:28.231\">szín,</span> <span begin=\"02:28.231\" end=\"02:28.763\">hang,</span> <span begin=\"02:28.763\" end=\"02:29.365\">szag,</span> <span begin=\"02:29.365\" end=\"02:29.779\">íz,</span></p><p begin=\"02:29.826\" end=\"02:34.777\" ttm:agent=\"v1\" itunes:key=\"L23\"><span begin=\"02:29.826\" end=\"02:31.314\">tapintás</span> <span begin=\"02:31.314\" end=\"02:31.810\">és</span> <span begin=\"02:31.810\" end=\"02:33.337\">tudati</span> <span begin=\"02:33.337\" end=\"02:34.777\">folyamat,</span></p><p begin=\"02:34.825\" end=\"02:40.354\" ttm:agent=\"v1\" itunes:key=\"L24\"><span begin=\"02:34.825\" end=\"02:35.412\">nincs</span> <span begin=\"02:35.412\" end=\"02:37.216\">birodalma</span> <span begin=\"02:37.216\" end=\"02:37.998\">az</span> <span begin=\"02:37.998\" end=\"02:40.354\">érzékszerveknek</span></p><p begin=\"02:40.420\" end=\"02:43.916\" ttm:agent=\"v1\" itunes:key=\"L25\"><span begin=\"02:40.420\" end=\"02:40.953\">és</span> <span begin=\"02:40.953\" end=\"02:41.510\">a</span> <span begin=\"02:41.510\" end=\"02:43.916\">tudatosságnak.</span></p><p begin=\"02:43.970\" end=\"02:50.008\" ttm:agent=\"v1\" itunes:key=\"L26\"><span begin=\"02:43.970\" end=\"02:44.553\">Nincs</span> <span begin=\"02:44.553\" end=\"02:45.987\">nemtudás</span> <span begin=\"02:45.987\" end=\"02:46.509\">és</span> <span begin=\"02:46.509\" end=\"02:47.063\">nincs</span> <span begin=\"02:47.063\" end=\"02:47.920\">annak</span> <span begin=\"02:47.920\" end=\"02:50.008\">megszűnése,</span></p><p begin=\"02:50.065\" end=\"02:53.609\" ttm:agent=\"v1\" itunes:key=\"L27\"><span begin=\"02:50.065\" end=\"02:50.665\">nincs</span> <span begin=\"02:50.665\" end=\"02:52.162\">öregség</span> <span begin=\"02:52.162\" end=\"02:52.654\">és</span> <span begin=\"02:52.654\" end=\"02:53.609\">halál</span></p><p begin=\"02:53.649\" end=\"02:58.108\" ttm:agent=\"v1\" itunes:key=\"L28\"><span begin=\"02:53.649\" end=\"02:54.180\">és</span> <span begin=\"02:54.180\" end=\"02:54.666\">nincs</span> <span begin=\"02:54.666\" end=\"02:55.655\">ezek</span> <span begin=\"02:55.655\" end=\"02:57.193\">megszűnése</span> <span begin=\"02:57.193\" end=\"02:58.108\">sem.</span></p><p begin=\"02:58.167\" end=\"03:02.629\" ttm:agent=\"v1\" itunes:key=\"L29\"><span begin=\"02:58.167\" end=\"02:58.676\">Nincs</span> <span begin=\"02:58.676\" end=\"03:00.199\">szenvedés,</span> <span begin=\"03:00.199\" end=\"03:00.692\">nincs</span> <span begin=\"03:00.692\" end=\"03:01.666\">annak</span> <span begin=\"03:01.666\" end=\"03:02.629\">oka,</span></p><p begin=\"03:02.669\" end=\"03:06.129\" ttm:agent=\"v1\" itunes:key=\"L30\"><span begin=\"03:02.669\" end=\"03:03.200\">nincs</span> <span begin=\"03:03.200\" end=\"03:04.218\">annak</span> <span begin=\"03:04.218\" end=\"03:06.129\">megszűnése,</span></p><p begin=\"03:06.181\" end=\"03:11.260\" ttm:agent=\"v1\" itunes:key=\"L31\"><span begin=\"03:06.181\" end=\"03:06.735\">és</span> <span begin=\"03:06.735\" end=\"03:07.256\">nincs</span> <span begin=\"03:07.256\" end=\"03:07.992\">útja</span> <span begin=\"03:07.992\" end=\"03:08.748\">a</span> <span begin=\"03:08.748\" end=\"03:11.260\">megszüntetésnek.</span></p><p begin=\"03:11.295\" end=\"03:17.247\" ttm:agent=\"v1\" itunes:key=\"L32\"><span begin=\"03:11.295\" end=\"03:11.866\">Nincs</span> <span begin=\"03:11.866\" end=\"03:14.382\">megvalósítás</span> <span begin=\"03:14.382\" end=\"03:14.864\">és</span> <span begin=\"03:14.864\" end=\"03:15.362\">nincs</span> <span begin=\"03:15.362\" end=\"03:17.247\">megérkezés,</span></p><p begin=\"03:17.394\" end=\"03:22.971\" ttm:agent=\"v1\" itunes:key=\"L33\"><span begin=\"03:17.394\" end=\"03:18.490\">mivel</span> <span begin=\"03:18.490\" end=\"03:18.972\">nincs,</span> <span begin=\"03:18.972\" end=\"03:20.006\">amit</span> <span begin=\"03:20.006\" end=\"03:20.507\">el</span> <span begin=\"03:20.507\" end=\"03:22.019\">kellene</span> <span begin=\"03:22.019\" end=\"03:22.971\">érni.</span></p><p begin=\"03:22.971\" end=\"03:26.018\" ttm:agent=\"v1\" itunes:key=\"L34\"><span begin=\"03:22.971\" end=\"03:23.580\">A</span> <span begin=\"03:23.580\" end=\"03:26.018\">Bódhiszattvának</span></p><p begin=\"03:26.044\" end=\"03:30.969\" ttm:agent=\"v1\" itunes:key=\"L35\"><span begin=\"03:26.044\" end=\"03:26.582\">a</span> <span begin=\"03:26.582\" end=\"03:28.528\">Meghaladó</span> <span begin=\"03:28.528\" end=\"03:30.049\">Bölcsesség</span> <span begin=\"03:30.049\" end=\"03:30.969\">által</span></p><p begin=\"03:31.019\" end=\"03:36.013\" ttm:agent=\"v1\" itunes:key=\"L36\"><span begin=\"03:31.019\" end=\"03:33.166\">akadálytól</span> <span begin=\"03:33.166\" end=\"03:34.152\">mentes</span> <span begin=\"03:34.152\" end=\"03:34.672\">a</span> <span begin=\"03:34.672\" end=\"03:36.013\">tudata.</span></p><p begin=\"03:36.085\" end=\"03:44.662\" ttm:agent=\"v1\" itunes:key=\"L37\"><span begin=\"03:36.085\" end=\"03:37.159\">Mivel</span> <span begin=\"03:37.159\" end=\"03:39.167\">akadálytól</span> <span begin=\"03:39.167\" end=\"03:40.162\">mentes</span> <span begin=\"03:40.162\" end=\"03:40.693\">a</span> <span begin=\"03:40.693\" end=\"03:42.168\">tudata,</span> <span begin=\"03:42.168\" end=\"03:44.662\">rettenthetetlen,</span></p><p begin=\"03:44.702\" end=\"03:50.091\" ttm:agent=\"v1\" itunes:key=\"L38\"><span begin=\"03:44.702\" end=\"03:45.196\">és</span> <span begin=\"03:45.196\" end=\"03:47.116\">meghaladva</span> <span begin=\"03:47.116\" end=\"03:48.213\">minden</span> <span begin=\"03:48.213\" end=\"03:50.091\">illúziót</span></p><p begin=\"03:50.154\" end=\"03:54.076\" ttm:agent=\"v1\" itunes:key=\"L39\"><span begin=\"03:50.154\" end=\"03:50.669\">az</span> <span begin=\"03:50.669\" end=\"03:52.578\">ellobbanást</span> <span begin=\"03:52.578\" end=\"03:54.076\">eléri.</span></p><p begin=\"03:54.116\" end=\"03:59.095\" ttm:agent=\"v1\" itunes:key=\"L40\"><span begin=\"03:54.116\" end=\"03:54.717\">A</span> <span begin=\"03:54.717\" end=\"03:55.680\">három</span> <span begin=\"03:55.680\" end=\"03:56.723\">világ</span> <span begin=\"03:56.723\" end=\"03:57.679\">összes</span> <span begin=\"03:57.679\" end=\"03:59.095\">Buddhái</span></p><p begin=\"03:59.176\" end=\"04:06.711\" ttm:agent=\"v1\" itunes:key=\"L41\"><span begin=\"03:59.176\" end=\"03:59.685\">a</span> <span begin=\"03:59.685\" end=\"04:01.657\">Meghaladó</span> <span begin=\"04:01.657\" end=\"04:03.190\">Bölcsesség</span> <span begin=\"04:03.190\" end=\"04:04.138\">által</span> <span begin=\"04:04.138\" end=\"04:06.139\">valósítják</span> <span begin=\"04:06.139\" end=\"04:06.711\">meg</span></p><p begin=\"04:06.728\" end=\"04:15.712\" ttm:agent=\"v1\" itunes:key=\"L42\"><span begin=\"04:06.728\" end=\"04:07.208\">a</span> <span begin=\"04:07.208\" end=\"04:09.225\">Tökéletes</span> <span begin=\"04:09.225\" end=\"04:09.753\">és</span> <span begin=\"04:09.753\" end=\"04:12.702\">Felülmúlhatatlan</span> <span begin=\"04:12.702\" end=\"04:15.712\">Felébredettséget.</span></p><p begin=\"04:15.775\" end=\"04:22.799\" ttm:agent=\"v1\" itunes:key=\"L43\"><span begin=\"04:15.775\" end=\"04:16.844\">Ezért</span> <span begin=\"04:16.844\" end=\"04:17.804\">ismerd</span> <span begin=\"04:17.804\" end=\"04:18.356\">fel</span> <span begin=\"04:18.356\" end=\"04:18.860\">a</span> <span begin=\"04:18.860\" end=\"04:20.866\">Meghaladó</span> <span begin=\"04:20.866\" end=\"04:22.799\">Bölcsességet,</span></p><p begin=\"04:22.847\" end=\"04:25.323\" ttm:agent=\"v1\" itunes:key=\"L44\"><span begin=\"04:22.847\" end=\"04:23.379\">a</span> <span begin=\"04:23.379\" end=\"04:23.836\">Nagy</span> <span begin=\"04:23.836\" end=\"04:24.362\">Szent</span> <span begin=\"04:24.362\" end=\"04:25.323\">Eszmét,</span></p><p begin=\"04:25.374\" end=\"04:28.766\" ttm:agent=\"v1\" itunes:key=\"L45\"><span begin=\"04:25.374\" end=\"04:25.867\">a</span> <span begin=\"04:25.867\" end=\"04:26.388\">Nagy</span> <span begin=\"04:26.388\" end=\"04:27.379\">Tudás</span> <span begin=\"04:27.379\" end=\"04:28.766\">Eszméjét,</span></p><p begin=\"04:28.855\" end=\"04:33.372\" ttm:agent=\"v1\" itunes:key=\"L46\"><span begin=\"04:28.855\" end=\"04:29.398\">a</span> <span begin=\"04:29.398\" end=\"04:32.399\">Felülmúlhatatlan</span> <span begin=\"04:32.399\" end=\"04:33.372\">Eszmét,</span></p><p begin=\"04:33.417\" end=\"04:37.781\" ttm:agent=\"v1\" itunes:key=\"L47\"><span begin=\"04:33.417\" end=\"04:33.953\">a</span> <span begin=\"04:33.953\" end=\"04:36.918\">Hasonlíthatatlan</span> <span begin=\"04:36.918\" end=\"04:37.781\">Eszmét,</span></p><p begin=\"04:37.861\" end=\"04:43.853\" ttm:agent=\"v1\" itunes:key=\"L48\"><span begin=\"04:37.861\" end=\"04:38.402\">azt,</span> <span begin=\"04:38.402\" end=\"04:39.414\">ami</span> <span begin=\"04:39.414\" end=\"04:40.375\">véget</span> <span begin=\"04:40.375\" end=\"04:40.912\">vet</span> <span begin=\"04:40.912\" end=\"04:41.816\">minden</span> <span begin=\"04:41.816\" end=\"04:43.853\">szenvedésnek.</span></p><p begin=\"04:43.889\" end=\"04:47.846\" ttm:agent=\"v1\" itunes:key=\"L49\"><span begin=\"04:43.889\" end=\"04:44.381\">Ez</span> <span begin=\"04:44.381\" end=\"04:45.929\">igazság,</span> <span begin=\"04:45.929\" end=\"04:46.387\">nem</span> <span begin=\"04:46.387\" end=\"04:47.846\">hazugság.</span></p><p begin=\"04:47.889\" end=\"04:50.380\" ttm:agent=\"v1\" itunes:key=\"L50\"><span begin=\"04:47.889\" end=\"04:48.905\">Ezért</span> <span begin=\"04:48.905\" end=\"04:50.380\">hangoztasd</span></p><p begin=\"04:50.449\" end=\"04:55.871\" ttm:agent=\"v1\" itunes:key=\"L51\"><span begin=\"04:50.449\" end=\"04:50.941\">a</span> <span begin=\"04:50.941\" end=\"04:52.914\">Meghaladó</span> <span begin=\"04:52.914\" end=\"04:54.458\">Bölcsesség</span> <span begin=\"04:54.458\" end=\"04:55.871\">Eszméjét,</span></p><p begin=\"04:55.926\" end=\"04:57.950\" ttm:agent=\"v1\" itunes:key=\"L52\"><span begin=\"04:55.926\" end=\"04:56.942\">amely</span> <span begin=\"04:56.942\" end=\"04:57.436\">így</span> <span begin=\"04:57.436\" end=\"04:57.950\">szól:</span></p><p begin=\"04:57.979\" end=\"05:01.970\" ttm:agent=\"v1\" itunes:key=\"L53\"><span begin=\"04:57.979\" end=\"04:58.974\">gáté</span> <span begin=\"04:58.974\" end=\"05:00.026\">gáté</span> <span begin=\"05:00.026\" end=\"05:01.970\">párágáté</span></p><p begin=\"05:02.083\" end=\"05:06.113\" ttm:agent=\"v1\" itunes:key=\"L54\"><span begin=\"05:02.083\" end=\"05:04.149\">párászámgáté</span> <span begin=\"05:04.149\" end=\"05:05.004\">bódhi</span> <span begin=\"05:05.004\" end=\"05:06.113\">szváhá</span> </p><p begin=\"05:06.151\" end=\"05:10.182\" ttm:agent=\"v1\" itunes:key=\"L55\"><span begin=\"05:06.151\" end=\"05:07.186\">gáté</span> <span begin=\"05:07.186\" end=\"05:08.187\">gáté</span> <span begin=\"05:08.187\" end=\"05:10.182\">párágáté</span></p><p begin=\"05:10.257\" end=\"05:14.285\" ttm:agent=\"v1\" itunes:key=\"L56\"><span begin=\"05:10.257\" end=\"05:12.306\">párászámgáté</span> <span begin=\"05:12.306\" end=\"05:13.264\">bódhi</span> <span begin=\"05:13.264\" end=\"05:14.285\">szváhá</span></p><p begin=\"05:14.327\" end=\"05:18.330\" ttm:agent=\"v1\" itunes:key=\"L57\"><span begin=\"05:14.327\" end=\"05:15.351\">gáté</span> <span begin=\"05:15.351\" end=\"05:16.352\">gáté</span> <span begin=\"05:16.352\" end=\"05:18.330\">párágáté</span></p><p begin=\"05:18.399\" end=\"05:26.915\" ttm:agent=\"v1\" itunes:key=\"L58\"><span begin=\"05:18.399\" end=\"05:20.449\">párászámgáté</span> <span begin=\"05:20.449\" end=\"05:21.069\">bódhi</span> <span begin=\"05:21.069\" end=\"05:26.915\">szváhá</span></p></div></body></tt>"
}
```

**Tool Call: thinking**
Status: Completed

Finished thinking.

## Assistant

Now I have everything I need. Let me write the specification.

**Tool Call: docs/example_specification.md**
Status: Failed

Can't create file: file already exists

**Tool Call: docs/example_specification.md**
Status: Completed

Diff: ttml_parser/docs/example_specification.md
```
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
```


## Assistant

The specification document has been created at `ttml_parser/docs/example_specification.md`. Here's a summary of what it covers:

---

### What's in the spec

**§1 Overview** — States the goal: a full-screen Apple Music-style karaoke player that demonstrates `ttml_parser` end-to-end.

**§2 Assets** — Identifies the two bundled files (`heart_sutra_hu.ttml` + `.mp3`) that already exist in `example/assets/`.

**§3 Dependencies** — `ttml_parser` (path dep), `just_audio`, and `audio_session`. Nothing else.

**§4 File Structure** — A clean six-file layout split into `models/`, `services/`, `screens/`, and `widgets/`.

**§5 Initialisation Sequence** — Ordered steps: load asset → `TtmlParser.parse()` → configure audio session → load audio source → show UI (with loading/error states).

**§6 Services** — Typed interfaces for `LyricsService` (pure query methods over the `TtmlDocument`) and `AudioService` (wraps `just_audio`, exposes streams).

**§7 State Model** — An immutable `PlayerState` snapshot rebuilt from the position stream on each tick.

**§8–11 UI** — Full layout specs for `KaraokeScreen`, `LyricsView` (auto-scroll on line change, not every tick), `LyricLineWidget` (four word states: sung/singing/pending/inactive, `ClipRect` fill animation, instrumental placeholder handling for line L1), and `PlayerControls` (seek bar, transport buttons, track info).

**§12 Theming** — Dark `ThemeData` overrides; system font only.

**§13 Rendering Guidance** — Explicitly ties back to §11 of the package spec (the four rules: line activation, word highlighting, voice differentiation, sub-word progress).

**§14–15 Error Handling & Lifecycle** — Error screens with retry, proper `dispose()` calls.

**§16 Acceptance Criteria** — 11 verifiable conditions an agent can check off one by one.

