/// Exception thrown when a TTML document cannot be parsed.
///
/// Wraps low-level parse errors (e.g. malformed XML, missing required
/// attributes) with a human-readable [message] and an optional [cause].
class TtmlParseException implements Exception {
  /// A description of what went wrong.
  final String message;

  /// The underlying error that caused this exception, if any.
  final Object? cause;

  /// Creates a [TtmlParseException] with the given [message] and optional [cause].
  const TtmlParseException(this.message, {this.cause});

  @override
  String toString() {
    if (cause != null) {
      return 'TtmlParseException: $message (cause: $cause)';
    }
    return 'TtmlParseException: $message';
  }
}