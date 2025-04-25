part of 'testability.dart';

@JS('ngTestabilityRegistries')
external JSArray<JSTestabilityRegistry>? _ngJSTestabilityRegistries;

@JS('getAngularTestability')
external set _jsGetAngularTestability(JSFunction function);

@JS('getAllAngularTestabilities')
external set _jsGetAllAngularTestabilities(JSFunction function);

@JS('frameworkStabilizers')
external JSArray<JSFunction>? _jsFrameworkStabilizers;

extension on JSArray {
  external void push(JSAny item);
}

class _JSTestabilityProxy implements _TestabilityProxy {
  const _JSTestabilityProxy();

  @override
  void addToWindow(TestabilityRegistry registry) {
    var registries = _ngJSTestabilityRegistries;
    if (registries == null) {
      registries = JSArray<JSTestabilityRegistry>();
      _ngJSTestabilityRegistries = registries;
      _jsGetAngularTestability = _getAngularTestability.toJS;
      _jsGetAllAngularTestabilities = _getAllAngularTestabilities.toJS;
      (_jsFrameworkStabilizers ??= JSArray<JSFunction>())
          .push(_whenAllStable.toJS);
    }
    registries.push(registry.toJS);
  }

  /// For every registered [TestabilityRegistry], tries `getAngularTestability`.
  static JSTestability? _getAngularTestability(Element element) {
    final registry = _ngJSTestabilityRegistries;
    if (registry == null) {
      return null;
    }
    for (var i = 0; i < registry.length; i++) {
      final result = registry[i].getAngularTestability(element);
      if (result != null) {
        return result;
      }
    }
    return null;
  }

  /// For every registered [TestabilityRegistry], returns the JS API for it.
  static JSArray<JSTestability> _getAllAngularTestabilities() {
    final registry = _ngJSTestabilityRegistries;
    var result = JSArray<JSTestability>();
    if (registry != null) {
      for (var i = 0; i < registry.length; i++) {
        final testabilities = registry[i].getAllAngularTestabilities();
        result = result.callMethod('concat'.toJS, testabilities)
            as JSArray<JSTestability>;
      }
    }
    return result;
  }

  /// For every testability, calls [callback] when they _all_ report stable.
  static void _whenAllStable(JSFunction callback) {
    final testabilities = _getAllAngularTestabilities();

    var pendingStable = testabilities.length;

    void decrement() {
      pendingStable--;
      if (pendingStable == 0) {
        callback.callAsFunction();
      }
    }

    for (var i = 0; i < testabilities.length; i++) {
      testabilities[i].whenStable(decrement.toJS);
    }
  }
}

extension on Testability {
  JSTestability get toJS {
    return JSTestability(
      isStable: (() => isStable).toJS,
      whenStable: (JSFunction callback) {
        whenStable(() {
          callback.callAsFunction();
        });
      }.toJS,
    );
  }
}

extension on TestabilityRegistry {
  JSTestabilityRegistry get toJS {
    JSTestability? getAngularTestability(Element element) {
      final dartTestability = testabilityFor(element);
      return dartTestability?.toJS;
    }

    JSArray<JSTestability> getAllAngularTestabilities() {
      return allTestabilities
          .map((testability) => testability.toJS)
          .toList()
          .toJS;
    }

    return JSTestabilityRegistry(
      getAngularTestability: getAngularTestability.toJS,
      getAllAngularTestabilities: getAllAngularTestabilities.toJS,
    );
  }
}
