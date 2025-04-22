import 'dart:js_interop';

import 'package:ngdart/angular.dart';
import 'package:test/test.dart';
import 'package:web/web.dart';

/// Matches textual content of an element including children.
Matcher hasTextContent(String expected) => _HasTextContent(expected);

/// Matches DOMTokenList.
Matcher hasDomTokenList(List<String> expected) => _HasDomTokenList(expected);

/// Matches textual content of an element including children.
Matcher hasInnerHtml(String expected) => _HasInnerHtml(expected);

final throwsNoProviderError = throwsA(_isNoProviderError);
final _isNoProviderError = const TypeMatcher<NoProviderError>();

class _HasTextContent extends Matcher {
  final String expectedText;

  const _HasTextContent(this.expectedText);

  @override
  bool matches(Object? item, void _) =>
      _elementText(item as JSAny?) == expectedText;

  @override
  Description describe(Description description) =>
      description.add(expectedText);

  @override
  Description describeMismatch(
    item,
    Description mismatchDescription,
    void _,
    void __,
  ) {
    mismatchDescription.add('Text content of element: '
        '\'${_elementText(item as JSAny?)}\'');
    return mismatchDescription;
  }
}

String? _elementText(JSAny? node) {
  if (node.isA<NodeList>()) {
    return <String?>[
      for (var i = 0; i < (node as NodeList).length; i++)
        _elementText(node.item(i))
    ].join('');
  }

  if (node.isA<Node>()) {
    if (node.isA<Comment>()) {
      return '';
    }

    if (node.isA<Element>() && (node as Element).shadowRoot != null) {
      return _elementText(node.shadowRoot!.childNodes);
    }

    if ((node as Node).childNodes.length != 0) {
      return _elementText(node.childNodes);
    }

    return node.textContent;
  }

  return null;
}

class _HasDomTokenList extends Matcher {
  final List<String?> expectedTokens;

  const _HasDomTokenList(this.expectedTokens);

  @override
  bool matches(Object? item, void _) {
    final tokens = item as DOMTokenList;

    if (tokens.length != expectedTokens.length) {
      return false;
    }

    for (var i = 0; i < expectedTokens.length; i++) {
      if (tokens.item(i) != expectedTokens[i]) {
        return false;
      }
    }

    return true;
  }

  @override
  Description describe(Description description) {
    return description.add(expectedTokens.join(','));
  }

  @override
  Description describeMismatch(
    item,
    Description mismatchDescription,
    void _,
    void __,
  ) {
    mismatchDescription.add('DOMTokenList: \'$item}\'');
    return mismatchDescription;
  }
}

class _HasInnerHtml extends Matcher {
  final String expectedHtml;

  const _HasInnerHtml(this.expectedHtml);

  @override
  bool matches(Object? item, void _) {
    return ((item as Element).innerHTML as JSString).toDart == expectedHtml;
  }

  @override
  Description describe(Description description) =>
      description.add(expectedHtml);

  @override
  Description describeMismatch(
    item,
    Description mismatchDescription,
    void _,
    void __,
  ) {
    mismatchDescription.add('Inner HTML of element: '
        '\'${_elementText(item as Element)}\'');
    return mismatchDescription;
  }
}
