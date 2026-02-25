import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ttml_parser/ttml_parser.dart';
import 'package:ttml_parser/src/parser/time_parser.dart';

void main() {
  const parser = TtmlParser();

  late TtmlDocument doc;

  setUpAll(() {
    final ttml = File('assets/heart_sutra.ttml').readAsStringSync();
    doc = parser.parse(ttml);
  });

  // ---------------------------------------------------------------------------
  // 10.1 Document-level tests
  // ---------------------------------------------------------------------------
  group('10.1 Document-level', () {
    test('parsing heart_sutra.ttml succeeds without throwing', () {
      // setUpAll already parsed; if we reach here it didn't throw.
      expect(doc, isNotNull);
    });

    test('totalDuration equals 5m 26s 915ms', () {
      expect(
        doc.totalDuration,
        equals(const Duration(minutes: 5, seconds: 26, milliseconds: 915)),
      );
    });

    test('agents has exactly two entries', () {
      expect(doc.agents, hasLength(2));
    });

    test('agent "v1" has type "person"', () {
      final v1 = doc.agents.firstWhere((a) => a.id == 'v1');
      expect(v1.type, equals('person'));
    });

    test('agent "v2" has type "other"', () {
      final v2 = doc.agents.firstWhere((a) => a.id == 'v2');
      expect(v2.type, equals('other'));
    });

    test('lines is non-empty', () {
      expect(doc.lines, isNotEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // 10.2 Line-level tests
  // ---------------------------------------------------------------------------
  group('10.2 Line-level (L2)', () {
    late TtmlLine l2;

    setUpAll(() {
      l2 = doc.lines.firstWhere((l) => l.key == 'L2');
    });

    test('begin equals 7s 733ms', () {
      expect(l2.begin, equals(const Duration(seconds: 7, milliseconds: 733)));
    });

    test('end equals 41s 898ms', () {
      expect(l2.end, equals(const Duration(seconds: 41, milliseconds: 898)));
    });

    test('agentId equals "v1"', () {
      expect(l2.agentId, equals('v1'));
    });

    test('has exactly five words', () {
      expect(l2.words, hasLength(5));
    });

    test('first word text equals "Mahá"', () {
      expect(l2.words.first.text, equals('Mahá'));
    });

    test('text getter equals full sentence', () {
      expect(
        l2.text,
        equals('Mahá Prádzsnyá Párámitá Hridájá Szútra'),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // 10.3 Word-level tests
  // ---------------------------------------------------------------------------
  group('10.3 Word-level (first word of L2)', () {
    late TtmlWord word;

    setUpAll(() {
      final l2 = doc.lines.firstWhere((l) => l.key == 'L2');
      word = l2.words.first;
    });

    test('begin equals 7s 733ms', () {
      expect(
        word.begin,
        equals(const Duration(seconds: 7, milliseconds: 733)),
      );
    });

    test('end equals 12s 124ms', () {
      expect(
        word.end,
        equals(const Duration(seconds: 12, milliseconds: 124)),
      );
    });

    test('duration equals 4s 391ms', () {
      expect(
        word.duration,
        equals(const Duration(seconds: 4, milliseconds: 391)),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // 10.4 Time-parser unit tests
  // ---------------------------------------------------------------------------
  group('10.4 Time-parser', () {
    test('"00:00.000" → Duration.zero', () {
      expect(parseTime('00:00.000'), equals(Duration.zero));
    });

    test('"00:07.500" → 7s 500ms', () {
      expect(
        parseTime('00:07.500'),
        equals(const Duration(seconds: 7, milliseconds: 500)),
      );
    });

    test('"01:04.097" → 1m 4s 97ms', () {
      expect(
        parseTime('01:04.097'),
        equals(const Duration(minutes: 1, seconds: 4, milliseconds: 97)),
      );
    });

    test('"05:26.915" → 5m 26s 915ms', () {
      expect(
        parseTime('05:26.915'),
        equals(const Duration(minutes: 5, seconds: 26, milliseconds: 915)),
      );
    });

    test('"01:02:03.456" → 1h 2m 3s 456ms', () {
      expect(
        parseTime('01:02:03.456'),
        equals(
          const Duration(
            hours: 1,
            minutes: 2,
            seconds: 3,
            milliseconds: 456,
          ),
        ),
      );
    });

    test('invalid string throws TtmlParseException', () {
      expect(
        () => parseTime('abc'),
        throwsA(isA<TtmlParseException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // 10.5 Error-handling tests
  // ---------------------------------------------------------------------------
  group('10.5 Error handling', () {
    test('malformed XML throws TtmlParseException', () {
      expect(
        () => parser.parse('<<not valid xml>>'),
        throwsA(isA<TtmlParseException>()),
      );
    });

    test('<p> missing begin throws TtmlParseException', () {
      const ttml = '''
<tt xmlns="http://www.w3.org/ns/ttml"
    xmlns:ttm="http://www.w3.org/ns/ttml#metadata">
  <head><metadata/></head>
  <body>
    <div>
      <p end="00:05.000">
        <span begin="00:00.000" end="00:05.000">Hello</span>
      </p>
    </div>
  </body>
</tt>''';
      expect(
        () => parser.parse(ttml),
        throwsA(isA<TtmlParseException>()),
      );
    });

    test('<p> missing end throws TtmlParseException', () {
      const ttml = '''
<tt xmlns="http://www.w3.org/ns/ttml"
    xmlns:ttm="http://www.w3.org/ns/ttml#metadata">
  <head><metadata/></head>
  <body>
    <div>
      <p begin="00:00.000">
        <span begin="00:00.000" end="00:05.000">Hello</span>
      </p>
    </div>
  </body>
</tt>''';
      expect(
        () => parser.parse(ttml),
        throwsA(isA<TtmlParseException>()),
      );
    });

    test('<span> missing begin throws TtmlParseException', () {
      const ttml = '''
<tt xmlns="http://www.w3.org/ns/ttml"
    xmlns:ttm="http://www.w3.org/ns/ttml#metadata">
  <head><metadata/></head>
  <body>
    <div>
      <p begin="00:00.000" end="00:05.000">
        <span end="00:05.000">Hello</span>
      </p>
    </div>
  </body>
</tt>''';
      expect(
        () => parser.parse(ttml),
        throwsA(isA<TtmlParseException>()),
      );
    });

    test('<ttm:agent> missing xml:id throws TtmlParseException', () {
      const ttml = '''
<tt xmlns="http://www.w3.org/ns/ttml"
    xmlns:ttm="http://www.w3.org/ns/ttml#metadata">
  <head>
    <metadata>
      <ttm:agent type="person"/>
    </metadata>
  </head>
  <body><div/></body>
</tt>''';
      expect(
        () => parser.parse(ttml),
        throwsA(isA<TtmlParseException>()),
      );
    });

    test('document with no <p> elements returns empty lines list', () {
      const ttml = '''
<tt xmlns="http://www.w3.org/ns/ttml"
    xmlns:ttm="http://www.w3.org/ns/ttml#metadata">
  <head><metadata/></head>
  <body>
    <div/>
  </body>
</tt>''';
      final result = parser.parse(ttml);
      expect(result.lines, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // 10.6 Whitespace-handling tests
  // ---------------------------------------------------------------------------
  group('10.6 Whitespace handling', () {
    late TtmlDocument wsDoc;

    setUpAll(() {
      const ttml = '''
<tt xmlns="http://www.w3.org/ns/ttml"
    xmlns:ttm="http://www.w3.org/ns/ttml#metadata">
  <head><metadata/></head>
  <body>
    <div>
      <p begin="00:00.000" end="00:10.000">
        <span begin="00:00.000" end="00:03.000">Hello</span>
        <span begin="00:03.000" end="00:06.000">  World  </span>
        <span begin="00:06.000" end="00:09.000">   </span>
      </p>
    </div>
  </body>
</tt>''';
      wsDoc = parser.parse(ttml);
    });

    test('space text nodes between spans are not parsed as words', () {
      // Only <span> elements become words, not text nodes with whitespace.
      // The line has 3 spans but one is whitespace-only → 2 words.
      expect(wsDoc.lines.first.words, hasLength(2));
    });

    test('leading/trailing whitespace in span text is trimmed', () {
      final second = wsDoc.lines.first.words[1];
      expect(second.text, equals('World'));
    });

    test('whitespace-only span is discarded', () {
      // The third span contains only spaces and must be dropped.
      final texts = wsDoc.lines.first.words.map((w) => w.text).toList();
      expect(texts, isNot(contains('')));
      expect(wsDoc.lines.first.words, hasLength(2));
    });
  });
}