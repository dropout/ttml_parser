import 'package:xml/xml.dart';

import '../exceptions/ttml_parse_exception.dart';
import '../models/ttml_agent.dart';
import '../models/ttml_document.dart';
import '../models/ttml_line.dart';
import '../models/ttml_word.dart';
import 'time_parser.dart';

// Namespace URIs used in TTML documents.
const _ttmlNs = 'http://www.w3.org/ns/ttml';
const _ttmlMetaNs = 'http://www.w3.org/ns/ttml#metadata';

const _itunesNs = 'http://music.apple.com/lyric-ttml-internal';

/// Parses a TTML lyric document into a [TtmlDocument].
///
/// [TtmlParser] is stateless — the same instance may be used to parse any
/// number of documents concurrently or sequentially.
class TtmlParser {
  /// Creates a [TtmlParser].
  const TtmlParser();

  /// Parses [ttmlContent] and returns a [TtmlDocument].
  ///
  /// Throws [TtmlParseException] if the input is malformed XML, is missing
  /// required elements or attributes, or contains invalid time strings.
  TtmlDocument parse(String ttmlContent) {
    // Step 1 — Parse XML.
    final XmlDocument xmlDoc;
    try {
      xmlDoc = XmlDocument.parse(ttmlContent);
    } on XmlParserException catch (e) {
      throw TtmlParseException('Malformed XML: ${e.message}', cause: e);
    }

    // Step 2 — Locate the root <tt> element.
    final tt = xmlDoc
        .findElements('tt', namespace: _ttmlNs)
        .cast<XmlElement?>()
        .firstWhere((_) => true, orElse: () => null);

    if (tt == null) {
      throw const TtmlParseException('Missing root <tt> element');
    }

    // Step 3 — Extract agents from <head><metadata>.
    final agents = _parseAgents(tt);

    // Step 4 — Extract total duration from <body>.
    final body = tt
        .findElements('body', namespace: _ttmlNs)
        .cast<XmlElement?>()
        .firstWhere((_) => true, orElse: () => null);

    Duration? totalDuration;
    if (body != null) {
      final durAttr = body.getAttribute('dur');
      if (durAttr != null) {
        totalDuration = parseTime(durAttr);
      }
    }

    // Step 5 — Collect all <p> elements from <div> children of <body>.
    final pElements = <XmlElement>[];
    if (body != null) {
      for (final div in body.findElements('div', namespace: _ttmlNs)) {
        for (final p in div.findElements('p', namespace: _ttmlNs)) {
          pElements.add(p);
        }
      }
    }

    // Steps 6 & 7 — Parse each <p> into a TtmlLine (which parses its <span>s).
    final lines = pElements.map(_parseLine).toList();

    // Step 8 — Assemble and return.
    return TtmlDocument(
      totalDuration: totalDuration,
      agents: agents,
      lines: lines,
    );
  }

  List<TtmlAgent> _parseAgents(XmlElement tt) {
    final agents = <TtmlAgent>[];

    for (final head in tt.findElements('head', namespace: _ttmlNs)) {
      for (final metadata in head.findElements('metadata', namespace: _ttmlNs)) {
        for (final agentEl
            in metadata.findElements('agent', namespace: _ttmlMetaNs)) {
          final id = agentEl.getAttribute('xml:id');
          if (id == null) {
            throw const TtmlParseException(
              '<ttm:agent> is missing the required xml:id attribute',
            );
          }
          final type = agentEl.getAttribute('type');
          if (type == null) {
            throw TtmlParseException(
              '<ttm:agent id="$id"> is missing the required type attribute',
            );
          }
          agents.add(TtmlAgent(id: id, type: type));
        }
      }
    }

    return agents;
  }

  TtmlLine _parseLine(XmlElement p) {
    final beginStr = p.getAttribute('begin');
    if (beginStr == null) {
      throw const TtmlParseException(
        '<p> is missing the required begin attribute',
      );
    }

    final endStr = p.getAttribute('end');
    if (endStr == null) {
      throw const TtmlParseException(
        '<p> is missing the required end attribute',
      );
    }

    final begin = parseTime(beginStr);
    final end = parseTime(endStr);

    final agentId = p.getAttribute('agent', namespace: _ttmlMetaNs);
    final key = p.getAttribute('key', namespace: _itunesNs);

    // Step 7 — Parse direct child <span> elements into TtmlWord instances.
    final words = <TtmlWord>[];
    for (final span in p.findElements('span', namespace: _ttmlNs)) {
      final word = _parseWord(span);
      if (word != null) {
        words.add(word);
      }
    }

    return TtmlLine(
      begin: begin,
      end: end,
      agentId: agentId,
      key: key,
      words: words,
    );
  }

  TtmlWord? _parseWord(XmlElement span) {
    final beginStr = span.getAttribute('begin');
    if (beginStr == null) {
      throw const TtmlParseException(
        '<span> is missing the required begin attribute',
      );
    }

    final endStr = span.getAttribute('end');
    if (endStr == null) {
      throw const TtmlParseException(
        '<span> is missing the required end attribute',
      );
    }

    final text = span.innerText.trim();
    if (text.isEmpty) {
      return null;
    }

    return TtmlWord(
      begin: parseTime(beginStr),
      end: parseTime(endStr),
      text: text,
    );
  }
}