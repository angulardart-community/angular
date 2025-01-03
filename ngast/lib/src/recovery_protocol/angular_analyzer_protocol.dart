part of 'recovery_protocol.dart';

class NgAnalyzerRecoveryProtocol extends RecoveryProtocol {
  @override
  RecoverySolution hasError(
      NgSimpleToken current, NgTokenReversibleReader<Object> reader) {
    return RecoverySolution.skip();
  }

  @override
  RecoverySolution isEndOfFile(
      NgSimpleToken current, NgTokenReversibleReader<Object> reader) {
    return RecoverySolution.skip();
  }

  @override
  RecoverySolution scanAfterComment(
      NgSimpleToken current, NgTokenReversibleReader<Object> reader) {
    NgScannerState? returnState;
    NgToken? returnToken;

    if (current.type == NgSimpleTokenType.eof) {
      reader.putBack(current);
      returnState = NgScannerState.scanStart;
      returnToken = NgToken.generateErrorSynthetic(
          current.offset, NgTokenType.commentEnd);
      return RecoverySolution(returnState, returnToken);
    }
    return RecoverySolution(returnState, returnToken);
  }

  @override
  RecoverySolution scanAfterElementDecorator(
      NgSimpleToken current, NgTokenReversibleReader<Object> reader) {
    NgScannerState? returnState;
    NgToken? returnToken;
    var type = current.type;
    var offset = current.offset;

    if (type == NgSimpleTokenType.openBracket ||
        type == NgSimpleTokenType.openParen ||
        type == NgSimpleTokenType.openBanana ||
        type == NgSimpleTokenType.hash ||
        type == NgSimpleTokenType.star ||
        type == NgSimpleTokenType.atSign ||
        type == NgSimpleTokenType.closeBracket ||
        type == NgSimpleTokenType.closeParen ||
        type == NgSimpleTokenType.closeBanana ||
        type == NgSimpleTokenType.identifier) {
      reader.putBack(current);
      returnState = NgScannerState.scanElementDecorator;
      returnToken = NgToken.generateErrorSynthetic(
          offset, NgTokenType.beforeElementDecorator,
          lexeme: ' ');
    } else if (type == NgSimpleTokenType.eof ||
        type == NgSimpleTokenType.commentBegin ||
        type == NgSimpleTokenType.openTagStart ||
        type == NgSimpleTokenType.closeTagStart) {
      reader.putBack(current);
      returnState = NgScannerState.scanStart;
      returnToken =
          NgToken.generateErrorSynthetic(offset, NgTokenType.openElementEnd);
    } else if (type == NgSimpleTokenType.doubleQuote ||
        type == NgSimpleTokenType.singleQuote) {
      reader.putBack(current);
      returnState = NgScannerState.scanElementDecoratorValue;
      returnToken = NgToken.generateErrorSynthetic(
          offset, NgTokenType.beforeElementDecoratorValue);
    }

    return RecoverySolution(returnState, returnToken);
  }

  @override
  RecoverySolution scanAfterElementDecoratorValue(
      NgSimpleToken current, NgTokenReversibleReader<Object> reader) {
    NgScannerState? returnState;
    NgToken? returnToken;
    var type = current.type;
    var offset = current.offset;

    if (type == NgSimpleTokenType.openBracket ||
        type == NgSimpleTokenType.openParen ||
        type == NgSimpleTokenType.openBanana ||
        type == NgSimpleTokenType.hash ||
        type == NgSimpleTokenType.star ||
        type == NgSimpleTokenType.atSign ||
        type == NgSimpleTokenType.identifier ||
        type == NgSimpleTokenType.closeBracket ||
        type == NgSimpleTokenType.closeParen ||
        type == NgSimpleTokenType.closeBanana ||
        type == NgSimpleTokenType.equalSign ||
        type == NgSimpleTokenType.doubleQuote ||
        type == NgSimpleTokenType.singleQuote) {
      reader.putBack(current);
      returnState = NgScannerState.scanElementDecorator;
      returnToken = NgToken.generateErrorSynthetic(
          offset, NgTokenType.beforeElementDecorator,
          lexeme: ' ');
    } else if (type == NgSimpleTokenType.eof ||
        type == NgSimpleTokenType.commentBegin ||
        type == NgSimpleTokenType.openTagStart ||
        type == NgSimpleTokenType.closeTagStart) {
      reader.putBack(current);
      returnToken =
          NgToken.generateErrorSynthetic(offset, NgTokenType.openElementEnd);
      returnState = NgScannerState.scanStart;
    }

    return RecoverySolution(returnState, returnToken);
  }

