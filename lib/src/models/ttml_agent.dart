/// A participant (voice) in a TTML lyric document.
class TtmlAgent {
  /// The unique identifier for this agent, corresponding to the `xml:id`
  /// attribute on the `<ttm:agent>` element.
  final String id;

  /// The type of this agent (e.g. `"person"` or `"other"`).
  final String type;

  /// Creates a [TtmlAgent] with the given [id] and [type].
  const TtmlAgent({required this.id, required this.type});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TtmlAgent && id == other.id && type == other.type;

  @override
  int get hashCode => Object.hash(id, type);

  @override
  String toString() => 'TtmlAgent(id: "$id", type: "$type")';
}