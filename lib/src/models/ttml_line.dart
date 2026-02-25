import 'ttml_word.dart';

/// A single lyric line, corresponding to a `<p>` element in the TTML document.
class TtmlLine {
  /// The time at which this line begins.
  final Duration begin;

  /// The time at which this line ends.
  final Duration end;

  /// The identifier of the [TtmlAgent] responsible for this line, if present.
  final String? agentId;

  /// The lyric key for this line (e.g. `"L2"`), if present.
  final String? key;

  /// The words that make up this line.
  final List<TtmlWord> words;

  /// The full text of this line, formed by joining each word's [TtmlWord.text]
  /// with a single space.
  String get text => words.map((w) => w.text).join(' ');

  /// The duration of this line, computed as [end] minus [begin].
  Duration get duration => end - begin;

  /// Creates a [TtmlLine] with the given timing, optional [agentId] and [key],
  /// and a list of [words].
  ///
  /// The [words] list is stored as an unmodifiable view.
  TtmlLine({
    required this.begin,
    required this.end,
    this.agentId,
    this.key,
    required List<TtmlWord> words,
  }) : words = List.unmodifiable(words);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TtmlLine &&
          begin == other.begin &&
          end == other.end &&
          agentId == other.agentId &&
          key == other.key &&
          _listsEqual(words, other.words);

  @override
  int get hashCode => Object.hash(begin, end, agentId, key, Object.hashAll(words));

  @override
  String toString() =>
      'TtmlLine(key: "$key", agentId: "$agentId", begin: $begin, end: $end, '
      'words: ${words.length}, text: $text)';

  static bool _listsEqual(List<TtmlWord> a, List<TtmlWord> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}