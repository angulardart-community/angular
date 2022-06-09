import 'package:test/test.dart';
import 'package:ngdart/angular.dart';
import 'package:ngtest/angular_test.dart';

import 'component_class_selector_test.template.dart' as ng;

void main() {
  tearDown(disposeAnyRunningTest);

  group('component with class selector', () {
    test('should not mangle host element name', () async {
      final testBed = NgTestBed<ClassSelectorComponent>(
          ng.createClassSelectorComponentFactory());
      final testFixture = await testBed.create();
      expect(testFixture.rootElement.tagName, equalsIgnoringCase('foo'));
    });

    test('should only match element with that class', () async {
      final testBed = NgTestBed<MatchClassSelectorComponent>(
          ng.createMatchClassSelectorComponentFactory());
      final testFixture = await testBed.create();
      expect(testFixture.rootElement.querySelectorAll('foo'), hasLength(2));
      expect(testFixture.rootElement.querySelectorAll('foo.bar'), hasLength(1));
      expect(testFixture.assertOnlyInstance.components, hasLength(1));
    });
  });
}

@Component(
  selector: 'foo.bar',
  template: '',
)
class ClassSelectorComponent {}

@Component(
  selector: 'test',
  template: '''
    <foo @skipSchemaValidationFor="foo"></foo>
    <foo class="bar"></foo>
  ''',
  directives: [ClassSelectorComponent],
)
class MatchClassSelectorComponent {
  @ViewChildren(ClassSelectorComponent)
  List<ClassSelectorComponent>? components;
}
