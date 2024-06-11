@JS()
library angular.src.testability.js_api;

import 'dart:js_interop';

import 'package:web/web.dart';

/// A JavaScript interface for interacting with AngularDart's `Testability` API.
///
/// This interfaces with a running AngularDart application.
@JS()
@anonymous
abstract class JsTestability {
  external factory JsTestability({
    required JSFunction isStable,
    required JSFunction whenStable,
  });

  /// Returns whether the application is considered stable.
  ///
  /// Stability is determined when the DOM is unlikely to change due to the
  /// framework. By default, this is determined by no known asynchronous tasks
  /// (microtasks, or timers) being present but not yet executed within the
  /// framework context.
  bool isStable();

  /// Invokes the provided [callback] when the application [isStable].
  ///
  /// If the application was already stable at the time of this function being
  /// invoked, [callback] is invoked with a value of `false` for `didWork`,
  /// indicating that no asynchronous work was awaited before execution.
  /// Otherwise a value of `true` is passed.
  void whenStable(JSFunction callback);
}

/// A JavaScript interface for interacting with AngularDart's `TestabilityRegistry` API.
///
/// A global registry of `Testability` instances given an app root element.
@JS()
@anonymous
abstract class JsTestabilityRegistry {
  external factory JsTestabilityRegistry({
    required JSFunction getAngularTestability,
    required JSFunction getAllAngularTestabilities,
  });

  /// Returns the registered testability instance for [appRoot], or `null`.
  JsTestability? getAngularTestability(Element appRoot);

  /// Returns all testability instances registered.
  List<JsTestability> getAllAngularTestabilities();
}
