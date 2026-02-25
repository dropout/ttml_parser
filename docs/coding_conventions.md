# Coding Conventions (Dart/Flutter)
- **Style & naming**: Use UpperCamelCase for types/extensions, lowerCamelCase for members/constants, snake_case for files; capitalize long acronyms as words; avoid leading underscore for non-private symbols.
- **Imports & layout**: Order `dart:` then `package:` then relative; keep exports in a separate section; sort sections alphabetically; run `dart format`; prefer <=80 chars; always use braces in control flow.
- **Docs & comments**: Use `///` for public APIs; start with a one-sentence summary; avoid block comments for docs; avoid redundant comments; use `[]` to link identifiers; put doc comments before annotations.
- **Null & initialization**: Avoid `late` unless needed; don't initialize to `null`; don't use explicit `null` defaults; prefer initializer lists; initialize fields at declaration when possible.
- **Collections & strings**: Prefer literals; use interpolation; avoid `Iterable.forEach()` with closures; use `isEmpty` over `length`; avoid `cast()` when possible; use `whereType()` for type filtering.
- **Functions & members**: Prefer tear-offs over lambdas; use `=>` for simple members; avoid unnecessary getters/setters; avoid `this.` except for disambiguation; avoid `new` and redundant `const`.
- **Async & errors**: Prefer `async`/`await`; avoid `async` without effect; avoid `Completer`; avoid catch-all `catch` without `on`; use `rethrow` when propagating.
- **Types & parameters**: Annotate return types and parameter types on declarations; avoid redundant local type annotations; avoid positional booleans; prefer named params; avoid `FutureOr<T>` returns.
