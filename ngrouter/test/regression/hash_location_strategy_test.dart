import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ngdart/angular.dart';
import 'package:ngrouter/ngrouter.dart';
import 'package:ngtest/angular_test.dart';
import 'package:test/test.dart';
import 'package:web/web.dart';

@GenerateNiceMocks([MockSpec<BrowserPlatformLocation>()])
import 'hash_location_strategy_test.mocks.dart'; // ignore: uri_does_not_exist
import 'hash_location_strategy_test.template.dart' as ng;

// ignore: undefined_function
final platformLocation = MockBrowserPlatformLocation();

void main() {
  setUp(() {
    reset(platformLocation);
  });

  tearDown(disposeAnyRunningTest);

  test('browser location should match clicked href', () async {
    final testBed = NgTestBed<AppComponent>(ng.createAppComponentFactory(),
        rootInjector: injectorFactory);
    final testFixture = await testBed.create();
    expect(
        testFixture.assertOnlyInstance.anchor!.getAttribute('href'), '#/foo');
    await testFixture.update((c) {
      c.anchor!.click();
    });
    verify(platformLocation.pushState(any, any, '#/foo')).called(1);
  });
}

PlatformLocation platformLocationFactory() => platformLocation;

@GenerateInjector([
  routerProvidersHash,
  FactoryProvider(PlatformLocation, platformLocationFactory),
])
InjectorFactory injectorFactory = ng.injectorFactory$Injector;

@Component(
  selector: 'app',
  template: '''
    <a #routerLink [routerLink]="fooRoute.toUrl()"></a>
    <router-outlet [routes]="routes"></router-outlet>
  ''',
  directives: [RouterLink, RouterOutlet],
)
class AppComponent {
  static final fooRoute = RouteDefinition(
    path: '/foo',
    component: ng.createFooComponentFactory(),
  );
  static final routes = [fooRoute];

  @ViewChild('routerLink')
  HtmlElement? anchor;
}

@Component(selector: 'foo', template: '')
class FooComponent {}
