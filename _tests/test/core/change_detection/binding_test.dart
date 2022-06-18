import 'package:test/test.dart';
import 'package:ngdart/angular.dart';
import 'package:ngtest/angular_test.dart';

import 'binding_test.template.dart' as ng;

void main() {
  tearDown(disposeAnyRunningTest);

  test('should support literals', () async {
    await _GetValue<TestLiterals>(ng.createTestLiteralsFactory()).runTest();
  });

  test('should strip quotes from literals', () async {
    await _GetValue<TestStripQuotes>(ng.createTestStripQuotesFactory())
        .runTest();
  });

  test('should support newlines in literals', () async {
    await _GetValue<TestNewLines>(ng.createTestNewLinesFactory()).runTest();
  });

  test('should support + operations', () async {
    await _GetValue<TestAddOperation>(ng.createTestAddOperationFactory())
        .runTest();
  });

  test('should support - operations', () async {
    await _GetValue<TestMinusOperation>(ng.createTestMinusOperationFactory())
        .runTest();
  });

  test('should support * operations', () async {
    await _GetValue<TestMultiplyOperation>(
            ng.createTestMultiplyOperationFactory())
        .runTest();
  });

  test('should support / operations', () async {
    await _GetValue<TestMultiplyOperation>(
            ng.createTestMultiplyOperationFactory())
        .runTest();
  });

  test('should support % operations', () async {
    await _GetValue<TestModulusOperation>(
            ng.createTestModulusOperationFactory())
        .runTest();
  });

  test('should support == operations', () async {
    await _GetValue<TestEqualityOperation>(
            ng.createTestEqualityOperationFactory())
        .runTest();
  });

  test('should support != operations', () async {
    await _GetValue<TestNotEqualsOperation>(
            ng.createTestNotEqualsOperationFactory())
        .runTest();
  });

  test('should support === operations', () async {
    await _GetValue<TestIdentityOperation>(
            ng.createTestIdentityOperationFactory())
        .runTest();
  });

  test('should support !== operations', () async {
    await _GetValue<TestNotIdenticalOperation>(
            ng.createTestNotIdenticalOperationFactory())
        .runTest();
  });

  test('should support > operations', () async {
    await _GetValue<TestGreaterThanOperation>(
            ng.createTestGreaterThanOperationFactory())
        .runTest();
  });

  test('should support < operations', () async {
    await _GetValue<TestLessThanOperation>(
            ng.createTestLessThanOperationFactory())
        .runTest();
  });

  test('should support >= operations', () async {
    await _GetValue<TestGreaterThanOrEqualsOperation>(
      ng.createTestGreaterThanOrEqualsOperationFactory(),
    ).runTest();
  });

  test('should support <= operations', () async {
    await _GetValue<TestLessThanOrEqualsOperation>(
            ng.createTestLessThanOrEqualsOperationFactory())
        .runTest();
  });

  test('should support && operations', () async {
    await _GetValue<TestAndOperation>(ng.createTestAndOperationFactory())
        .runTest();
  });

  test('should support || operations', () async {
    await _GetValue<TestOrOperation>(ng.createTestOrOperationFactory())
        .runTest();
  });

  test('should support ternary operations', () async {
    await _GetValue<TestTernaryOperation>(
            ng.createTestTernaryOperationFactory())
        .runTest();
  });

  test('should support ! operations', () async {
    await _GetValue<TestNegateOperation>(ng.createTestNegateOperationFactory())
        .runTest();
  });

  test('should support !! operations', () async {
    await _GetValue<TestDoubleNegationOperation>(
            ng.createTestDoubleNegationOperationFactory())
        .runTest();
  });

  test('should support keyed access to a map', () async {
    await _GetValue<TestMapAccess>(ng.createTestMapAccessFactory()).runTest();
  });

  test('should support keyed access to a list', () async {
    await _GetValue<TestListAccess>(ng.createTestListAccessFactory()).runTest();
  });

  test('should support property access', () async {
    await _GetValue<TestPropertyAccess>(ng.createTestPropertyAccessFactory())
        .runTest();
  });

  test('should support chained property access', () async {
    await _GetValue<TestChainedPropertyAccess>(
            ng.createTestChainedPropertyAccessFactory())
        .runTest();
  });

  test('should support a function call', () async {
    await _GetValue<TestFunctionCall>(ng.createTestFunctionCallFactory())
        .runTest();
  });

  test('should support assigning explicitly to null', () async {
    await _GetValue<TestAssignNull>(ng.createTestAssignNullFactory()).runTest();
  });

  test('should support assigning explicitly to null', () async {
    await _GetValue<TestElvisOperation>(ng.createTestElvisOperationFactory())
        .runTest();
  });

  test('should support assigning explicitly to null', () async {
    await _GetValue<TestNullAwareOperation>(
            ng.createTestNullAwareOperationFactory())
        .runTest();
  });
}

