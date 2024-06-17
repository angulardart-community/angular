import 'dart:js_interop';

import 'package:ngdart/angular.dart' show Injectable;
import 'package:web/web.dart';

import 'base_href.dart';
import 'platform_location.dart';

/// `PlatformLocation` encapsulates all of the direct calls to platform APIs.
/// This class should not be used directly by an application developer. Instead, use
/// [Location].
@Injectable()
class BrowserPlatformLocation extends PlatformLocation {
  final Location location;
  final History _history;

  BrowserPlatformLocation()
      : location = window.location,
        _history = window.history;

  @override
  String? getBaseHrefFromDOM() => baseHrefFromDOM();

  @override
  void onPopState(void Function(Event) fn) {
    window.addEventListener('popstate', fn.toJS, false.toJS);
  }

  @override
  void onHashChange(void Function(Event) fn) {
    window.addEventListener('hashchange', fn.toJS, false.toJS);
  }

  @override
  String get pathname {
    return location.pathname;
  }

  @override
  String get search {
    return location.search;
  }

  @override
  String get hash {
    return location.hash;
  }

  set pathname(String newPath) {
    location.pathname = newPath;
  }

  @override
  void pushState(Object? state, String title, String? url) {
    _history.pushState(state?.toJSBox, title, url);
  }

  @override
  void replaceState(Object? state, String title, String? url) {
    _history.replaceState(state?.toJSBox, title, url);
  }

  @override
  void forward() {
    _history.forward();
  }

  @override
  void back() {
    _history.back();
  }
}
