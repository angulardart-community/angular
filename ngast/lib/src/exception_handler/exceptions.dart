part of 'exception_handler.dart';

@sealed
class ParserErrorCode {
  static const cannotFindMatchingClose = ParserErrorCode._(
    'CANNOT_FIND_MATCHING_CLOSE',
    'Cannot find matching close element to this',
  );

  static const danglingCloseElement = ParserErrorCode._(
    'DANGLING_CLOSE_ELEMENT',
    'Closing tag is dangling and no matching open tag can be found',
  );

  static const duplicateStarDirective = ParserErrorCode._(
    'DUPLICATE_STAR_DIRECTIVE',
    'Already found a *-directive, limit 1 per element.',
  );

  static const duplicateSelectDecorator = ParserErrorCode._(
    'DUPLICATE_SELECT_DECORATOR',
    "Only 1 'select' decorator can exist in <ng-content>, found duplicate",
  );

  static const duplicateProjectAsDecorator = ParserErrorCode._(
    'DUPLICATE_PROJECT_AS_DECORATOR',
    "Only 1 'ngProjectAs' decorator can exist in <ng-content>, found duplicate",
  );

  static const duplicateReferenceDecorator = ParserErrorCode._(
    'DUPLICATE_REFERENCE_DECORATOR',
    'Only 1 reference decorator can exist in <ng-content>, found duplicate',
  );

  static const elementDecorator = ParserErrorCode._(
    'ELEMENT_DECORATOR',
    'Expected element decorator after whitespace',
  );

  static const elementDecoratorAfterPrefix = ParserErrorCode._(
    'ELEMENT_DECORATOR_AFTER_PREFIX',
    'Expected element decorator identifier after prefix',
  );

  static const elementDecoratorSuffixBeforePrefix = ParserErrorCode._(
    'ELEMENT_DECORATOR',
    'Found special decorator suffix before prefix',
  );

  static const elementDecoratorValue = ParserErrorCode._(
    'ELEMENT_DECORATOR_VALUE',
    "Expected quoted value following '='",
  );

  static const elementDecoratorValueMissingQuotes = ParserErrorCode._(
    'ELEMENT_DECORATOR_VALUE_MISSING_QUOTES',
    'Decorator values must contain quotes',
  );

  static const elementIdentifier = ParserErrorCode._(
    'ELEMENT_IDENTIFIER',
    'Expected element tag name',
  );

  static const expectedAfterElementIdentifier = ParserErrorCode._(
    'EXPECTED_AFTER_ELEMENT_IDENTIFIER',
    'Expected either whitespace or close tag end after element identifier',
  );

  static const expectedEqualSign = ParserErrorCode._(
    'EXPECTED_EQUAL_SIGN',
    "Expected '=' between decorator and value",
  );

  static const expectedStandalone = ParserErrorCode._(
    'EXPECTING_STANDALONE',
    'Expected standalone token',
  );

  static const expectedTagClose = ParserErrorCode._(
    'EXPECTED_TAG_CLOSE',
    'Expected tag close.',
  );

  // 'Catch-all' error code.
  static const expectedToken = ParserErrorCode._(
    'UNEXPECTED_TOKEN',
    'Unexpected token',
  );

  static const expectedWhitespaceBeforeNewDecorator = ParserErrorCode._(
    'EXPECTED_WHITESPACE_BEFORE_DECORATOR',
    'Expected whitespace before a new decorator',
  );

  static const emptyInterpolation = ParserErrorCode._(
    'EMPTY_INTERPOLATION',
    'Interpolation expression cannot be empty',
  );

  static const invalidDecoratorInNgContainer = ParserErrorCode._(
    'INVALID_DECORATOR_IN_NGCONTAINER',
    "Only '*' bindings are supported on <ng-container>",
  );

  static const invalidDecoratorInNgContent = ParserErrorCode._(
    'INVALID_DECORATOR_IN_NGCONTENT',
    "Only 'select' is a valid attribute/decorate in <ng-content>",
  );

  static const invalidDecoratorInTemplate = ParserErrorCode._(
    'INVALID_DECORATOR_IN_TEMPLATE',
    "Invalid decorator in 'template' element",
  );

  static const invalidLetBindingInNoTemplate = ParserErrorCode._(
    'INVALID_LET_BINDING_IN_NONTEMPLATE',
    "'let-' binding can only be used in 'template' element",
  );

  static const invalidMicroExpression = ParserErrorCode._(
    'INVALID_MICRO_EXPRESSION',
    'Failed parsing micro expression',
  );

  static const nonVoidElementUsingVoidEnd = ParserErrorCode._(
    'NONVOID_ELEMENT_USING_VOID_END',
    'Element is not a void-element',
  );

  static const ngContentMustCLoseImmediately = ParserErrorCode._(
    'NGCONTENT_MUST_CLOSE_IMMEDIATElY',
    "'<ng-content ...>' must be followed immediately by close '</ng-content>'",
  );

  static const propertyNameTooManyFixes = ParserErrorCode._(
    'PROPERTY_NAME_TOO_MANY_FIXES',
    "Property name can only be in format: 'name[.postfix[.unit]]",
  );

  static const referenceIdentifierFound = ParserErrorCode._(
    'REFERENCE_IDENTIFIER_FOUND',
    'Reference decorator only supports #<variable> on <ng-content>',
  );

  static const suffixBanana = ParserErrorCode._(
    'SUFFIX_BANANA',
    "Expected closing banana ')]'",
  );

  static const suffixEvent = ParserErrorCode._(
    'SUFFIX_EVENT',
    "Expected closing parenthesis ')'",
  );

  static const suffixProperty = ParserErrorCode._(
    'SUFFIX_PROPERTY',
    "Expected closing bracket ']'",
  );

  static const enclosedQuote = ParserErrorCode._(
    'UNCLOSED_QUOTE',
    'Expected close quote for element decorator value',
  );

  static const unopenedMustache = ParserErrorCode._(
    'UNOPENED_MUSTACHE',
    'Unopened mustache',
  );

  static const unterminatedComment = ParserErrorCode._(
    'UNTERMINATED COMMENT',
    'Unterminated comment',
  );

  static const unterminatedMustache = ParserErrorCode._(
    'UNTERMINATED_MUSTACHE',
    'Unterminated mustache',
  );

  static const voidElementInCloseTag = ParserErrorCode._(
    'VOID_ELEMENT_IN_CLOSE_TAG',
    'Void element identifiers cannot be used in close element tag',
  );

  static const voidCloseInCloseTag = ParserErrorCode._(
    'VOID_CLOSE_IN_CLOSE_TAG',
    "Void close '/>' cannot be used in a close element",
  );

  final String name;

  final String message;

  /// Initialize a newly created erorr code to have the given [name].
  /// The message associated with the error will be created from the
  /// given [message] template. The correction associated with the error
  /// will be created from the given [correction] template.
  const ParserErrorCode._(
    this.name,
    this.message,
  );
}