  @override
  RecoverySolution scanAfterElementIdentifierClose(
      NgSimpleToken current, NgTokenReversibleReader<Object> reader) {
    NgScannerState? returnState;
    NgToken? returnToken;
    var type = current.type;
    var offset = current.offset;

    if (type == NgSimpleTokenType.commentBegin ||
        type == NgSimpleTokenType.openTagStart ||
        type == NgSimpleTokenType.closeTagStart ||
        type == NgSimpleTokenType.eof ||
        type == NgSimpleTokenType.voidCloseTag) {
      if (type != NgSimpleTokenType.voidCloseTag) {
        reader.putBack(current);
      }
      returnToken =
          NgToken.generateErrorSynthetic(offset, NgTokenType.closeElementEnd);
      returnState = NgScannerState.scanStart;
    }

    return RecoverySolution(returnState, returnToken);
  }

  @override
  RecoverySolution scanAfterElementIdentifierOpen(
      NgSimpleToken current, NgTokenReversibleReader<Object> reader) {
    NgScannerState? returnState;
    NgToken? returnToken;
    var type = current.type;

    if (type == NgSimpleTokenType.openBracket ||
        type == NgSimpleTokenType.openParen ||
        type == NgSimpleTokenType.openBanana ||
        type == NgSimpleTokenType.hash ||
        type == NgSimpleTokenType.star ||
        type == NgSimpleTokenType.atSign ||
        type == NgSimpleTokenType.equalSign ||
        type == NgSimpleTokenType.closeBracket ||
        type == NgSimpleTokenType.closeParen ||
        type == NgSimpleTokenType.closeBanana ||
        type == NgSimpleTokenType.doubleQuote ||
        type == NgSimpleTokenType.singleQuote) {
      reader.putBack(current);
      returnToken = NgToken.generateErrorSynthetic(
          current.offset, NgTokenType.beforeElementDecorator,
          lexeme: ' ');
      returnState = NgScannerState.scanElementDecorator;
    } else if (type == NgSimpleTokenType.commentBegin ||
        type == NgSimpleTokenType.openTagStart ||
        type == NgSimpleTokenType.closeTagStart ||
        type == NgSimpleTokenType.eof) {
      reader.putBack(current);
      returnToken = NgToken.generateErrorSynthetic(
          current.offset, NgTokenType.openElementEnd);
      returnState = NgScannerState.scanStart;
    }

    return RecoverySolution(returnState, returnToken);
  }

  @override
  RecoverySolution scanAfterInterpolation(
      NgSimpleToken current, NgTokenReversibleReader<Object> reader) {
    var type = current.type;
    if (type == NgSimpleTokenType.eof ||
        type == NgSimpleTokenType.mustacheBegin ||
        type == NgSimpleTokenType.whitespace) {
      reader.putBack(current);
      return RecoverySolution(
          NgScannerState.scanStart,
          NgToken.generateErrorSynthetic(
              current.offset, NgTokenType.interpolationEnd));
    }
    return RecoverySolution.skip();
  }

  @override
  RecoverySolution scanBeforeElementDecorator(
      NgSimpleToken current, NgTokenReversibleReader<Object> reader) {
    return RecoverySolution.skip();
  }

