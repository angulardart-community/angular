/// A wrapper around a native element inside of a View.
///
/// An `ElementRef` is backed by a render-specific element. In the browser, this
/// is usually a DOM element.
///
/// **DEPRECATED**: A wrapper around a native DOM element inside of a View.
///
/// Inject `Element` or `HTMLElement` from `dart:html` instead; this will be
/// removed in a future version of AngularDart, and has unnecessary overhead.
@Deprecated(
    'Inject or reference package:web/web.dart Element or HTMLElement instead')
class ElementRef {
  final dynamic nativeElement;

  // Requires that, if provided, this value is non-null.
  //
  // Then it is upcasted to dynamic for the public API to be non-breaking.
  // ignore: prefer_initializing_formals
  @Deprecated(
      'Inject or reference package:web/web.dart Element or HTMLElement instead')
  const ElementRef(this.nativeElement);
}
