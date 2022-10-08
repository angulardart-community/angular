part of 'testability.dart';

@JS('ngTestabilityRegistries')
external List<JsTestabilityRegistry>? _ngJsTestabilityRegistries;

@JS('getAngularTestability')
external set _jsGetAngularTestability(
    Object? Function(Element element) function);

@JS('getAllAngularTestabilities')
external set _jsGetAllAngularTestabilities(List<Object> Function() function);

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
      _jsGetAngularTestability = allowInterop(_getAngularTestability);
      _jsGetAllAngularTestabilities = allowInterop(_getAllAngularTestabilities);
      (_jsFrameworkStabilizers ??= <Object?>[])
          .add(allowInterop(_whenAllStable));
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
      testabilities[i].whenStable(allowInterop(decrement));
    }
  }
}

extension on Testability {
  JsTestability asJsApi() {
    return JsTestability(
      isStable: allowInterop(() => isStable),
      whenStable: allowInterop(whenStable),
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
      getAngularTestability: allowInterop(getAngularTestability),
      getAllAngularTestabilities: allowInterop(getAllAngularTestabilities),
    );
  }
}