  @override
  RecoverySolution scanBeforeInterpolation(
      NgSimpleToken current, NgTokenReversibleReader<Object> reader) {
    NgScannerState? returnState;
    NgToken? returnToken;
    if (current.type == NgSimpleTokenType.text ||
        current.type == NgSimpleTokenType.mustacheEnd) {
      reader.putBack(current);
      returnToken = NgToken.generateErrorSynthetic(
          current.offset, NgTokenType.interpolationStart);
      returnState = NgScannerState.scanInterpolation;
    }
    return RecoverySolution(returnState, returnToken);
  }

  @override
  RecoverySolution scanComment(
      NgSimpleToken current, NgTokenReversibleReader<Object> reader) {
    if (current.type == NgSimpleTokenType.eof) {
      return RecoverySolution(
          NgScannerState.scanStart,
          NgToken.generateErrorSynthetic(
              current.offset, NgTokenType.commentEnd));
    }
    return RecoverySolution.skip();
  }

  @override
  RecoverySolution scanInterpolation(
      NgSimpleToken current, NgTokenReversibleReader<Object> reader) {
    NgScannerState? returnState;
    NgToken? returnToken;
    var type = current.type;

    if (type == NgSimpleTokenType.eof ||
        type == NgSimpleTokenType.mustacheBegin ||
        type == NgSimpleTokenType.mustacheEnd ||
        type == NgSimpleTokenType.whitespace) {
      reader.putBack(current);
      returnToken = NgToken.generateErrorSynthetic(
          current.offset, NgTokenType.interpolationValue,
          lexeme: '');
      returnState = NgScannerState.scanAfterInterpolation;
    }
    return RecoverySolution(returnState, returnToken);
  }

  @override
  RecoverySolution scanElementDecorator(
      NgSimpleToken current, NgTokenReversibleReader<Object> reader) {
    NgScannerState? returnState;
    NgToken? returnToken;
    var type = current.type;
    var offset = current.offset;

    if (type == NgSimpleTokenType.equalSign ||
        type == NgSimpleTokenType.commentBegin ||
        type == NgSimpleTokenType.openTagStart ||
        type == NgSimpleTokenType.closeTagStart ||
        type == NgSimpleTokenType.eof ||
        type == NgSimpleTokenType.doubleQuote ||
        type == NgSimpleTokenType.singleQuote) {
      reader.putBack(current);
      returnToken =
          NgToken.generateErrorSynthetic(offset, NgTokenType.elementDecorator);
      returnState = NgScannerState.scanAfterElementDecorator;
    } else if (type == NgSimpleTokenType.closeBracket) {
      reader.putBack(current);
      returnState = NgScannerState.scanSpecialPropertyDecorator;
      returnToken =
          NgToken.generateErrorSynthetic(offset, NgTokenType.propertyPrefix);
    } else if (type == NgSimpleTokenType.closeParen) {
      reader.putBack(current);
      returnState = NgScannerState.scanSpecialEventDecorator;
      returnToken =
          NgToken.generateErrorSynthetic(offset, NgTokenType.eventPrefix);
    } else if (type == NgSimpleTokenType.closeBanana) {
      reader.putBack(current);
      returnState = NgScannerState.scanSpecialBananaDecorator;
      returnToken =
          NgToken.generateErrorSynthetic(offset, NgTokenType.bananaPrefix);
    }

    return RecoverySolution(returnState, returnToken);
  }

