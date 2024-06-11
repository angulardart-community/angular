import 'package:web/web.dart';

extension DOMTokenListIterableExtensions on DOMTokenList {
  Iterable<String> asIterable() sync* {
    for (var i = 0; i < length; i++) {
      yield item(i)!;
    }
  }
}

extension HTMLCollectionIterableExtensions on HTMLCollection {
  Iterable<Element> asIterable() sync* {
    for (var i = 0; i < length; i++) {
      yield item(i)!;
    }
  }
}

extension NodeListIterableExtensions on NodeList {
  Iterable<Node> asIterable() sync* {
    for (var i = 0; i < length; i++) {
      yield item(i)!;
    }
  }
}

extension ElementStyleExtensions on Element {
  CSSStyleDeclaration getComputedStyle() {
    return window.getComputedStyle(this);
  }
}
