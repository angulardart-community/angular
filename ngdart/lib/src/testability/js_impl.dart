part of 'testability.dart';

@JS('ngTestabilityRegistries')
external JSArray<JsTestabilityRegistry>? _ngJsTestabilityRegistries;

@JS('getAngularTestability')
external set _jsGetAngularTestability(JSFunction function);

@JS('getAllAngularTestabilities')
external set _jsGetAllAngularTestabilities(JSFunction function);

@JS('frameworkStabilizers')
external JSArray<JSFunction>? _jsFrameworkStabilizers;

class _JSTestabilityProxy implements _TestabilityProxy {
  const _JSTestabilityProxy();

  @override
  void addToWindow(TestabilityRegistry registry) {
    var registries = _ngJsTestabilityRegistries;
    if (registries == null) {
      registries = JSArray();
      _ngJsTestabilityRegistries = registries;
      _jsGetAngularTestability = _getAngularTestability.toJS;
      _jsGetAllAngularTestabilities = _getAllAngularTestabilities.toJS;
      ((_jsFrameworkStabilizers ??= JSArray()) as List<JSFunction>).add(
          ((JSFunction callback) => _whenAllStable(callback as void Function()))
              .toJS);
    }
    registries.add(registry.asJsApi());
  }

  /// For every registered [TestabilityRegistry], tries `getAngularTestability`.
  static JsTestability? _getAngularTestability(Element element) {
    final registries = _ngJsTestabilityRegistries;
    if (registries == null) {
      return null;
    }
    for (final registry in (registries as List<JsTestabilityRegistry>)) {
      final result = registry.getAngularTestability(element);
      if (result != null) {
        return result;
      }
    }
    return null;
  }

  /// For every registered [TestabilityRegistry], returns the JS API for it.
  static JSArray<JsTestability> _getAllAngularTestabilities() {
    final registries = _ngJsTestabilityRegistries;
    if (registries == null) {
      return JSArray();
    }
    final result = <JsTestability>[];
    for (final registry in (registries as List<JsTestabilityRegistry>)) {
      final testabilities =
          registry.getAllAngularTestabilities() as List<JsTestability>;
      result.addAll(testabilities);
    }
    return result.toJS;
  }

  /// For every testability, calls [callback] when they _all_ report stable.
  static void _whenAllStable(void Function() callback) {
    final testabilities = _getAllAngularTestabilities() as List<JsTestability>;

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
      whenStable: ((JSFunction callback) =>
          whenStable(callback as void Function())).toJS,
    );
  }
}

extension on TestabilityRegistry {
  JsTestabilityRegistry asJsApi() {
    JsTestability? getAngularTestability(Element element) {
      final dartTestability = testabilityFor(element);
      return dartTestability?.asJsApi();
    }

    JSArray<JsTestability> getAllAngularTestabilities() {
      return allTestabilities
          .map((testability) => testability.asJsApi())
          .toList()
          .toJS;
    }

    return JsTestabilityRegistry(
      getAngularTestability: getAngularTestability.toJS,
      getAllAngularTestabilities: getAllAngularTestabilities.toJS,
    );
  }
}
