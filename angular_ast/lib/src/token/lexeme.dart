part of ngast.src.token.tokens;

/// A [NgSimpleToken] that has a custom lexeme, i.e. not predefined by type.
///
/// For example, a `text` is (almost) any arbitrary string.
class _LexemeNgSimpleToken extends NgSimpleToken {
  const _LexemeNgSimpleToken(
      int offset, this.lexeme, this.length, NgSimpleTokenType type)
      : super._(type, offset);

  @override
  bool operator ==(Object? other) {
    return other is _LexemeNgSimpleToken &&
        super == other &&
        lexeme == other.lexeme;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, lexeme);

  @override
  final String lexeme;

  @override
  final int length;
}

/// A [NgToken] that has a custom lexeme, i.e. not predefined by a token type.
///
/// For example, an `elementIdentifier` is (almost) any arbitrary string.
class _LexemeNgToken extends NgToken {
  const _LexemeNgToken(
    int offset,
    this.lexeme,
    NgTokenType type, {
    bool errorSynthetic = false,
  }) : super._(
          type,
          offset,
          errorSynthetic: errorSynthetic,
        );

  @override
  bool operator ==(Object? other) {
    return other is _LexemeNgToken && super == other && lexeme == other.lexeme;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, lexeme);

  @override
  final String lexeme;
}
