part of 'testability.dart';

@JS('ngTestabilityRegistries')
external List<JsTestabilityRegistry>? _ngJsTestabilityRegistries;

@JS('getAngularTestability')
external set _jsGetAngularTestability(JSFunction function);

@JS('getAllAngularTestabilities')
external set _jsGetAllAngularTestabilities(JSFunction function);

@JS('frameworkStabilizers')
external List<Object?>? _jsFrameworkStabilizers;

class _JSTestabilityProxy implements _TestabilityProxy {
  const _JSTestabilityProxy();

  @override
  void addToWindow(TestabilityRegistry registry) {
    var registries = _ngJsTestabilityRegistries;
    if (registries == null) {
      registries = <JsTestabilityRegistry>[];
      _ngJsTestabilityRegistries = registries;
      _jsGetAngularTestability = _getAngularTestability.toJS;
      _jsGetAllAngularTestabilities = _getAllAngularTestabilities.toJS;
      (_jsFrameworkStabilizers ??= <Object?>[]).add(_whenAllStable.toJS);
    }
    registries.add(registry.asJsApi());
  }

  /// For every registered [TestabilityRegistry], tries `getAngularTestability`.
  static JsTestability? _getAngularTestability(Element element) {
    final registry = _ngJsTestabilityRegistries;
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
  static List<JsTestability> _getAllAngularTestabilities() {
    final registry = _ngJsTestabilityRegistries;
    if (registry == null) {
      return <JsTestability>[];
    }
    final result = <JsTestability>[];
    for (var i = 0; i < registry.length; i++) {
      final testabilities = registry[i].getAllAngularTestabilities();
      result.addAll(testabilities);
    }
    return result;
  }

  /// For every testability, calls [callback] when they _all_ report stable.
  static void _whenAllStable(void Function() callback) {
    final testabilities = _getAllAngularTestabilities();

    var pendingStable = testabilities.length;

    void decrement() {
      pendingStable--;
      if (pendingStable == 0) {
        callback();
      }
    }

    for (var i = 0; i < testabilities.length; i++) {
      testabilities[i].whenStable(decrement.toJS);
    }
  }
}

extension on Testability {
  JsTestability asJsApi() {
    return JsTestability(
      isStable: (() => isStable).toJS,
      whenStable: whenStable.toJS,
    );
  }
}

extension on TestabilityRegistry {
  JsTestabilityRegistry asJsApi() {
    JsTestability? getAngularTestability(Element element) {
      final dartTestability = testabilityFor(element);
      return dartTestability?.asJsApi();
    }

    List<JsTestability> getAllAngularTestabilities() {
      return allTestabilities
          .map((testability) => testability.asJsApi())
          .toList();
    }

    return JsTestabilityRegistry(
      getAngularTestability: getAngularTestability.toJS,
      getAllAngularTestabilities: getAllAngularTestabilities.toJS,
    );
  }
}