  @override
  RecoverySolution scanElementDecoratorValue(
      NgSimpleToken current, NgTokenReversibleReader<Object> reader) {
    NgScannerState? returnState;
    NgToken? returnToken;
    var type = current.type;
    var offset = current.offset;

    if (type == NgSimpleTokenType.openBracket ||
        type == NgSimpleTokenType.openParen ||
        type == NgSimpleTokenType.openBanana ||
        type == NgSimpleTokenType.closeBracket ||
        type == NgSimpleTokenType.closeParen ||
        type == NgSimpleTokenType.closeBanana ||
        type == NgSimpleTokenType.commentBegin ||
        type == NgSimpleTokenType.openTagStart ||
        type == NgSimpleTokenType.closeTagStart ||
        type == NgSimpleTokenType.tagEnd ||
        type == NgSimpleTokenType.voidCloseTag ||
        type == NgSimpleTokenType.eof ||
        type == NgSimpleTokenType.equalSign ||
        type == NgSimpleTokenType.hash ||
        type == NgSimpleTokenType.star ||
        type == NgSimpleTokenType.atSign) {
      reader.putBack(current);
      returnState = NgScannerState.scanAfterElementDecoratorValue;

      var left =
          NgToken.generateErrorSynthetic(offset, NgTokenType.doubleQuote);
      var value = NgToken.generateErrorSynthetic(
          offset, NgTokenType.elementDecoratorValue);
      var right =
          NgToken.generateErrorSynthetic(offset, NgTokenType.doubleQuote);

      returnToken = NgAttributeValueToken.generate(left, value, right);
    }
    if (type == NgSimpleTokenType.identifier) {
      returnState = NgScannerState.scanAfterElementDecoratorValue;
      var left =
          NgToken.generateErrorSynthetic(offset, NgTokenType.doubleQuote);
      var value = NgToken.elementDecoratorValue(offset, current.lexeme);
      var right = NgToken.generateErrorSynthetic(
          offset + current.length, NgTokenType.doubleQuote);

      returnToken = NgAttributeValueToken.generate(left, value, right);
    }

    return RecoverySolution(returnState, returnToken);
  }

  @override
  RecoverySolution scanElementEndClose(
      NgSimpleToken current, NgTokenReversibleReader<Object> reader) {
    NgScannerState? returnState;
    NgToken? returnToken;
    var type = current.type;
    var offset = current.offset;

    if (type == NgSimpleTokenType.commentBegin ||
        type == NgSimpleTokenType.openTagStart ||
        type == NgSimpleTokenType.closeTagStart ||
        type == NgSimpleTokenType.eof ||
        type == NgSimpleTokenType.voidCloseTag) {
      if (type != NgSimpleTokenType.voidCloseTag) {
        reader.putBack(current);
      }
      returnToken =
          NgToken.generateErrorSynthetic(offset, NgTokenType.closeElementEnd);
      returnState = NgScannerState.scanStart;
    }

    return RecoverySolution(returnState, returnToken);
  }

  @override
  RecoverySolution scanElementEndOpen(
      NgSimpleToken current, NgTokenReversibleReader<Object> reader) {
    return RecoverySolution.skip();
  }

  @override
  RecoverySolution scanElementIdentifierClose(
      NgSimpleToken current, NgTokenReversibleReader<Object> reader) {
    NgScannerState? returnState;
    NgToken? returnToken;
    var type = current.type;
    var offset = current.offset;

    if (type == NgSimpleTokenType.closeTagStart ||
        type == NgSimpleTokenType.openTagStart ||
        type == NgSimpleTokenType.tagEnd ||
        type == NgSimpleTokenType.commentBegin ||
        type == NgSimpleTokenType.eof ||
        type == NgSimpleTokenType.whitespace) {
      reader.putBack(current);
      returnToken =
          NgToken.generateErrorSynthetic(offset, NgTokenType.elementIdentifier);
      returnState = NgScannerState.scanAfterElementIdentifierClose;
    }

    return RecoverySolution(returnState, returnToken);
  }

