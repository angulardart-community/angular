import 'package:ngdart/angular.dart';
import 'package:ngtest/angular_test.dart';
import 'package:test/test.dart';
import 'package:web/web.dart';

import 'implicit_static_test.template.dart' as ng;

void main() {
  tearDown(disposeAnyRunningTest);

  test('should support implicit static field', () async {
    final testBed =
        NgTestBed<TestStaticField>(ng.createTestStaticFieldFactory());
    final testFixture = await testBed.create();
    expect(testFixture.text, TestStaticField.field);
  });

  test('should support implicit static getter', () async {
    final testBed =
        NgTestBed<TestStaticGetter>(ng.createTestStaticGetterFactory());
    final testFixture = await testBed.create();
    expect(testFixture.text, TestStaticGetter.getter);
  });

  test('should support implicit static method', () async {
    final testBed =
        NgTestBed<TestStaticMethod>(ng.createTestStaticMethodFactory());
    final testFixture = await testBed.create();
    expect(testFixture.text, TestStaticMethod.method());
  });

  test('should support implicit static setter', () async {
    final testBed =
        NgTestBed<TestStaticSetter>(ng.createTestStaticSetterFactory());
    final testFixture = await testBed.create();
    expect(testFixture.text, isEmpty);
    await testFixture.update((_) {
      testFixture.rootElement.firstChild!.dispatchEvent(CustomEvent('set'));
    });
    expect(testFixture.text, TestStaticSetter.valueToSet);
  });

  test('should support calling an implicit static field', () async {
    final testBed = NgTestBed<TestCallingStaticField>(
        ng.createTestCallingStaticFieldFactory());
    final testFixture = await testBed.create();
    expect(testFixture.text, TestCallingStaticField.field());
  });

  test('should support binding an implicit static tear-off', () async {
    final testBed =
        NgTestBed<TestStaticTearOff>(ng.createTestStaticTearOffFactory());
    final testFixture = await testBed.create();
    expect(testFixture.text, TestStaticTearOff.method());
  });
}

@Component(
  selector: 'test',
  template: '{{field}}',
)
class TestStaticField {
  static String field = 'static field';
}

@Component(
  selector: 'test',
  template: '{{getter}}',
)
class TestStaticGetter {
  static String get getter => 'static getter';
}

@Component(
  selector: 'test',
  template: '{{method()}}',
)
class TestStaticMethod {
  static String method() => 'static method';
}

@Component(
  selector: 'test',
  template: '''
    <div @skipSchemaValidationFor="[set]" (set)="setter = valueToSet">
      {{setValue}}
    </div>
  ''',
)
class TestStaticSetter {
  static String valueToSet = 'static setter';
  static String? setValue;

  static set setter(String value) {
    setValue = value;
  }
}

@Component(
  selector: 'test',
  template: '{{field()}}',
)
class TestCallingStaticField {
  // ignore: prefer_function_declarations_over_variables
  static String Function() field = () => 'static closure';
}

@Directive(selector: '[invoke]')
class InvokeTearOff {
  final Element _host;

  InvokeTearOff(this._host);

  @Input()
  set invoke(String Function() value) {
    _host.textContent = value();
  }
}

@Component(
  selector: 'test',
  template: '<div [invoke]="method"></div>',
  directives: [InvokeTearOff],
)
class TestStaticTearOff {
  static String method() => 'static tear-off';
}
