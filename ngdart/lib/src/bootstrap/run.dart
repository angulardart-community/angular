import 'package:meta/meta.dart';
import 'package:ngdart/src/meta.dart';
import 'package:ngdart/src/testability.dart';

import '../core/app_host.dart';
import '../core/application_ref.dart';
import '../core/application_tokens.dart';
import '../core/linker.dart' show ComponentFactory, ComponentRef;
import '../core/linker/app_view_utils.dart';
import '../core/zone/ng_zone.dart';
import '../devtools.dart';
import '../di/injector.dart';
import '../runtime/dom_events.dart';
import '../utilities.dart';
import 'modules.dart';

/// Used as a "tear-off" of [NgZone].
NgZone _createNgZone() => NgZone();

/// **INTERNAL ONLY**: Creates a new application-level Injector.
///
/// This is more complicated than just creating a new Injector, because we want
/// to make sure we allow [userProvidedInjector] to override _some_ top-level
/// services (`APP_ID`, `ExceptionHandler`) _and_ to ensure that Angular-level
/// services (`ApplicationRef`) get the user-provided versions.
///
/// May override [createNgZone] to provide a custom callback to create one. This
/// is primarily useful in testing (i.e. via directly or indirectly the
/// `ngtest` package).
Injector appInjector(
  InjectorFactory userProvidedInjector, {
  NgZone Function() createNgZone = _createNgZone,
}) {
  // These are the required root services, always provided by AngularDart.
  final minimalInjector = appGlobals.createAppInjector(minimalApp());

  // Lazily initialized later on once we have the user injector.
  late final ApplicationRef applicationRef;
  final ngZone = createNgZone();
  final Injector appGlobalInjector = _LazyInjector({
    ApplicationRef: () => applicationRef,
    AppViewUtils: () => appViewUtils,
    NgZone: () => ngZone,
    Testability: () => Testability(ngZone),
  }, unsafeCast(minimalInjector));

  // These are the user-provided overrides.
  final userInjector = userProvidedInjector(appGlobalInjector);

  // ... and then we add ApplicationRef, which has the unique property of
  // injecting services (specifically, `ExceptionHandler` and `APP_ID`) that
  // might have come from the user-provided injector, instead of the minimal.
  //
  // We also add other top-level services with similar constraints:
  // * `AppViewUtils`
  final injector = ngZone.run(() {
    applicationRef = internalCreateApplicationRef(
      ngZone,
      userInjector,
    );
    appViewUtils = AppViewUtils(
      userInjector.provideToken(APP_ID),
      EventManager(ngZone),
    );
    return userInjector;
  });

  if (isDevToolsEnabled) {
    Inspector.instance.inspect(applicationRef);
  }

  return injector;
}

/// An implementation of [Injector] that invokes closures.
///
/// ... right now this is a workaround for the ApplicationRef issue above.
@Immutable()
class _LazyInjector extends HierarchicalInjector {
  final Map<Object, Object Function()> _providers;

  const _LazyInjector(
    this._providers, [
    super.parent,
  ]);

  @override
  Object? injectFromSelfOptional(
    Object token, [
    Object? orElse = throwIfNotFound,
  ]) {
    var result = _providers[token];
    if (result == null) {
      if (identical(token, Injector)) {
        return this;
      }
      return orElse;
    }
    return result();
  }
}

Injector _identityInjector(Injector parent) => parent;

/// Starts a new AngularDart application with [componentFactory] as the root.
///
/// ```dart
/// // Assume this file is "main.dart".
/// import 'package:ngdart/angular.dart';
/// import 'main.template.dart' as ng;
///
/// @Component(
///   selector: 'hello-world',
///   template: '',
/// )
/// class HelloWorld {}
///
/// void main() {
///   runApp(ng.HelloWorldNgFactory);
/// }
/// ```
///
/// See [ComponentFactory] for documentation on how to find an instance of
/// a `ComponentFactory<T>` given a `class` [T] annotated with `@Component`. An
/// HTML tag matching the `selector` defined in [Component.selector] will be
/// upgraded to use AngularDart to manage that element (and its children). If
/// there is no matching element, a new tag will be appended to the `<body>`.
///
/// Optionally may supply a [createInjector] function in order to provide
/// services to the root of the application:
///
/// // Assume this file is "main.dart".
/// import 'package:ngdart/angular.dart';
/// import 'main.template.dart' as ng;
///
/// @Component(
///   selector: 'hello-world',
///   template: '',
/// )
/// class HelloWorld {
///   HelloWorld(HelloService service) {
///     service.sayHello();
///   }
/// }
///
/// class HelloService {
///   void sayHello() {
///     print('Hello World!');
///   }
/// }
///
/// void main() {
///   runApp(ng.HelloWorldNgFactory, createInjector: helloInjector);
/// }
///
/// @GenerateInjector(const [
///   const ClassProvider(HelloService),
/// ])
/// final InjectorFactory helloInjector = ng.helloInjector$Injector;
/// ```
///
/// See [InjectorFactory] for more examples.
///
/// Returns a [ComponentRef] with the created root component instance within the
/// context of a new [ApplicationRef], with change detection and other framework
/// internals setup.
ComponentRef<T> runApp<T extends Object>(
  ComponentFactory<T> componentFactory, {
  InjectorFactory createInjector = _identityInjector,
}) {
  final injector = appInjector(createInjector);
  final appRef = injector.provideType<ApplicationRef>(ApplicationRef);
  return appRef.bootstrap(componentFactory);
}

/// Asynchronous alternative to [runApp], supporting [beforeComponentCreated].
///
/// The provided callback ([beforeComponentCreated]) is invoked _before_
/// creating the root component, with a handle to the root injector. The user
/// must return a `Future` - it will be `await`-ed before creating the root
/// component.
///
/// See [runApp] for additional details.
Future<ComponentRef<T>> runAppAsync<T extends Object>(
  ComponentFactory<T> componentFactory, {
  required Future<void> Function(Injector) beforeComponentCreated,
  InjectorFactory createInjector = _identityInjector,
}) {
  final injector = appInjector(createInjector);
  final appRef = injector.provideType<ApplicationRef>(ApplicationRef);
  final ngZone = injector.provideType<NgZone>(NgZone);
  return ngZone.run(() {
    final future = beforeComponentCreated(injector);
    return future.then((_) => appRef.bootstrap(componentFactory));
  });
}
