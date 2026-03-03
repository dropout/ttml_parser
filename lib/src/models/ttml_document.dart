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

  /// Returns the [TtmlLine] active at [position], or `null` if none.
  ///
  /// A line is considered active when `line.begin <= position < line.end`.
  TtmlLine? activeLine(Duration position) {
    final index = activeLineIndex(position);
    return index == -1 ? null : lines[index];
  }

  /// Returns the index of the active line in [lines], or `-1` if none.
  int activeLineIndex(Duration position) {
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (position >= line.begin && position < line.end) {
        return i;
      }
    }
    return -1;
  }

  /// Returns the [TtmlAgent] whose `id` matches [agentId], or `null` if not found.
  TtmlAgent? agentFor(String? agentId) {
    if (agentId == null) return null;
    for (final agent in agents) {
      if (agent.id == agentId) return agent;
    }
    return null;
  }  

  @override
  String toString() =>
      'TtmlDocument(totalDuration: $totalDuration, agents: ${agents.length}, '
      'lines: ${lines.length})';
}