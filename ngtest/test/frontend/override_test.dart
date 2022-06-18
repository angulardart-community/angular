import 'package:test/test.dart';
import 'package:ngdart/angular.dart';
import 'package:ngtest/angular_test.dart';

import 'override_test.template.dart' as ng;

void main() {
  tearDown(disposeAnyRunningTest);

  test('should support overriding providers', () async {
    final fixture =
        await NgTestBed<TestViewComponent>(ng.createTestViewComponentFactory())
            .create();
    expect(fixture.text, 'Hello World');
  });
}

@Component(
  selector: 'view-comp',
  providers: [DataService],
  template: '{{value}}',
)
class ViewComponent implements OnInit {
  final DataService _service;

  String? value;

  ViewComponent(this._service);

  @override
  Future<String> ngOnInit() async => value = await _service.fetch();
}

@Component(
  selector: 'test-view-comp',
  directives: [
    OverrideDirective,
    ViewComponent,
  ],
  template: '<view-comp override></view-comp>',
)
class TestViewComponent {}

@Directive(
  selector: '[override]',
  providers: [
    Provider(DataService, useClass: FakeDataService),
  ],
)
class OverrideDirective {}

@Injectable()
class DataService {
  Future<String> fetch() => throw UnimplementedError();
}

@Injectable()
class FakeDataService implements DataService {
  @override
  Future<String> fetch() async => 'Hello World';
}
