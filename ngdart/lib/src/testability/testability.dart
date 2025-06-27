import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:meta/meta.dart';
import 'package:web/web.dart';

import '../../di.dart';
import '../core/zone/ng_zone.dart';
import 'js_api.dart';

part 'js_impl.dart';

/// The [Testability] providers.
///
/// The [testabilityProvider] should be added to the app's root injector.
/// ```
/// @GenerateInjector([testabilityProvider])
/// final InjectorFactory appInjector = ng.appInjector$Injector;
/// ...
/// runApp(ng.MyAppComponentNgFactory, createInjector: appInjector);
/// ```
const testabilityProvider = [
  ClassProvider(Testability),
  ClassProvider(TestabilityRegistry),
];

/// Provides testing hooks accessible via JavaScript APIs in the browser.
///
/// To access the [Testability] API from a browser, the [TestabilityRegistry]
/// must be injected too.
// TODO(b/168535057): Add `dispose` function (to unsubscribe, remove elements).
@sealed
class Testability {
  final NgZone _ngZone;

  Testability(this._ngZone);

  List<void Function()>? _callWhenStable;

  /// Registers [callback] to be invoked when change detection is completed.
  ///
  /// This is commonly referred to as _stable_, that-is that the DOM
  /// representation of the app is synchronized with the Dart data and template
  /// models, and no more changes are (currently) epected.
  void whenStable(void Function() callback) {
    _storeCallback(callback);
    _runCallbacksIfStable();
  }

  void _storeCallback(void Function() callback) {
    var callWhenStable = _callWhenStable;
    if (callWhenStable == null) {
      _callWhenStable = [callback];
      _ngZone.runOutsideAngular(() {
        _ngZone.onTurnDone.listen((_) {
          // Wait until the end of the event loop before checking stability.
          scheduleMicrotask(() => _runCallbacksIfStable());
        });
      });
    } else {
      callWhenStable.add(callback);
    }
  }

  /// Whether the framework is no longer anticipating change detection.
  ///
  /// See [whenStable] for details.
  bool get isStable => !_ngZone.isRunning && !_ngZone.hasPendingMacrotasks;

  void _runCallbacksIfStable() {
    if (!isStable) {
      // Wait until this function is called again (it will be).
    } else {
      // Schedule the callback in a new microtask so this never is synchronous.
      scheduleMicrotask(() => _runCallbacks());
    }
  }

  void _runCallbacks() {
    var callWhenStable = _callWhenStable!;
    while (callWhenStable.isNotEmpty) {
      callWhenStable.removeLast()();
    }
  }
}

/// A global registry of [Testability] instances given an app root element.
class TestabilityRegistry {
  TestabilityRegistry() {
    const _TestabilityProxy().addToWindow(this);
  }

  final _appRoots = <Element, Testability>{};

  /// Associate [appRoot] with the provided [testability] instance.
  void registerApplication(Element appRoot, Testability testability) {
    _appRoots[appRoot] = testability;
  }

  /// Returns the registered testability instance for [appRoot], or `null`.
  Testability? testabilityFor(Element appRoot) => _appRoots[appRoot];

  /// Returns all testability instances registered.
  Iterable<Testability> get allTestabilities => _appRoots.values;
}

/// Provides implementation details for how to export and import the JS APIs.
abstract class _TestabilityProxy {
  const factory _TestabilityProxy() = _JSTestabilityProxy;

  /// Adds [registry] to the current browser context (i.e. `window.*`).
  void addToWindow(TestabilityRegistry registry);
}
