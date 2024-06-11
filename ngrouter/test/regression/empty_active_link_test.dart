import 'package:ngdart/angular.dart';
import 'package:ngrouter/ngrouter.dart';
import 'package:ngrouter/testing.dart';
import 'package:ngtest/angular_test.dart';
import 'package:test/test.dart';

import 'empty_active_link_test.template.dart' as ng;

@GenerateInjector(routerProvidersTest)
final injector = ng.injector$Injector;

void main() {
  test('router link with empty path should be marked active', () async {
    final testBed = NgTestBed<AppComponent>(ng.createAppComponentFactory())
        .addInjector(injector);
    final testFixture = await testBed.create();
    final anchor = testFixture.rootElement.querySelector('a')!;
    expect(anchor.classList.contains(AppComponent.activeClassName), isTrue);
  });
}

@Component(
  selector: 'index',
  template: '',
)
class IndexComponent {}

@Component(
  selector: 'app',
  template: ''''
    <a [routerLink]="indexPath" [routerLinkActive]="activeClassName"></a>
    <router-outlet [routes]="routes"></router-outlet>
  ''',
  directives: [
    RouterLink,
    RouterLinkActive,
    RouterOutlet,
  ],
)
class AppComponent {
  static const activeClassName = 'active';
  static const indexPath = '/';
  static final routes = [
    RouteDefinition(
        path: indexPath, component: ng.createIndexComponentFactory()),
  ];
}
