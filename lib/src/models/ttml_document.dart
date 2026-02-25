import 'ttml_agent.dart';
import 'ttml_line.dart';

/// The top-level result of parsing a TTML lyric document.
class TtmlDocument {
  /// The total duration of the document, taken from the `dur` attribute on
  /// `<body>`, or `null` if the attribute is absent.
  final Duration? totalDuration;

  /// The agents (voices) declared in the document's `<head><metadata>` section.
  final List<TtmlAgent> agents;

  /// The lyric lines parsed from the document's `<body>` section, in document
  /// order.
  final List<TtmlLine> lines;

  /// Creates a [TtmlDocument] with the given [totalDuration], [agents], and
  /// [lines].
  ///
  /// Both [agents] and [lines] are stored as unmodifiable views.
  TtmlDocument({
    required this.totalDuration,
    required List<TtmlAgent> agents,
    required List<TtmlLine> lines,
  })  : agents = List.unmodifiable(agents),
        lines = List.unmodifiable(lines);

  @override
  String toString() =>
      'TtmlDocument(totalDuration: $totalDuration, agents: ${agents.length}, '
      'lines: ${lines.length})';
}