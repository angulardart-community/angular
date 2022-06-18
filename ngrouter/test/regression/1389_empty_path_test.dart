import 'package:test/test.dart';
import 'package:ngdart/angular.dart';
import 'package:ngrouter/angular_router.dart';
import 'package:ngrouter/testing.dart';
import 'package:ngtest/angular_test.dart';

// ignore: uri_has_not_been_generated
import '1389_empty_path_test.template.dart' as ng;

void main() {
  tearDown(disposeAnyRunningTest);

  test('navigation to empty path should fail', () async {
    final testBed = NgTestBed<TestComponent>(ng.createTestComponentFactory());
    final testFixture = await testBed.create();
    final router = testFixture.assertOnlyInstance.router;
    final result = await router.navigate('/');
    expect(result, NavigationResult.INVALID_ROUTE);
  });
}

@Component(
  selector: 'test',
  template: '',
  providers: routerProvidersTest,
)
class TestComponent {
  final Router router;

  TestComponent(this.router);
}