  @override
  RecoverySolution scanElementIdentifierOpen(
      NgSimpleToken current, NgTokenReversibleReader<Object> reader) {
    NgScannerState? returnState;
    NgToken? returnToken;
    var type = current.type;
    var offset = current.offset;

    if (type == NgSimpleTokenType.openBracket ||
        type == NgSimpleTokenType.openParen ||
        type == NgSimpleTokenType.openBanana ||
        type == NgSimpleTokenType.hash ||
        type == NgSimpleTokenType.star ||
        type == NgSimpleTokenType.atSign ||
        type == NgSimpleTokenType.closeBracket ||
        type == NgSimpleTokenType.closeParen ||
        type == NgSimpleTokenType.closeBanana ||
        type == NgSimpleTokenType.commentBegin ||
        type == NgSimpleTokenType.openTagStart ||
        type == NgSimpleTokenType.closeTagStart ||
        type == NgSimpleTokenType.tagEnd ||
        type == NgSimpleTokenType.eof ||
        type == NgSimpleTokenType.equalSign ||
        type == NgSimpleTokenType.whitespace ||
        type == NgSimpleTokenType.doubleQuote ||
        type == NgSimpleTokenType.singleQuote) {
      reader.putBack(current);
      returnToken =
          NgToken.generateErrorSynthetic(offset, NgTokenType.elementIdentifier);
      returnState = NgScannerState.scanAfterElementIdentifierOpen;
    }
    return RecoverySolution(returnState, returnToken);
  }

  @override
  RecoverySolution scanOpenElementEnd(
      NgSimpleToken current, NgTokenReversibleReader<Object> reader) {
    return RecoverySolution.skip();
  }

  @override
  RecoverySolution scanElementStart(
      NgSimpleToken current, NgTokenReversibleReader<Object> reader) {
    return RecoverySolution.skip();
  }

  @override
  RecoverySolution scanSimpleElementDecorator(
      NgSimpleToken current, NgTokenReversibleReader<Object> reader) {
    NgScannerState? returnState;
    NgToken? returnToken;
    var type = current.type;

    if (type == NgSimpleTokenType.bang ||
        type == NgSimpleTokenType.dash ||
        type == NgSimpleTokenType.forwardSlash ||
        type == NgSimpleTokenType.period ||
        type == NgSimpleTokenType.unexpectedChar ||
        type == NgSimpleTokenType.percent ||
        type == NgSimpleTokenType.backSlash) {
      return RecoverySolution.skip();
    }
    reader.putBack(current);
    returnState = NgScannerState.scanAfterElementDecorator;
    returnToken = NgToken.generateErrorSynthetic(
        current.offset, NgTokenType.elementDecorator);
    return RecoverySolution(returnState, returnToken);
  }

  @override
  RecoverySolution scanSpecialBananaDecorator(
      NgSimpleToken current, NgTokenReversibleReader<Object> reader) {
    NgScannerState? returnState;
    NgToken? returnToken;
    var type = current.type;

    if (type == NgSimpleTokenType.bang ||
        type == NgSimpleTokenType.dash ||
        type == NgSimpleTokenType.forwardSlash ||
        type == NgSimpleTokenType.unexpectedChar ||
        type == NgSimpleTokenType.percent ||
        type == NgSimpleTokenType.backSlash) {
      return RecoverySolution.skip();
    }
    reader.putBack(current);
    returnState = NgScannerState.scanSuffixBanana;
    returnToken = NgToken.generateErrorSynthetic(
        current.offset, NgTokenType.elementDecorator);
    return RecoverySolution(returnState, returnToken);
  }

  @override
  RecoverySolution scanSpecialEventDecorator(
      NgSimpleToken current, NgTokenReversibleReader<Object> reader) {
    NgScannerState? returnState;
    NgToken? returnToken;
    var type = current.type;

    if (type == NgSimpleTokenType.bang ||
        type == NgSimpleTokenType.dash ||
        type == NgSimpleTokenType.forwardSlash ||
        type == NgSimpleTokenType.unexpectedChar ||
        type == NgSimpleTokenType.percent ||
        type == NgSimpleTokenType.backSlash) {
      return RecoverySolution.skip();
    }
    reader.putBack(current);
    returnState = NgScannerState.scanSuffixEvent;
    returnToken = NgToken.generateErrorSynthetic(
        current.offset, NgTokenType.elementDecorator);
    return RecoverySolution(returnState, returnToken);
  }

