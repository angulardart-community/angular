import 'package:ngdart/angular.dart';
import 'package:ngrouter/ngrouter.dart';
import 'package:ngtest/angular_test.dart';
import 'package:test/test.dart';
import 'package:web/web.dart' show WindowEventGetters, window;

import 'revert_popstate_test.template.dart' as ng;

void main() {
  late Location location;
  late NgTestFixture<TestComponent> testFixture;
  late Router router;
  late TestRouterHook routerHook;

  setUp(() async {
    routerHook = TestRouterHook();
    final testBed = NgTestBed<TestComponent>(
      ng.createTestComponentFactory(),
      rootInjector: (parent) {
        return createInjector(Injector.map({RouterHook: routerHook}, parent));
      },
    );
    testFixture = await testBed.create(beforeComponentCreated: (injector) {
      location = injector.provideType(Location)..replaceState('/a');
      router = injector.provideType(Router);
    });
  });

  tearDown(disposeAnyRunningTest);

  // When a navigation triggered by a popstate event is prevented, updating the
  // browser location to match the active route should preserve the previous
  // browser history (rather than overwriting it).
  test('preventing back should preserve previous history', () async {
    // Navigate from /a -> /b.
    var result = await router.navigate('/b');
    expect(result, NavigationResult.success);

    // Navigate from /b -> /c.
    result = await router.navigate('/c');
    expect(result, NavigationResult.success);

    // The `popstate` event triggered by `History.back()` is not guaranteed to
    // occur before the future returned by `NgTestFixture.update()` has
    // resolved. In order to be sure we're testing the correct state, we listen
    // for the next `popstate` event and use a completer to signal that it has
    // occured.
    var nextPopState = window.onPopState.first;
    // Prevent navigation on back button.
    await testFixture.update((_) {
      routerHook.canLeave = false;
      location.back();
    });
    // In rare cases, not waiting for this `popstate` event causes the
    // subsequent code to execute first.
    await nextPopState;

    // Location should not have changed.
    expect(location.path(), '/c');

    nextPopState = window.onPopState.first;
    // Allow navigation on back button.
    await testFixture.update((_) {
      routerHook.canLeave = true;
      location.back();
    });
    await nextPopState;

    // Location should now be the correct previous history location.
    expect(location.path(), '/b');
  });
}

const testModule = Module(
  include: [routerModule],
  provide: [ValueProvider.forToken(appBaseHref, '/')],
);

@GenerateInjector.fromModules([testModule])
final InjectorFactory createInjector = ng.createInjector$Injector;

@Component(
  selector: 'test',
  directives: [RouterOutlet],
  template: '''
    <router-outlet [routes]="routes"></router-outlet>
  ''',
)
class TestComponent {
  final routes = [
    RouteDefinition(
      path: '/a',
      component: ng.createRouteComponentFactory(),
    ),
    RouteDefinition(
      path: '/b',
      component: ng.createRouteComponentFactory(),
    ),
    RouteDefinition(
      path: '/c',
      component: ng.createRouteComponentFactory(),
    ),
  ];
}

@Component(
  selector: 'route',
  template: '',
)
class RouteComponent {}

class TestRouterHook extends RouterHook {
  var canLeave = true;

  @override
  Future<bool> canDeactivate(_, __, ___) => Future.value(canLeave);
}
