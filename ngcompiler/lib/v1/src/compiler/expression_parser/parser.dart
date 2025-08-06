import 'package:meta/meta.dart';
import 'package:ngcompiler/v1/src/compiler/compile_metadata.dart';
import 'package:ngcompiler/v1/src/compiler/expression_parser/analyzer_parser.dart';
import 'package:ngcompiler/v1/src/compiler/expression_parser/ast.dart';
import 'package:ngcompiler/v1/src/compiler/expression_parser/lexer.dart';
import 'package:ngcompiler/v1/src/compiler/js_split_facade.dart';
import 'package:ngcompiler/v2/context.dart';

final _implicitReceiver = ImplicitReceiver();
final _findInterpolation = RegExp(r'{{([\s\S]*?)}}');

class ParseException extends BuildError {
  final String _message;

  ParseException(
    String message,
    String? input,
    String errLocation, [
    dynamic ctxLocation,
  ]) : _message =
            'Parser Error: $message $errLocation [$input] in $ctxLocation';

  @override
  String toString() {
    return _message;
  }
}

abstract class ExpressionParserImpl {
  AST parseActionImpl(
    String input,
    String location,
    List<CompileIdentifierMetadata> exports,
  );

  AST parseBindingImpl(
    String input,
    String location,
    List<CompileIdentifierMetadata> exports,
  );

  AST? parseInterpolationImpl(
    String input,
    String location,
    List<CompileIdentifierMetadata> exports,
  );

  /// Helper method for implementing [parseInterpolation].
  ///
  /// Splits a longer multi-expression interpolation into [SplitInterpolation].
  @protected
  SplitInterpolation? splitInterpolation(String input, String location) {
    List<String> parts = jsSplit(input, _findInterpolation);

    if (parts.length <= 1) {
      return null;
    }

    List<String> strings = <String>[];
    List<String> expressions = <String>[];

    for (int i = 0; i < parts.length; i++) {
      String part = parts[i];

      if (i.isEven) {
        // fixed string
        strings.add(part);
      } else if (part.trim().isNotEmpty) {
        expressions.add(part);
      } else {
        throw ParseException(
          'Blank expressions are not allowed in interpolated strings',
          input,
          'at column ${findInterpolationErrorColumn(parts, i)} in',
          location,
        );
      }
    }

    return SplitInterpolation._(strings, expressions);
  }

  @protected
  void checkNoInterpolation(String input, String location) {
    List<String> parts = jsSplit(input, _findInterpolation);

    if (parts.length > 1) {
      throw ParseException(
        'Got interpolation ({{}}) where expression was expected',
        input,
        'at column ${findInterpolationErrorColumn(parts, 1)} in',
        location,
      );
    }
  }

  @protected
  static int findInterpolationErrorColumn(
    List<String> parts,
    int partInErrIdx,
  ) {
    String errLocation = '';

    for (int i = 0; i < partInErrIdx; i++) {
      errLocation += i.isEven ? parts[i] : '{{${parts[i]}}}';
    }

    return errLocation.length;
  }
}

class ExpressionParser extends ExpressionParserImpl {
  final AnalyzerExpressionParser analyzerParser;

  final Lexer lexer;

  ExpressionParser()
      : analyzerParser = AnalyzerExpressionParser(),
        lexer = Lexer();

  /// Parses an event binding (historically called an "action").
  ///
  /// ```
  /// // <div (click)="doThing()">
  /// parseAction('doThing()', ...)
  /// ```
  ASTWithSource parseAction(
    String? input,
    String location,
    List<CompileIdentifierMetadata> exports,
  ) {
    if (input == null) {
      throw ParseException(
        'Blank expressions are not allowed in event bindings.',
        input,
        location,
      );
    }

    checkNoInterpolation(input, location);
    return ASTWithSource(
      parseActionImpl(input, location, exports),
      input,
      location,
    );
  }

  /// Override to implement [parseAction].
  ///
  /// Basic validation is already performed that [input] is seemingly valid.
  @override
  AST parseActionImpl(
    String input,
    String location,
    List<CompileIdentifierMetadata> exports,
  ) {
    if (input.contains(r'$pipe')) {
      return analyzerParser.parseActionImpl(input, location, exports);
    }

    List<Token> tokens = lexer.tokenize(_stripComments(input));
    return _ParseAST(input, location, tokens, true, exports).parsePipe();
  }

  /// Parses an input, property, or attribute binding.
  ///
  /// ```
  /// // <div [title]="renderTitle">
  /// parseBinding('renderTitle', ...)
  /// ```
  ASTWithSource parseBinding(
    String input,
    String location,
    List<CompileIdentifierMetadata> exports,
  ) {
    checkNoInterpolation(input, location);
    return ASTWithSource(
      parseBindingImpl(input, location, exports),
      input,
      location,
    );
  }

