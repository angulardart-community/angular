import 'package:web/web.dart';

final _inertFragment = DocumentFragment();

/// Sanitizes the given unsafe, untrusted HTML fragment, and returns HTML text
/// that is safe to add to the DOM in a browser environment.
///
/// This function uses the builtin Dart innerHTML sanitization provided by
/// NodeTreeSanitizer on an inert element.
String? sanitizeHtmlInternal(String value) {
  final inertFragment = _inertFragment..textContent = value;
  final safeHtml = inertFragment.textContent;
  inertFragment.textContent = null;
  return safeHtml;
}
