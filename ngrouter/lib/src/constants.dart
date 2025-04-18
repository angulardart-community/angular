import 'package:ngdart/angular.dart';

import 'directives/router_link_active_directive.dart';
import 'directives/router_link_directive.dart';
import 'directives/router_outlet_directive.dart';
import 'location.dart';
import 'router/router.dart';
import 'router/router_impl.dart';

/// The main [Router] directives.
///
/// Attach to a @[Component]'s directives when using any other the Router
/// directives.
/// ```dart
/// @Component(
///   selector: 'my-app',
///   directives: const [routerDirectives]
///   template: '<router-outlet></router-outlet>'
/// )
/// class MyApp {}
/// ```
const routerDirectives = [RouterOutlet, RouterLink, RouterLinkActive];

/// The main [Router] providers.
///
/// The [routerProviders] should be added to the app's root injector.
/// ```dart
/// @GenerateInjector(const [
///   routerProviders,
/// ])
/// final InjectorFactory appInjector = ng.appInjector$Injector;
///
/// void main() {
///   runApp(ng.MyAppComponentNgFactory, createInjector: appInjector);
/// }
/// ```
const routerProviders = [
  ClassProvider(LocationStrategy, useClass: PathLocationStrategy),
  ClassProvider(PlatformLocation, useClass: BrowserPlatformLocation),
  ClassProvider(Location),
  ClassProvider(Router, useClass: RouterImpl)
];

/// The main [Router] DI module.
///
/// The [routerModule] should be added to the app's root injector.
/// ```dart
/// @GenerateInjector.fromModules(const [
///   routerModule
/// ])
/// final InjectorFactory appInjector = ng.appInjector$Injector;
///
/// void main() {
///   runApp(ng.MyAppComponentNgFactory, createInjector: appInjector);
/// }
/// ```
const routerModule = Module(provide: routerProviders);

/// The main [Router] providers when using hash routing.
///
/// The [routerProvidersHash] should be added to the app's root injector.
/// ```dart
/// @GenerateInjector(const [
///   routerProvidersHash
/// ])
/// final InjectorFactory appInjector = ng.appInjector$Injector;
///
/// void main() {
///   runApp(ng.MyAppComponentNgFactory, createInjector: appInjector);
/// }
/// ```
const routerProvidersHash = [
  ClassProvider(LocationStrategy, useClass: HashLocationStrategy),
  ClassProvider(PlatformLocation, useClass: BrowserPlatformLocation),
  ClassProvider(Location),
  ClassProvider(Router, useClass: RouterImpl)
];

/// The main [Router] DI module when using hash routing.
///
/// The [routerHashModule] should be added to the app's root injector.
/// ```dart
/// @GenerateInjector.fromModules(const [
///   routerHashModule
/// ])
/// final InjectorFactory appInjector = ng.appInjector$Injector;
///
/// void main() {
///   runApp(ng.MyAppComponentNgFactory, createInjector: appInjector);
/// }
/// ```
const routerHashModule = Module(provide: routerProvidersHash);