  /// Override to implement [parseBinding].
  ///
  /// Basic validation is already performed that [input] is seemingly valid.
  @override
  AST parseBindingImpl(
    String input,
    String location,
    List<CompileIdentifierMetadata> exports,
  ) {
    if (input.contains(r'$pipe')) {
      return analyzerParser.parseBindingImpl(input, location, exports);
    }

    List<Token> tokens = lexer.tokenize(_stripComments(input));
    return _ParseAST(input, location, tokens, false, exports).parsePipe();
  }

  /// Parses a text interpolation.
  ///
  /// ```
  /// // Hello {{place}}!
  /// parseInterpolation('place', ...)
  /// ```
  ///
  /// Returns `null` if there were no interpolations in [input].
  ASTWithSource? parseInterpolation(
    String input,
    String location,
    List<CompileIdentifierMetadata> exports,
  ) {
    AST? result = parseInterpolationImpl(input, location, exports);

    if (result == null) {
      return null;
    }

    return ASTWithSource(result, input, location);
  }

  /// Override to implement [parseInterpolation].
  ///
  /// Basic validation is already performed that [input] is seemingly valid.
  @override
  AST? parseInterpolationImpl(
    String input,
    String location,
    List<CompileIdentifierMetadata> exports,
  ) {
    if (input.contains(r'$pipe')) {
      return analyzerParser.parseInterpolationImpl(input, location, exports);
    }

    SplitInterpolation? split = splitInterpolation(input, location);

    if (split == null) {
      return null;
    }

    List<AST> expressions = <AST>[];

    for (int i = 0; i < split.expressions.length; ++i) {
      List<Token> tokens = lexer.tokenize(_stripComments(split.expressions[i]));
      AST ast = _ParseAST(input, location, tokens, false, exports).parsePipe();
      expressions.add(ast);
    }

    return Interpolation(split.strings, expressions);
  }

  static String _stripComments(String input) {
    var i = _commentStart(input);
    return i != null ? input.substring(0, i).trim() : input;
  }

  static int? _commentStart(String input) {
    int? outerQuote;

    for (var i = 0; i < input.length - 1; i++) {
      var char = input.codeUnitAt(i);
      var nextChar = input.codeUnitAt(i + 1);

      if (identical(char, $SLASH) && nextChar == $SLASH && outerQuote == null) {
        return i;
      }

      if (identical(outerQuote, char)) {
        outerQuote = null;
      } else if (outerQuote == null && isQuote(char)) {
        outerQuote = char;
      }
    }

    return null;
  }
}

/// Splits a longer interpolation expression into [strings] and [expressions].
final class SplitInterpolation {
  final List<String> strings;

  final List<String> expressions;

  SplitInterpolation._(this.strings, this.expressions);
}

final class _ParseAST {
  final String input;

  final String location;

  final List<Token> tokens;

  final bool parseAction;

  Map<String, CompileIdentifierMetadata> exports;

  Map<String, Map<String, CompileIdentifierMetadata>> prefixes;

  int index = 0;

  bool _parseCall = false;

  _ParseAST(
    this.input,
    this.location,
    this.tokens,
    this.parseAction,
    List<CompileIdentifierMetadata> exports,
  )   : exports = <String, CompileIdentifierMetadata>{},
        prefixes = <String, Map<String, CompileIdentifierMetadata>>{} {
    for (var export in exports) {
      if (export.prefix == null) {
        this.exports[export.name] = export;
      } else {
        (prefixes[export.prefix!] ??= {})[export.name] = export;
      }
    }
  }

  Token peek(int offset) {
    var i = index + offset;
    return i < tokens.length ? tokens[i] : Token.eof;
  }

  Token get next => peek(0);

  int get inputIndex => index < tokens.length ? next.index : input.length;

  void advance() {
    index++;
  }

  bool optionalCharacter(int code) {
    if (next.isCharacter(code)) {
      advance();
      return true;
    }

    return false;
  }

  bool peekKeywordLet() {
    return next.isKeywordLet;
  }

  bool peekDeprecatedKeywordVar() {
    return next.isKeywordDeprecatedVar;
  }

  bool peekDeprecatedOperatorHash() {
    return next.isOperator('#');
  }

  void expectCharacter(int code) {
    if (optionalCharacter(code)) {
      return;
    }

    error('Missing expected ${String.fromCharCode(code)}');
  }

  bool optionalOperator(String op) {
    if (next.isOperator(op)) {
      advance();
      return true;
    }

    return false;
  }

  void expectOperator(String operator) {
    if (optionalOperator(operator)) {
      return;
    }

    error('Missing expected operator $operator');
  }

