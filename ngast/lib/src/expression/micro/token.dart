/// Represents a section of parsed text from an Angular micro expression.
///
/// Clients should not extend, implement, or mix-in this class.
class NgMicroToken {
  factory NgMicroToken.bindExpressionBefore(int offset, String lexeme) {
    return NgMicroToken._(
      NgMicroTokenType.bindExpressionBefore,
      lexeme,
      offset,
    );
  }

  factory NgMicroToken.bindExpression(int offset, String lexeme) {
    return NgMicroToken._(NgMicroTokenType.bindExpression, lexeme, offset);
  }

  factory NgMicroToken.bindIdentifier(int offset, String lexeme) {
    return NgMicroToken._(NgMicroTokenType.bindIdentifier, lexeme, offset);
  }

  factory NgMicroToken.endExpression(int offset, String lexeme) {
    return NgMicroToken._(NgMicroTokenType.endExpression, lexeme, offset);
  }

  factory NgMicroToken.letAssignment(int offset, String lexeme) {
    return NgMicroToken._(NgMicroTokenType.letAssignment, lexeme, offset);
  }

  factory NgMicroToken.letAssignmentBefore(int offset, String lexeme) {
    return NgMicroToken._(
      NgMicroTokenType.letAssignmentBefore,
      lexeme,
      offset,
    );
  }

  factory NgMicroToken.letIdentifier(int offset, String lexeme) {
    return NgMicroToken._(
      NgMicroTokenType.letIdentifier,
      lexeme,
      offset,
    );
  }

  factory NgMicroToken.letKeyword(int offset, String lexeme) {
    return NgMicroToken._(NgMicroTokenType.letKeyword, lexeme, offset);
  }

  factory NgMicroToken.letKeywordAfter(int offset, String lexeme) {
    return NgMicroToken._(NgMicroTokenType.letKeywordAfter, lexeme, offset);
  }

  const NgMicroToken._(this.type, this.lexeme, this.offset);

  @override
  bool operator ==(Object? other) {
    return other is NgMicroToken &&
        other.offset == offset &&
        other.type == type;
  }

  @override
  int get hashCode => Object.hash(offset, lexeme, type);

  /// Indexed location where the token ends in the original source text.
  int get end => offset + length;

  /// Number of characters in this token.
  int get length => lexeme.length;

  /// What characters were scanned and represent this token.
  final String lexeme;

  /// Indexed location where the token begins in the original source text.
  final int offset;

  /// Type of token scanned.
  final NgMicroTokenType type;

  @override
  String toString() => '#$NgMicroToken(${type.name}) {$offset:$lexeme}';
}

enum NgMicroTokenType {
  endExpression,
  bindExpression,
  bindExpressionBefore,
  bindIdentifier,
  letAssignment,
  letAssignmentBefore,
  letIdentifier,
  letKeyword,
  letKeywordAfter
}