/// A helper for asserting against a new component that implements [ValueTest].
class _GetValue<T extends ValueTest> {
  final ComponentFactory<T> _factory;

  const _GetValue(this._factory);

  Future<void> runTest() async {
    final fixture = await NgTestBed(_factory).create();
    await fixture.update(expectAsync1((ValueTest comp) {
      expect(comp.child!.value, comp.expected);
    }));
  }
}

@Component(
  selector: 'child',
  template: r'{{value}}',
)
class ChildComponent {
  @Input()
  dynamic value;
}

abstract class ValueTest {
  ChildComponent? get child;

  dynamic get expected;
}

@Component(
  selector: 'test',
  directives: [ChildComponent],
  template: r'<child [value]="10"></child>',
)
class TestLiterals implements ValueTest {
  @ViewChild(ChildComponent)
  @override
  ChildComponent? child;

  @override
  int get expected => 10;
}

@Component(
  selector: 'test',
  directives: [ChildComponent],
  template: r'''<child [value]="'string'"></child>''',
)
class TestStripQuotes implements ValueTest {
  @ViewChild(ChildComponent)
  @override
  ChildComponent? child;

  @override
  String get expected => 'string';
}

@Component(
  selector: 'test',
  directives: [ChildComponent],
  template: '''<child [value]="value"></child>''',
)
class TestNewLines implements ValueTest {
  @ViewChild(ChildComponent)
  @override
  ChildComponent? child;

  @override
  String get expected => 'a\n\nb';

  // TODO(b/136199519): Move the value back inline in the template.
  var value = 'a\n\nb';
}

@Component(
  selector: 'test',
  directives: [ChildComponent],
  template: '<child [value]="10 + 2"></child>',
)
class TestAddOperation implements ValueTest {
  @ViewChild(ChildComponent)
  @override
  ChildComponent? child;

  @override
  int get expected => 12;
}

@Component(
  selector: 'test',
  directives: [ChildComponent],
  template: '<child [value]="10 - 2"></child>',
)
class TestMinusOperation implements ValueTest {
  @ViewChild(ChildComponent)
  @override
  ChildComponent? child;

  @override
  int get expected => 8;
}

@Component(
  selector: 'test',
  directives: [ChildComponent],
  template: '<child [value]="10 * 2"></child>',
)
class TestMultiplyOperation implements ValueTest {
  @ViewChild(ChildComponent)
  @override
  ChildComponent? child;

  @override
  int get expected => 20;
}

@Component(
  selector: 'test',
  directives: [ChildComponent],
  template: '<child [value]="10 / 2"></child>',
)
class TestDivisionOperation implements ValueTest {
  @ViewChild(ChildComponent)
  @override
  ChildComponent? child;

  @override
  int get expected => 5;
}

@Component(
  selector: 'test',
  directives: [ChildComponent],
  template: '<child [value]="11 % 2"></child>',
)
class TestModulusOperation implements ValueTest {
  @ViewChild(ChildComponent)
  @override
  ChildComponent? child;

  @override
  int get expected => 1;
}

@Component(
  selector: 'test',
  directives: [ChildComponent],
  template: '<child [value]="1 == 1"></child>',
)
class TestEqualityOperation implements ValueTest {
  @ViewChild(ChildComponent)
  @override
  ChildComponent? child;

  @override
  bool get expected => true;
}

@Component(
  selector: 'test',
  directives: [ChildComponent],
  template: '<child [value]="1 != 1"></child>',
)
class TestNotEqualsOperation implements ValueTest {
  @ViewChild(ChildComponent)
  @override
  ChildComponent? child;

  @override
  Matcher get expected => isFalse;
}

@Component(
  selector: 'test',
  directives: [ChildComponent],
  template: '<child [value]="identical(1, 1)"></child>',
  exports: [identical],
)
class TestIdentityOperation implements ValueTest {
  @ViewChild(ChildComponent)
  @override
  ChildComponent? child;

  @override
  bool get expected => true;
}

@Component(
  selector: 'test',
  directives: [ChildComponent],
  template: '<child [value]="!identical(1, 1)"></child>',
  exports: [identical],
)
class TestNotIdenticalOperation implements ValueTest {
  @ViewChild(ChildComponent)
  @override
  ChildComponent? child;

  @override
  Matcher get expected => isFalse;
}

@Component(
  selector: 'test',
  directives: [ChildComponent],
  template: '<child [value]="1 < 2"></child>',
)
class TestLessThanOperation implements ValueTest {
  @ViewChild(ChildComponent)
  @override
  ChildComponent? child;

  @override
  bool get expected => true;
}

@Component(
  selector: 'test',
  directives: [ChildComponent],
  template: '<child [value]="2 > 1"></child>',
)
class TestGreaterThanOperation implements ValueTest {
  @ViewChild(ChildComponent)
  @override
  ChildComponent? child;

  @override
  bool get expected => true;
}

