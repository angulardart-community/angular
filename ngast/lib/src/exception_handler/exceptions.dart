part of 'exception_handler.dart';

@sealed
enum ParserErrorCode {
  cannotFindMatchingClose('Cannot find matching close element to this'),
  danglingCloseElement('Closing tag is dangling and no matching open tag can be found'),
  duplicateStarDirective('Already found a *-directive, limit 1 per element.'),
  duplicateSelectDecorator("Only 1 'select' decorator can exist in <ng-content>, found duplicate"),
  duplicateProjectAsDecorator("Only 1 'ngProjectAs' decorator can exist in <ng-content>, found duplicate"),
  duplicateReferenceDecorator('Only 1 reference decorator can exist in <ng-content>, found duplicate'),
  elementDecorator('Expected element decorator after whitespace'),
  elementDecoratorAfterPrefix('Expected element decorator identifier after prefix'),
  elementDecoratorSuffixBeforePrefix('Found special decorator suffix before prefix'),
  elementDecoratorValue("Expected quoted value following '='"),
  elementDecoratorValueMissingQuotes('Decorator values must contain quotes'),
  elementIdentifier('Expected element tag name'),
  expectedAfterElementIdentifier('Expected either whitespace or close tag end after element identifier'),
  expectedEqualSign("Expected '=' between decorator and value"),
  expectedStandalone('Expected standalone token'),
  expectedTagClose('Expected tag close.'),
  // 'Catch-all' error code.
  expectedToken('Unexpected token'),
  expectedWhitespaceBeforeNewDecorator('Expected whitespace before a new decorator'),
  emptyInterpolation('Interpolation expression cannot be empty'),
  invalidDecoratorInNgContainer("Only '*' bindings are supported on <ng-container>"),
  invalidDecoratorInNgContent("Only 'select' is a valid attribute/decorate in <ng-content>"),
  invalidDecoratorInTemplate("Invalid decorator in 'template' element"),
  invalidLetBindingInNoTemplate("'let-' binding can only be used in 'template' element"),
  invalidMicroExpression('Failed parsing micro expression'),
  nonVoidElementUsingVoidEnd('Element is not a void-element'),
  ngContentMustCLoseImmediately("'<ng-content ...>' must be followed immediately by close '</ng-content>'"),
  propertyNameTooManyFixes("Property name can only be in format: 'name[.postfix[.unit]]"),
  referenceIdentifierFound('Reference decorator only supports #<variable> on <ng-content>'),
  suffixBanana("Expected closing banana ')]'"),
  suffixEvent("Expected closing parenthesis ')'"),
  suffixProperty("Expected closing bracket ']'"),
  enclosedQuote('Expected close quote for element decorator value'),
  unopenedMustache('Unopened mustache'),
  unterminatedComment('Unterminated comment'),
  unterminatedMustache('Unterminated mustache'),
  voidElementInCloseTag('Void element identifiers cannot be used in close element tag'),
  voidCloseInCloseTag("Void close '/>' cannot be used in a close element");

  final String message;

  /// Initialize a newly created erorr code to have the given [name].
  /// The message associated with the error will be created from the
  /// given [message] template. The correction associated with the error
  /// will be created from the given [correction] template.
  const ParserErrorCode(this.message);
}
