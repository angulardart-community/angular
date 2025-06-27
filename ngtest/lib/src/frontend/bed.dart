import 'dart:async';

import 'package:ngdart/angular.dart';
import 'package:web/web.dart';

import '../bootstrap.dart';
import '../errors.dart';
import 'fixture.dart';
import 'ng_zone/real_time_stabilizer.dart';
import 'ng_zone/timer_hook_zone.dart';
import 'stabilizer.dart';

/// Used to determine if there is an actively executing test.
NgTestFixture<void>? activeTest;

/// If any [NgTestFixture] is currently executing, calls `dispose` on it.
///
/// Returns a future that completes when the test is destroyed.
///
/// This function is meant to be used within
/// the `tearDown` function of `package:test`:
/// ```dart
/// tearDown(() => disposeAnyRunningTest());
/// ```
Future<void> disposeAnyRunningTest() async {
  return activeTest?.dispose();
}

/// An immutable builder for creating a pre-configured AngularDart application.
///
/// The root component type [T] that is created is essentially the same as a
/// root application component you would create normally with `bootstrap`.
///
/// For a simple test:
/// ```dart
/// group('$HelloWorldComponent', () {
///   tearDown(() => disposeAnyRunningTest());
///
///   test('should render "Hello World"', () async {
///     var bed = new NgTestBed<HelloWorldComponent>();
///     var fixture = await bed.create();
///     expect(fixture.text, contains('Hello World'));
///   });
/// });
/// ```
///
/// New behavior and features can be added in a hierarchy of tests:
/// ```dart
/// group('My tests', () {
///   NgTestBed<HelloWorldComponent> bed;
///   NgTestFixture<HelloWorldComponent> fixture;
///
///   setUp(() => bed = new NgTestBed<HelloWorldComponent>());
///   tearDown(() => disposeAnyRunningTest());
///
///   test('should render "Hello World", () async {
///     fixture = await bed.create();
///     expect(fixture.text, contains('Hello World'));
///   });
///
///   test('should render "Hello World" in all-caps', () async {
///     bed = bed.addProviders(const [
///       const ClassProvider(TextFormatter, AllCapsTextFormatter),
///     ]);
///     fixture = await bed.create();
///     expect(fixture.text, contains('HELLO WORLD'));
///   });
/// });
/// ```
class NgTestBed<T extends Object> {
  static Element _defaultHost() {
    final host = document.createElement('ng-test-bed');
    document.body!.append(host);
    return host;
  }

  static Injector _defaultRootInjector(Injector parent) => parent;

  static NgTestStabilizer _alwaysStable(
    Injector _,
  ) =>
      NgTestStabilizer.alwaysStable;

  static NgTestStabilizer _defaultStabilizers(
    Injector injector, [
    TimerHookZone? timerZone,
  ]) {
    // There is no good way in Dart to support a union between two function
    // types with different amounts of required, positional arguments, without
    // taking `Object` or `Function` and casting.
    //
    // NgTestStabilizer Function(Injector) &
    // NgTestStabilizer Function(Injector, [Object?])
    // ... *are* compatible though, so we rely on that for this internal code.
    //
    // (We assume if _defaultStabilizers is invoked, timerZone has been set.)
    return RealTimeNgZoneStabilizer(timerZone!, injector.provideType(NgZone));
  }

  final Element? _host;
  final NgTestStabilizerFactory _createStabilizer;

  // TODO(b/157257828): Split initReflector APIs into a separate class.
  final ComponentFactory<T> _componentFactory;
  final InjectorFactory _rootInjector;

  /// Create a new [NgTestBed] that uses the provided [component] factory.
  ///
  /// ```dart
  /// void main() {
  ///   final ngTestBed = NgTestBed(
  ///     SomeComponentNgFactory,
  ///     rootInjector: ([parent]) => Injector.map({
  ///       Service: Service(),
  ///     }, parent),
  ///   );
  /// }
  /// ```
  factory NgTestBed(
    ComponentFactory<T> component, {
    Element? host,
    InjectorFactory rootInjector = _defaultRootInjector,
    bool watchAngularLifecycle = true,
  }) {
    if (T == dynamic) {
      throw GenericTypeMissingError();
    }
    return NgTestBed<T>._useComponentFactory(
      component: component,
      rootInjector: rootInjector,
      host: host,
      watchAngularLifecycle: watchAngularLifecycle,
    );
  }

  NgTestBed._({
    Element? host,
    required NgTestStabilizerFactory stabilizer,
    InjectorFactory? rootInjector,
    required ComponentFactory<T> component,
  })  : _host = host,
        _createStabilizer = stabilizer,
        _rootInjector = rootInjector ?? _defaultRootInjector,
        _componentFactory = component;

  NgTestBed._useComponentFactory({
    Element? host,
    required ComponentFactory<T> component,
    required InjectorFactory rootInjector,
    required bool watchAngularLifecycle,
  })  : _host = host,
        _createStabilizer =
            watchAngularLifecycle ? _defaultStabilizers : _alwaysStable,
        _rootInjector = rootInjector,
        _componentFactory = component;