  String expectIdentifierOrKeyword() {
    var n = next;

    if (!n.isIdentifier && !n.isKeyword) {
      error('Unexpected token $n, expected identifier or keyword');
    }

    advance();
    return n.toString();
  }

  String expectIdentifierOrKeywordOrString() {
    var n = next;

    if (!n.isIdentifier && !n.isKeyword && !n.isString) {
      error('Unexpected token $n, expected identifier, keyword, or string');
    }

    advance();
    return n.toString();
  }

  AST parseArgument() {
    return parseExpression();
  }

  AST parsePipe() {
    AST result = parseExpression();

    if (optionalOperator('|')) {
      if (parseAction) {
        error('Cannot have a pipe in an action expression');
      }

      do {
        String name = expectIdentifierOrKeyword();
        List<AST> args = <AST>[];
        bool prevParseCall = _parseCall;
        _parseCall = false;

        while (optionalCharacter($COLON)) {
          args.add(parseExpression());
        }

        _parseCall = prevParseCall;
        result = BindingPipe(result, name, args);
      } while (optionalOperator('|'));
    }

    return result;
  }

  AST parseExpression() {
    return parseConditional();
  }

  AST parseConditional() {
    int start = inputIndex;
    AST result = parseLogicalOr();

    if (optionalOperator('??')) {
      AST nullExp = parsePipe();
      return IfNull(result, nullExp);
    }

    if (optionalOperator('?')) {
      bool prevParseCall = _parseCall;
      _parseCall = false;

      AST yes = parsePipe();

      if (!optionalCharacter($COLON)) {
        int end = inputIndex;
        String expression = input.substring(start, end);
        error('Conditional expression $expression requires all 3 expressions');
      }

      AST no = parsePipe();
      _parseCall = prevParseCall;
      return Conditional(result, yes, no);
    }

    return result;
  }

  AST parseLogicalOr() {
    // '||'
    AST result = parseLogicalAnd();

    while (optionalOperator('||')) {
      result = Binary('||', result, parseLogicalAnd());
    }

    return result;
  }

  AST parseLogicalAnd() {
    // '&&'
    AST result = parseEquality();

    while (optionalOperator('&&')) {
      result = Binary('&&', result, parseEquality());
    }

    return result;
  }

  AST parseEquality() {
    // '==','!=','===','!=='
    AST result = parseRelational();

    while (true) {
      if (optionalOperator('==')) {
        result = Binary('==', result, parseRelational());
      } else if (optionalOperator('===')) {
        result = Binary('===', result, parseRelational());
      } else if (optionalOperator('!=')) {
        result = Binary('!=', result, parseRelational());
      } else if (optionalOperator('!==')) {
        result = Binary('!==', result, parseRelational());
      } else {
        return result;
      }
    }
  }

  AST parseRelational() {
    // '<', '>', '<=', '>='
    AST result = parseAdditive();

    while (true) {
      if (optionalOperator('<')) {
        result = Binary('<', result, parseAdditive());
      } else if (optionalOperator('>')) {
        result = Binary('>', result, parseAdditive());
      } else if (optionalOperator('<=')) {
        result = Binary('<=', result, parseAdditive());
      } else if (optionalOperator('>=')) {
        result = Binary('>=', result, parseAdditive());
      } else {
        return result;
      }
    }
  }

  AST parseAdditive() {
    // '+', '-'
    AST result = parseMultiplicative();

    while (true) {
      if (optionalOperator('+')) {
        result = Binary('+', result, parseMultiplicative());
      } else if (optionalOperator('-')) {
        result = Binary('-', result, parseMultiplicative());
      } else {
        return result;
      }
    }
  }

  AST parseMultiplicative() {
    // '*', '%', '/'
    AST result = parsePrefix();

    while (true) {
      if (optionalOperator('*')) {
        result = Binary('*', result, parsePrefix());
      } else if (optionalOperator('%')) {
        result = Binary('%', result, parsePrefix());
      } else if (optionalOperator('/')) {
        result = Binary('/', result, parsePrefix());
      } else {
        return result;
      }
    }
  }

  AST parsePrefix() {
    if (optionalOperator('+')) {
      return parsePrefix();
    }

    if (optionalOperator('-')) {
      return Binary('-', LiteralPrimitive(0), parsePrefix());
    }

    if (optionalOperator('!')) {
      return PrefixNot(parsePrefix());
    }

    return parseCallChain();
  }

