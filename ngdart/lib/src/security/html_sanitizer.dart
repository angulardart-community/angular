import 'dart:js_interop';

import 'package:web/web.dart';

/// Sanitizes the given unsafe, untrusted HTML fragment, and returns HTML text
/// that is safe to add to the DOM in a browser environment.
String? sanitizeHtmlInternal(String value) {
  final template = HTMLTemplateElement();
  template.innerHTML = value.toJS;
  return (template.innerHTML as JSString).toDart;
}
