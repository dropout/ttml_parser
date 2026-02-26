import 'package:ttml_parser/ttml_parser.dart';

/// Stateless service that holds a parsed [TtmlDocument] and exposes
/// pure query methods for resolving the active lyric line and agents.
class LyricsService {
  LyricsService(this.document);

  final TtmlDocument document;

  /// Returns the [TtmlLine] active at [position], or `null` if none.
  ///
  /// A line is considered active when `line.begin <= position < line.end`.
  TtmlLine? activeLine(Duration position) {
    final index = activeLineIndex(position);
    return index == -1 ? null : document.lines[index];
  }

  /// Returns the index of the active line in [document.lines], or `-1` if none.
  int activeLineIndex(Duration position) {
    for (var i = 0; i < document.lines.length; i++) {
      final line = document.lines[i];
      if (position >= line.begin && position < line.end) {
        return i;
      }
    }
    return -1;
  }

  /// Returns the [TtmlAgent] whose `id` matches [agentId], or `null` if not found.
  TtmlAgent? agentFor(String? agentId) {
    if (agentId == null) return null;
    for (final agent in document.agents) {
      if (agent.id == agentId) return agent;
    }
    return null;
  }
}