  AST parseCallChain() {
    AST result = parsePrimary();

    while (true) {
      if (optionalCharacter($PERIOD)) {
        result = parseAccessMemberOrMethodCall(result, false);
      } else if (optionalOperator('?.')) {
        result = parseAccessMemberOrMethodCall(result, true);
      } else if (optionalCharacter($LBRACKET)) {
        AST key = parsePipe();
        expectCharacter($RBRACKET);

        if (optionalOperator('=')) {
          AST value = parseConditional();
          result = KeyedWrite(result, key, value);
        } else {
          result = KeyedRead(result, key);
        }
      } else if (_parseCall && optionalCharacter($COLON)) {
        _parseCall = false;

        AST expression = parseExpression();
        _parseCall = true;

        if (result is PropertyRead) {
          result = NamedExpr(result.name, expression);
        } else if (result is StaticRead && result.id.prefix == null) {
          result = NamedExpr(result.id.name, expression);
        } else {
          error('Expected previous token to be an identifier');
        }
      } else if (optionalCharacter($LPAREN)) {
        _CallArguments arguments = parseCallArguments();
        expectCharacter($RPAREN);
        result = FunctionCall(result, arguments.positional, arguments.named);
      } else {
        return result;
      }
    }
  }

  AST parsePrimary() {
    if (optionalCharacter($LPAREN)) {
      AST result = parsePipe();
      expectCharacter($RPAREN);
      return result;
    }

    if (next.isKeywordNull || next.isKeywordUndefined) {
      advance();
      return LiteralPrimitive(null);
    }

    if (next.isKeywordTrue) {
      advance();
      return LiteralPrimitive(true);
    }

    if (next.isKeywordFalse) {
      advance();
      return LiteralPrimitive(false);
    }

    if (next.isIdentifier) {
      AST receiver = _implicitReceiver;
      String identifier = next.stringValue;

      if (exports.containsKey(identifier)) {
        advance();
        return StaticRead(exports[identifier]!);
      }

      if (prefixes.containsKey(identifier)) {
        if (peek(1).isCharacter($PERIOD)) {
          Token nextId = peek(2);

          if (nextId.isIdentifier &&
              prefixes[identifier]!.containsKey(nextId.stringValue)) {
            // consume the prefix, the '.', and the next identifier
            advance();
            advance();
            advance();
            return StaticRead(prefixes[identifier]![nextId.stringValue]!);
          }
        }
      }

      return parseAccessMemberOrMethodCall(receiver, false);
    }

    if (next.isNumber) {
      num value = next.toNumber();
      advance();
      return LiteralPrimitive(value);
    }

    if (next.isString) {
      String literalValue = next.toString();
      advance();
      return LiteralPrimitive(literalValue);
    }

    if (index >= tokens.length) {
      error('Unexpected end of expression: $input');
    } else {
      error('Unexpected token $next');
    }
  }

  AST parseAccessMemberOrMethodCall(AST receiver, [bool isSafe = false]) {
    String id = expectIdentifierOrKeyword();

    if (optionalCharacter($LPAREN)) {
      _CallArguments args = parseCallArguments();
      expectCharacter($RPAREN);
      return isSafe
          ? SafeMethodCall(receiver, id, args.positional, args.named)
          : MethodCall(receiver, id, args.positional, args.named);
    }

    if (isSafe) {
      if (optionalOperator('=')) {
        error("The '?.' operator cannot be used in the assignment");
      }

      return SafePropertyRead(receiver, id);
    }

    if (optionalOperator('=')) {
      if (!parseAction) {
        error('Bindings cannot contain assignments');
      }

      AST value = parseConditional();
      return PropertyWrite(receiver, id, value);
    }

    return PropertyRead(receiver, id);
  }

  _CallArguments parseCallArguments() {
    List<AST> positional = <AST>[];
    List<NamedExpr> named = <NamedExpr>[];

    if (next.isCharacter($RPAREN)) {
      return _CallArguments(positional, named);
    }

    do {
      _parseCall = true;

      AST ast = parsePipe();

      if (ast is NamedExpr) {
        named.add(ast);
      } else {
        positional.add(ast);
      }
    } while (optionalCharacter($COMMA));

    _parseCall = false;
    return _CallArguments(positional, named);
  }

  /// An identifier, a keyword, a string with an optional `-` inbetween.
  String expectTemplateBindingKey() {
    String result = '';
    bool operatorFound = false;

    do {
      result += expectIdentifierOrKeywordOrString();
      operatorFound = optionalOperator('-');

      if (operatorFound) {
        result += '-';
      }
    } while (operatorFound);

    return result.toString();
  }

  Never error(String message, [int? index]) {
    index ??= this.index;

    String location = (index < tokens.length)
        ? 'at column ${tokens[index].index + 1} in'
        : 'at the end of the expression';
    throw ParseException(message, input, location, this.location);
  }
}

final class _CallArguments {
  final List<AST> positional;

  final List<NamedExpr> named;

  _CallArguments(this.positional, this.named);
}
