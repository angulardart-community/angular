/// This library is considered separate from rest of `runtime.dart`, as it
/// imports `web` package and `runtime.dart` is currently used on libraries
/// that expect to only run on the command-line VM.
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:meta/dart2js.dart' as dart2js;
import 'package:ngdart/src/utilities.dart';
import 'package:web/web.dart';

/// https://developer.mozilla.org/en-US/docs/Web/API/Document/createTextNode
Text _createTextNode(String text) => Text(text);

/// https://developer.mozilla.org/en-US/docs/Web/API/Document/createComment
Comment _createComment() => Comment();

/// Set to `true` when Angular modified the DOM.
///
/// May be used in order to optimize polling techniques that attempt to only
/// process events after a significant change detection cycle (i.e. one that
/// modified the DOM versus a no-op).
///
/// **NOTE**: What sets this to `true` (versus ignores it entirely) is currently
/// not consistent (it skips some methods that knowingly update the DOM). See
/// b/122842549.
var domRootRendererIsDirty = false;

/// Either adds or removes [className] to [element] based on [isAdd].
///
/// For example, the following template binding:
/// ```html
/// <div [class.warning]="isWarning">...</div>
/// ```
///
/// ... would emit:
/// ```dart
/// updateClassBinding(_divElement, 'warning', isWarning);
/// ```
///
/// For [element]s not guaranteed to be HTML, see [updateClassBindingNonHtml].
@dart2js.noInline
void updateClassBinding(HTMLElement element, String className, bool isAdd) {
  if (isAdd) {
    element.classList.add(className);
  } else {
    element.classList.remove(className);
  }
}

/// Similar to [updateClassBinding], for an [element] not guaranteed to be HTML.
///
/// For example, using [document.createElement] to create a custom element will
/// not be recognized as a built-in HTML element, or for SVG elements created by the
/// template.
///
/// Dart2JS emits slightly more optimized cost in [updateClassBinding].
@dart2js.noInline
void updateClassBindingNonHtml(Element element, String className, bool isAdd) {
  if (isAdd) {
    element.classList.add(className);
  } else {
    element.classList.remove(className);
  }
}

/// Updates [attribute] on [element] to reflect [value].
///
/// If [value] is `null`, this implicitly _removes_ [attribute] from [element].
@dart2js.noInline
void updateAttribute(
  Element element,
  String attribute,
  String? value,
) {
  if (value == null) {
    element.removeAttribute(attribute);
  } else {
    setAttribute(element, attribute, value);
  }
  domRootRendererIsDirty = true;
}

/// Similar to [updateAttribute], but supports name-spaced attributes.
@dart2js.noInline
void updateAttributeNS(
  Element element,
  String namespace,
  String attribute,
  String? value,
) {
  if (value == null) {
    element.removeAttributeNS(namespace, attribute);
  } else {
    element.setAttributeNS(namespace, attribute, value);
  }
  domRootRendererIsDirty = true;
}

/// Similar to [updateAttribute], but strictly for setting the initial [value].
///
/// This is meant as a slight optimization when initially building elements
/// from the template, as it does not check to see if [value] is `null` (and
/// the attribute should be removed) nor does it set [domRootRendererIsDirty].
@dart2js.noInline
void setAttribute(
  Element element,
  String attribute, [
  String value = '',
]) {
  element.setAttribute(attribute, value);
}

/// Helper function for setting an arbitrary [property] on an [element].
///
/// For example `setProperty(e, 'disabled', true)` should compile to:
///
/// ```js
/// e.disabled = true;
/// ```
@dart2js.tryInline
void setProperty(
  Element element,
  String property,
  Object? value,
) {
  // TODO(ykmnkmi): `ngcompiler` doesn't have type data to use convert
  //  values to JS types and use `JSAny` here. Expected to be inlined
  //  with right type.
  if (value == null) {
    element[property] = null;
  } else if (value is bool) {
    element[property] = value.toJS;
  } else if (value is num) {
    element[property] = value.toJS;
  } else if (value is String) {
    element[property] = value.toJS;
  } else {
    element[property] = value.jsify();
  }
}

