import 'package:sanitize_dom/sanitize_dom.dart';
import 'package:web/web.dart';

final _inertFragment = DocumentFragment();

/// Sanitizes the given unsafe, untrusted HTML fragment, and returns HTML text
/// that is safe to add to the DOM in a browser environment.
String? sanitizeHtmlInternal(String value) {
  final inertFragment = _inertFragment..innerHtml = value;
  final safeHtml = inertFragment.innerHtml;

  while (inertFragment.firstChild != null) {
    inertFragment.removeChild(inertFragment.firstChild!);
  }

  return safeHtml;
}
