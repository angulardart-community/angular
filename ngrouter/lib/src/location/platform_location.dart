import 'dart:js_interop';

import 'package:web/web.dart';

/// This class should not be used directly by an application developer. Instead, use
/// [Location].
///
/// `PlatformLocation` encapsulates all calls to DOM apis, which allows the Router to be platform
/// agnostic.
/// This means that we can have different implementation of `PlatformLocation` for the different
/// platforms
/// that angular supports. For example, the default `PlatformLocation` is {@link
/// BrowserPlatformLocation},
/// however when you run your app in a WebWorker you use [WebWorkerPlatformLocation].
///
/// The `PlatformLocation` class is used directly by all implementations of [LocationStrategy]
/// when
/// they need to interact with the DOM apis like pushState, popState, etc...
///
/// [LocationStrategy] in turn is used by the [Location] service which is used directly
/// by
/// the [Router] in order to navigate between routes. Since all interactions between {@link
/// Router} /
/// [Location] / [LocationStrategy] and DOM apis flow through the `PlatformLocation`
/// class
/// they are all platform independent.
abstract class PlatformLocation {
  String? getBaseHrefFromDOM();
  void onPopState(void Function(Event event) fn);
  void onHashChange(void Function(Event event) fn);
  String get pathname;
  String get search;
  String get hash;
  void replaceState(JSAny? state, String title, String? url);
  void pushState(JSAny? state, String title, String? url);
  void forward();
  void back();
}