/// Creates a [Text] node with the provided [contents].
///
/// This is an optimization to reduce code size for a common operation.
///
/// For example, the naive way of creating text nodes would be:
///
/// ```dart
/// var a = Text('Hello');
/// var b = Text('World');
/// var c = Text('!')
/// ```
///
/// This in turn compiles to the following after Dart2JS:
///
/// ```js
/// var t, a, b, c;
/// t = document;
/// a = t.createTextNode('Hello');
/// b = t.createTextNode('World');
/// c = t.createTextNode('!')
/// ```
///
/// Where-as using [createText] minimizes the amount of code:
///
/// ```dart
/// var d = document;
/// var a = createText(d, 'Hello');
/// var b = createText(d, 'World');
/// var c = createText('!');
/// ```
///
/// ... compiles to (and can be further minified, assume as `z6` below):
///
/// ```js
/// var t, a, b, c;
/// t = document;
/// a = z6(d, 'Hello');
/// b = z6(d, 'World');
/// c = z6(d, '!');
/// ```
@dart2js.noInline
Text createText(String contents) {
  return _createTextNode(contents);
}

/// Appends and returns a a new [Text] node to a [parent] node.
///
/// This is an optimization to reduce code size for a common operation.
@dart2js.noInline
Text appendText(Node parent, String text) {
  return unsafeCast(parent.appendChild(createText(text)));
}

/// Returns a new [Comment] node with empty contents.
///
/// This is an optimization to reduce code size for a common operation.
@dart2js.noInline
Comment createAnchor() => _createComment();

/// Appends and returns a new empty [Comment] to a [parent] node.
///
/// This is an optimization to reduce code size for a common operation.
@dart2js.noInline
Comment appendAnchor(Node parent) {
  return unsafeCast(parent.appendChild(_createComment()));
}

/// Appends and returns a new empty [DivElement] to a [parent] node.
///
/// This is an optimization to reduce code size for a common operation.
@dart2js.noInline
HTMLDivElement appendDiv(Document doc, Node parent) {
  return unsafeCast(parent.appendChild(doc.createElement('div')));
}

/// Appends and returns a new empty [HTMLSpanElement] to a [parent] node.
///
/// This is an optimization to reduce code size for a common operation.
@dart2js.noInline
HTMLSpanElement appendSpan(Document doc, Node parent) {
  return unsafeCast(parent.appendChild(doc.createElement('span')));
}

/// Appends and returns a new empty [Element] to a [parent] node.
///
/// For `<div>`, see [appendDiv], and for `<span>`, see [appendSpan].
///
/// This is an optimization to reduce code size for a common operation.
@dart2js.noInline
T appendElement<T extends Element>(
  Document doc,
  Node parent,
  String tagName,
) {
  // <T extends Element> allows the pattern:
  // HTMLElement e = appendElement(doc, parent, 'foo')
  //
  // ... without gratituous use of unsafeCast or casts in general.
  return unsafeCast(parent.appendChild(doc.createElement(tagName)));
}

/// Inserts [nodes] into the DOM before [sibling].
@dart2js.noInline
void insertNodesBefore(List<Node> nodes, Node parent, Node sibling) {
  for (var i = 0, l = nodes.length; i < l; i++) {
    parent.insertBefore(nodes[i], sibling);
  }
}

/// Appends [nodes] into the DOM inside of [parent].
@dart2js.noInline
void appendNodes(List<Node> nodes, Node parent) {
  for (var i = 0, l = nodes.length; i < l; i++) {
    parent.appendChild(nodes[i]);
  }
}

/// Removes [nodes] from the DOM.
@dart2js.noInline
void removeNodes(List<Node> nodes) {
  for (var i = 0; i < nodes.length; i++) {
    var node = nodes[i];
    node.parentNode?.removeChild(node);
  }
}

/// Appends [nodes] into the DOM as siblings of [sibling] node.
///
/// **NOTE**: This was previously called `_moveNodesAfterSibling`.
@dart2js.noInline
void insertNodesAsSibling(List<Node> nodes, Node sibling) {
  final parentOfSibling = sibling.parentNode;
  if (nodes.isEmpty || parentOfSibling == null) {
    return;
  }
  final nextSibling = sibling.nextSibling;
  if (nextSibling == null) {
    appendNodes(nodes, parentOfSibling);
  } else {
    insertNodesBefore(nodes, parentOfSibling, nextSibling);
  }
}