  /// Returns a new instance of [NgTestBed] with the root injector wrapped.
  ///
  /// That is, [factory] will _supplement_ the existing injector(s). In most
  /// cases this is likely not required unless you are re-using test
  /// configuration across many tests with subtle differences.
  NgTestBed<T> addInjector(InjectorFactory factory) {
    return fork(
      rootInjector: (Injector parent) => _rootInjector(factory(parent)),
    );
  }

  /// Returns a new instance of [NgTestBed] with [stabilizers] added.
  NgTestBed<T> addStabilizers(Iterable<NgTestStabilizerFactory> stabilizers) {
    // [_alwaysStable] is the default stabilizer when there is no other
    // stabilizers. It should be removed when other stabilizers exist.
    if (_createStabilizer == _alwaysStable) {
      return fork(stabilizer: composeStabilizers(stabilizers));
    }
    return fork(
      stabilizer: composeStabilizers([_createStabilizer, ...stabilizers]),
    );
  }

  /// Creates a new test application with [T] as the root component.
  ///
  /// If [beforeChangeDetection] is set, it is called _before_ any initial
  /// change detection (so you can do initialization of component state that
  /// might be required).
  ///
  /// Returns a future that completes with a fixture around the component.
  Future<NgTestFixture<T>> create({
    FutureOr<void> Function(Injector)? beforeComponentCreated,
    FutureOr<void> Function(T instance)? beforeChangeDetection,
  }) {
    // We *purposefully* do not use async/await here - that always adds an
    // additional micro-task - we want this to fail fast without entering an
    // asynchronous event if another test is running.
    _checkForActiveTest();

    // Future.sync promotes synchronous errors to Future.error if they occur.
    return Future<NgTestFixture<T>>.sync(() {
      // Ensure that no tests have started since the last microtask.
      _checkForActiveTest();

      // Create a zone to intercept timer creation.
      final timerHookZone = TimerHookZone();
      late final NgZone ngZoneInstance;
      NgZone ngZoneFactory() {
        return timerHookZone.run(() {
          return ngZoneInstance = NgZone();
        });
      }

      // Created within "createStabilizersAndRunUserHook".
      late final NgTestStabilizer allStabilizers;

      Future<void> createStabilizersAndRunUserHook(Injector injector) async {
        // Some internal stabilizers get access to the TimerHookZone.
        // Most (i.e. user-land) stabilizers do not.
        final createStabilizer = _createStabilizer;
        allStabilizers = createStabilizer is AllowTimerHookZoneAccess
            ? createStabilizer(injector, timerHookZone)
            : createStabilizer(injector);

        // If there is no user hook, we are done.
        if (beforeComponentCreated == null) {
          return;
        }

        // If there is a user hook, execute it within the ngZone:
        final completer = Completer<void>();
        ngZoneInstance.runGuarded(() async {
          try {
            await beforeComponentCreated(injector);
            completer.complete();
          } catch (e, s) {
            completer.completeError(e, s);
          }
        });
        return completer.future.whenComplete(() => allStabilizers.update());
      }

      return bootstrapForTest<T>(
        _componentFactory,
        _host ?? _defaultHost(),
        _rootInjector,
        beforeComponentCreated: createStabilizersAndRunUserHook,
        beforeChangeDetection: beforeChangeDetection,
        createNgZone: ngZoneFactory,
      ).then((componentRef) async {
        _checkForActiveTest();
        await allStabilizers.stabilize();
        final testFixture = NgTestFixture(
          componentRef.injector.provideType(ApplicationRef),
          componentRef,
          allStabilizers,
        );
        // We need the local variable to capture the generic type T.
        activeTest = testFixture;
        return testFixture;
      });
    });
  }

  static void _checkForActiveTest() {
    if (activeTest != null) {
      throw TestAlreadyRunningError();
    }
  }

  /// Creates a new instance of [NgTestBed].
  ///
  /// Any non-null value overrides the existing properties.
  NgTestBed<E> fork<E extends T>({
    Element? host,
    ComponentFactory<E>? component,
    InjectorFactory? rootInjector,
    NgTestStabilizerFactory? stabilizer,
  }) {
    return NgTestBed<E>._(
      host: host ?? _host,
      stabilizer: stabilizer ?? _createStabilizer,
      rootInjector: rootInjector ?? _rootInjector,
      component: component ?? _componentFactory as ComponentFactory<E>,
    );
  }

  /// Returns a new instance of [NgTestBed] with [component] overrode.
  NgTestBed<E> setComponent<E extends T>(ComponentFactory<E> component) {
    return fork<E>(component: component);
  }

  /// Returns a new instance of [NgTestBed] with [host] overrode.
  NgTestBed<T> setHost(Element host) => fork(host: host);
}
