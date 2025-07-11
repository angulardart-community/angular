import 'dart:js_interop';

import 'package:ngdart/angular.dart' show OpaqueToken;
import 'package:web/web.dart';

/// `LocationStrategy` is responsible for representing and reading route state
/// from the browser's URL. Angular provides two strategies:
/// [HashLocationStrategy] and [PathLocationStrategy] (default).
///
/// This is used under the hood of the [Location] service.
///
/// Applications should use the [Router] or [Location] services to
/// interact with application route state.
///
/// For instance, [HashLocationStrategy] produces URLs like
/// `http://example.com#/foo`, and [PathLocationStrategy] produces
/// `http://example.com/foo` as an equivalent URL.
///
/// See these two classes for more.
abstract class LocationStrategy {
  String path();
  String hash();
  String prepareExternalUrl(String internal);
  void pushState(JSAny? state, String title, String url, String queryParams);
  void replaceState(JSAny? state, String title, String url, String queryParams);
  void forward();
  void back();
  void onPopState(void Function(Event event) fn);
  String getBaseHref();
}

/// The [appBaseHref] token represents the base HREF to be used for the router.
///
/// For example, if your site is at `/my/app` on your host:
/// ```dart
/// const ValueProvider.forToken(appBaseHref, '/my/app');
/// ```
const appBaseHref = OpaqueToken<String>('appBaseHref');