  @override
  RecoverySolution scanSpecialPropertyDecorator(
      NgSimpleToken current, NgTokenReversibleReader<Object> reader) {
    NgScannerState? returnState;
    NgToken? returnToken;
    var type = current.type;

    if (type == NgSimpleTokenType.bang ||
        type == NgSimpleTokenType.dash ||
        type == NgSimpleTokenType.forwardSlash ||
        type == NgSimpleTokenType.unexpectedChar ||
        type == NgSimpleTokenType.percent ||
        type == NgSimpleTokenType.backSlash) {
      return RecoverySolution.skip();
    }
    reader.putBack(current);
    returnState = NgScannerState.scanSuffixProperty;
    returnToken = NgToken.generateErrorSynthetic(
        current.offset, NgTokenType.elementDecorator);
    return RecoverySolution(returnState, returnToken);
  }

  @override
  RecoverySolution scanStart(
      NgSimpleToken current, NgTokenReversibleReader<Object> reader) {
    return RecoverySolution.skip();
  }

  @override
  RecoverySolution scanSuffixBanana(
      NgSimpleToken current, NgTokenReversibleReader<Object> reader) {
    NgScannerState? returnState;
    NgToken? returnToken;
    var type = current.type;

    if (type == NgSimpleTokenType.bang ||
        type == NgSimpleTokenType.forwardSlash ||
        type == NgSimpleTokenType.dash ||
        type == NgSimpleTokenType.unexpectedChar ||
        type == NgSimpleTokenType.percent ||
        type == NgSimpleTokenType.backSlash) {
      return RecoverySolution.skip();
    }
    reader.putBack(current);
    returnState = NgScannerState.scanAfterElementDecorator;
    returnToken = NgToken.generateErrorSynthetic(
        current.offset, NgTokenType.bananaSuffix);
    return RecoverySolution(returnState, returnToken);
  }

  @override
  RecoverySolution scanSuffixEvent(
      NgSimpleToken current, NgTokenReversibleReader<Object> reader) {
    NgScannerState? returnState;
    NgToken? returnToken;
    var type = current.type;

    if (type == NgSimpleTokenType.bang ||
        type == NgSimpleTokenType.forwardSlash ||
        type == NgSimpleTokenType.dash ||
        type == NgSimpleTokenType.unexpectedChar ||
        type == NgSimpleTokenType.percent ||
        type == NgSimpleTokenType.backSlash) {
      return RecoverySolution.skip();
    }
    reader.putBack(current);
    returnState = NgScannerState.scanAfterElementDecorator;
    returnToken =
        NgToken.generateErrorSynthetic(current.offset, NgTokenType.eventSuffix);
    return RecoverySolution(returnState, returnToken);
  }

  @override
  RecoverySolution scanSuffixProperty(
      NgSimpleToken current, NgTokenReversibleReader<Object> reader) {
    NgScannerState? returnState;
    NgToken? returnToken;
    var type = current.type;

    if (type == NgSimpleTokenType.bang ||
        type == NgSimpleTokenType.forwardSlash ||
        type == NgSimpleTokenType.dash ||
        type == NgSimpleTokenType.unexpectedChar ||
        type == NgSimpleTokenType.percent ||
        type == NgSimpleTokenType.backSlash) {
      return RecoverySolution.skip();
    }

    reader.putBack(current);
    returnState = NgScannerState.scanAfterElementDecorator;
    returnToken = NgToken.generateErrorSynthetic(
        current.offset, NgTokenType.propertySuffix);
    return RecoverySolution(returnState, returnToken);
  }

  @override
  RecoverySolution scanText(
      NgSimpleToken current, NgTokenReversibleReader<Object> reader) {
    return RecoverySolution.skip();
  }
}