@Component(
  selector: 'test',
  directives: [ChildComponent],
  template: '<child [value]="1 <= 2"></child>',
)
class TestLessThanOrEqualsOperation implements ValueTest {
  @ViewChild(ChildComponent)
  @override
  ChildComponent? child;

  @override
  bool get expected => true;
}

@Component(
  selector: 'test',
  directives: [ChildComponent],
  template: '<child [value]="2 >= 1"></child>',
)
class TestGreaterThanOrEqualsOperation implements ValueTest {
  @ViewChild(ChildComponent)
  @override
  ChildComponent? child;

  @override
  bool get expected => true;
}

@Component(
  selector: 'test',
  directives: [ChildComponent],
  template: '<child [value]="true && false"></child>',
)
class TestAndOperation implements ValueTest {
  @ViewChild(ChildComponent)
  @override
  ChildComponent? child;

  @override
  Matcher get expected => isFalse;
}

@Component(
  selector: 'test',
  directives: [ChildComponent],
  template: '<child [value]="val1 || val2"></child>',
)
class TestOrOperation implements ValueTest {
  @ViewChild(ChildComponent)
  @override
  ChildComponent? child;

  // Can't inline; we'd get a dead code warning in .template.dart.
  bool get val1 => true;
  bool get val2 => false;

  @override
  bool get expected => true;
}

@Component(
  selector: 'test',
  directives: [ChildComponent],
  template: '<child [value]="!true"></child>',
)
class TestNegateOperation implements ValueTest {
  @ViewChild(ChildComponent)
  @override
  ChildComponent? child;

  @override
  Matcher get expected => isFalse;
}

@Component(
  selector: 'test',
  directives: [ChildComponent],
  template: '<child [value]="!!true"></child>',
)
class TestDoubleNegationOperation implements ValueTest {
  @ViewChild(ChildComponent)
  @override
  ChildComponent? child;

  @override
  bool get expected => true;
}

@Component(
  selector: 'test',
  directives: [ChildComponent],
  template: r'''<child [value]="1 > 2 ? 'yes' : 'no'"></child>''',
)
class TestTernaryOperation implements ValueTest {
  @ViewChild(ChildComponent)
  @override
  ChildComponent? child;

  @override
  String get expected => 'no';
}

@Component(
  selector: 'test',
  directives: [ChildComponent],
  template: r'''<child [value]="map['foo']"></child>''',
)
class TestMapAccess implements ValueTest {
  @ViewChild(ChildComponent)
  @override
  ChildComponent? child;

  Map<String, String> get map => const {'foo': 'bar'};

  @override
  String get expected => 'bar';
}

@Component(
  selector: 'test',
  directives: [ChildComponent],
  template: r'''<child [value]="list[1]"></child>''',
)
class TestListAccess implements ValueTest {
  @ViewChild(ChildComponent)
  @override
  ChildComponent? child;

  List<String> get list => const ['foo', 'bar'];

  @override
  String get expected => 'bar';
}

@Component(
  selector: 'test',
  directives: [ChildComponent],
  template: r'''<child [value]="list.length"></child>''',
)
class TestPropertyAccess implements ValueTest {
  @ViewChild(ChildComponent)
  @override
  ChildComponent? child;

  List<String> get list => const ['foo', 'bar'];

  @override
  int get expected => 2;
}

@Component(
  selector: 'test',
  directives: [ChildComponent],
  template: r'''<child [value]="list.length.isEven"></child>''',
)
class TestChainedPropertyAccess implements ValueTest {
  @ViewChild(ChildComponent)
  @override
  ChildComponent? child;

  List<String> get list => const ['foo', 'bar'];

  @override
  bool get expected => true;
}

@Component(
  selector: 'test',
  directives: [ChildComponent],
  template: r'''<child [value]="list.toList().length.isEven"></child>''',
)
class TestFunctionCall implements ValueTest {
  @ViewChild(ChildComponent)
  @override
  ChildComponent? child;

  List<String> get list => const ['foo', 'bar'];

  @override
  bool get expected => true;
}

@Component(
  selector: 'test',
  directives: [ChildComponent],
  template: r'''<child [value]="null"></child>''',
)
class TestAssignNull implements ValueTest {
  @ViewChild(ChildComponent)
  @override
  ChildComponent? child;

  @override
  Matcher get expected => isNull;
}

@Component(
  selector: 'test',
  directives: [ChildComponent],
  template: r'''<child [value]="map?.keys"></child>''',
)
class TestElvisOperation implements ValueTest {
  @ViewChild(ChildComponent)
  @override
  ChildComponent? child;

  dynamic get map => null;

  @override
  Matcher get expected => isNull;
}

@Component(
  selector: 'test',
  directives: [ChildComponent],
  template: r'''<child [value]="map?.keys ?? 'Hello'"></child>''',
)
class TestNullAwareOperation implements ValueTest {
  @ViewChild(ChildComponent)
  @override
  ChildComponent? child;

  dynamic get map => null;

  @override
  String get expected => 'Hello';
}
