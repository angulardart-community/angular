part of ngast.src.token.tokens;

/// The types of tokens that can be returned by the NgStringTokenizer
enum NgSimpleTokenType {
  atSign('@'),
  bang('!'),
  backSlash('\\'),
  closeBanana(')]'),
  closeBrace('}'),
  closeBracket(']'),
  closeParen(')'),
  closeTagStart('</'),
  commentBegin('<!--'),
  commentEnd('-->'),
  dash('-'),
  doubleQuote('"'),
  openTagStart('<'),
  tagEnd('>'),
  equalSign('='),
  EOF(''),
  forwardSlash('/'),
  hash('#'),
  identifier(''),
  mustacheBegin('{{'),
  mustacheEnd('}}'),
  openBanana('[('),
  openBrace('{'),
  openBracket('['),
  openParen('('),
  period('.'),
  percent('%'),
  singleQuote("'"),
  star('*'),
  text(''),
  unexpectedChar('?'),
  voidCloseTag('/>'),
  whitespace(' ');

  final String symbols;
  const NgSimpleTokenType(this.symbols);
}

/// The types of tokens that can be returned by the NgScanner.
enum NgTokenType {
  annotationPrefix('@'),
  bananaPrefix('[('),
  bananaSuffix(')]'),
  bindPrefix('bind-'), // Not used in NgScanner.
  beforeElementDecorator(''),
  beforeElementDecoratorValue('='),
  closeElementEnd('>'),
  closeElementStart('</'),
  commentEnd('-->'),
  commentStart('<!--'),
  commentValue(''),
  doubleQuote('"'),
  elementDecorator(''),
  elementDecoratorValue(''),
  elementIdentifier(''),
  eventPrefix('('),
  eventSuffix(')'),
  interpolationEnd('}}'),
  interpolationStart('{{'),
  interpolationValue(''),
  letPrefix('let-'),
  openElementEnd('>'),
  openElementEndVoid('/>'),
  openElementStart('<'),
  onPrefix('on-'), // Not used in NgScanner.
  propertyPrefix('['),
  propertySuffix(']'),
  referencePrefix('#'),
  singleQuote("'"),
  templatePrefix('*'),
  text(''),
  whitespace(' ');

  final String symbols;
  const NgTokenType(this.symbols);
}
