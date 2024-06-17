import 'package:ngdart/angular.dart';
import 'package:ngtest/angular_test.dart';
import 'package:test/test.dart';
import 'package:web/web.dart';

import 'ng_class_test.template.dart' as ng;

void main() {
  tearDown(disposeAnyRunningTest);

  group('ngClass', () {
    test('should clean up when the directive is destroyed', () async {
      var testBed =
          NgTestBed<DestroyClassTest>(ng.createDestroyClassTestFactory());
      var testFixture = await testBed.create();
      await testFixture.update((DestroyClassTest component) {
        component.items = [
          ['0']
        ];
      });
      await testFixture.update((DestroyClassTest component) {
        component.items = [
          ['1']
        ];
      });
      expect(
        testFixture.rootElement.querySelector('div')!.classList.asIterable(),
        equals(['1']),
      );
    });

    test('should add classes specified in map without change in class names',
        () async {
      var testBed = NgTestBed<ClassWithNames>(ng.createClassWithNamesFactory());
      var testFixture = await testBed.create();
      expect(
        testFixture.rootElement.querySelector('div')!.classList.asIterable(),
        equals(['foo-bar', 'fooBar']),
      );
    });

    test('should update classes based on changes in map values', () async {
      var testBed =
          NgTestBed<ConditionMapTest>(ng.createConditionMapTestFactory());
      var testFixture = await testBed.create();
      var content = testFixture.rootElement.querySelector('div')!;
      expect(content.classList.asIterable(), equals(['foo']));
      await testFixture.update((ConditionMapTest component) {
        component.condition = false;
      });
      expect(content.classList.asIterable(), equals(['bar']));
    });

    test('should update classes based on changes to the map', () async {
      var testBed = NgTestBed<MapUpdateTest>(ng.createMapUpdateTestFactory());
      var testFixture = await testBed.create();
      var content = testFixture.rootElement.querySelector('div')!;
      expect(content.classList.asIterable(), equals(['foo']));
      await testFixture.update((MapUpdateTest component) {
        component.map!['bar'] = true;
      });
      expect(content.classList.asIterable(), equals(['foo', 'bar']));
      await testFixture.update((MapUpdateTest component) {
        component.map!['baz'] = true;
      });
      expect(content.classList.asIterable(), equals(['foo', 'bar', 'baz']));
      await testFixture.update((MapUpdateTest component) {
        component.map!.remove('bar');
      });
      expect(content.classList.asIterable(), equals(['foo', 'baz']));
    });

    test('should update classes based on reference changes to the map',
        () async {
      var testBed = NgTestBed<MapUpdateTest>(ng.createMapUpdateTestFactory());
      var testFixture = await testBed.create();
      var content = testFixture.rootElement.querySelector('div')!;
      expect(content.classList.asIterable(), equals(['foo']));
      await testFixture.update((MapUpdateTest component) {
        component.map = <String, bool>{'foo': true, 'bar': true};
      });
      expect(content.classList.asIterable(), equals(['foo', 'bar']));
      await testFixture.update((MapUpdateTest component) {
        component.map = <String, bool>{'baz': true};
      });
      expect(content.classList.asIterable(), equals(['baz']));
    });

    test('should remove classes when expression is null', () async {
      var testBed = NgTestBed<MapUpdateTest>(ng.createMapUpdateTestFactory());
      var testFixture = await testBed.create();
      var content = testFixture.rootElement.querySelector('div')!;
      expect(content.classList.asIterable(), equals(['foo']));
      await testFixture.update((MapUpdateTest component) {
        component.map = null;
      });
      expect(content.classList.asIterable(), isEmpty);
      await testFixture.update((MapUpdateTest component) {
        component.map = <String, bool>{'foo': false, 'bar': true};
      });
      expect(content.classList.asIterable(), equals(['bar']));
    });

    test('should allow multiple classes per expression', () async {
      var testBed = NgTestBed<MapUpdateTest>(ng.createMapUpdateTestFactory());
      var testFixture = await testBed.create();
      var content = testFixture.rootElement.querySelector('div')!;
      await testFixture.update((MapUpdateTest component) {
        component.map = <String, bool>{'bar baz': true, 'bar1 baz1': true};
      });
      expect(content.classList.asIterable(),
          equals(['bar', 'baz', 'bar1', 'baz1']));
      await testFixture.update((MapUpdateTest component) {
        component.map = <String, bool>{'bar baz': false, 'bar1 baz1': true};
      });
      expect(content.classList.asIterable(), equals(['bar1', 'baz1']));
    });

    test('should split by one or more spaces between classes', () async {
      var testBed = NgTestBed<MapUpdateTest>(ng.createMapUpdateTestFactory());
      var testFixture = await testBed.create();
      var content = testFixture.rootElement.querySelector('div')!;
      await testFixture.update((MapUpdateTest component) {
        component.map = <String, bool>{'foo bar     baz': true};
      });
      expect(content.classList.asIterable(), equals(['foo', 'bar', 'baz']));
    });

    test('should update classes based on changes to the list', () async {
      var testBed = NgTestBed<ListUpdateTest>(ng.createListUpdateTestFactory());
      var testFixture = await testBed.create();
      var content = testFixture.rootElement.querySelector('div')!;
      expect(content.classList.asIterable(), equals(['foo']));
      await testFixture.update((ListUpdateTest component) {
        component.list.add('bar');
      });
      expect(content.classList.asIterable(), equals(['foo', 'bar']));
      await testFixture.update((ListUpdateTest component) {
        component.list[1] = 'baz';
      });
      expect(content.classList.asIterable(), equals(['foo', 'baz']));
      await testFixture.update((ListUpdateTest component) {
        component.list.remove('baz');
      });
      expect(content.classList.asIterable(), equals(['foo']));
    });

    test('should update classes when list reference changes', () async {
      var testBed = NgTestBed<ListUpdateTest>(ng.createListUpdateTestFactory());
      var testFixture = await testBed.create();
      var content = testFixture.rootElement.querySelector('div')!;
      expect(content.classList.asIterable(), equals(['foo']));
      await testFixture.update((ListUpdateTest component) {
        component.list = ['bar'];
      });
      expect(content.classList.asIterable(), equals(['bar']));
    });

    test('should take initial classes into account when a reference changes',
        () async {
      var testBed = NgTestBed<ListUpdateWithInitialTest>(
          ng.createListUpdateWithInitialTestFactory());
      var testFixture = await testBed.create();
      var content = testFixture.rootElement.querySelector('div')!;
      expect(content.classList.asIterable(), equals(['foo']));
      await testFixture.update((ListUpdateWithInitialTest component) {
        component.list = ['bar'];
      });
      expect(content.classList.asIterable(), equals(['foo', 'bar']));
    });

    test('should ignore empty or blank class names', () async {
      var testBed = NgTestBed<ListUpdateWithInitialTest>(
          ng.createListUpdateWithInitialTestFactory());
      var testFixture = await testBed.create();
      var content = testFixture.rootElement.querySelector('div')!;
      await testFixture.update((ListUpdateWithInitialTest component) {
        component.list = ['', '  '];
      });
      expect(content.classList.asIterable(), equals(['foo']));
    });

    test('should trim blanks from class names', () async {
      var testBed = NgTestBed<ListUpdateWithInitialTest>(
          ng.createListUpdateWithInitialTestFactory());
      var testFixture = await testBed.create();
      var content = testFixture.rootElement.querySelector('div')!;
      await testFixture.update((ListUpdateWithInitialTest component) {
        component.list = [' bar  '];
      });
      expect(content.classList.asIterable(), equals(['foo', 'bar']));
    });

    test('should allow multiple classes per item in lists', () async {
      var testBed = NgTestBed<ListUpdateTest>(ng.createListUpdateTestFactory());
      var testFixture = await testBed.create();
      var content = testFixture.rootElement.querySelector('div')!;
      await testFixture.update((ListUpdateTest component) {
        component.list = ['foo bar baz', 'foo1 bar1   baz1'];
      });
      expect(content.classList.asIterable(),
          equals(['foo', 'bar', 'baz', 'foo1', 'bar1', 'baz1']));
      await testFixture.update((ListUpdateTest component) {
        component.list = ['foo bar   baz foobar'];
      });
      expect(content.classList.asIterable(),
          equals(['foo', 'bar', 'baz', 'foobar']));
    });

    test('should update classes if the set instance changes', () async {
      var testBed = NgTestBed<SetUpdateTest>(ng.createSetUpdateTestFactory());
      var testFixture = await testBed.create();
      var content = testFixture.rootElement.querySelector('div')!;
      var set = <String>{};
      set.add('bar');
      await testFixture.update((SetUpdateTest component) {
        component.set = set;
      });
      expect(content.classList.asIterable(), equals(['bar']));
      set = <String>{};
      set.add('baz');
      await testFixture.update((SetUpdateTest component) {
        component.set = set;
      });
      expect(content.classList.asIterable(), equals(['baz']));
    });

    test('should add classes specified in a string literal', () async {
      var testBed =
          NgTestBed<StringLiteralTest>(ng.createStringLiteralTestFactory());
      var testFixture = await testBed.create();
      var content = testFixture.rootElement.querySelector('div')!;
      expect(content.classList.asIterable(),
          equals(['foo', 'bar', 'foo-bar', 'fooBar']));
    });

    test('should update classes based on changes to the string', () async {
      var testBed =
          NgTestBed<StringUpdateTest>(ng.createStringUpdateTestFactory());
      var testFixture = await testBed.create();
      var content = testFixture.rootElement.querySelector('div')!;
      expect(content.classList.asIterable(), equals(['foo']));
      await testFixture.update((StringUpdateTest component) {
        component.string = 'foo bar';
      });
      expect(content.classList.asIterable(), equals(['foo', 'bar']));
      await testFixture.update((StringUpdateTest component) {
        component.string = 'baz';
      });
      expect(content.classList.asIterable(), equals(['baz']));
    });

    test('should remove active classes when switching from string to null',
        () async {
      var testBed =
          NgTestBed<StringUpdateTest>(ng.createStringUpdateTestFactory());
      var testFixture = await testBed.create();
      var content = testFixture.rootElement.querySelector('div')!;
      expect(content.classList.asIterable(), equals(['foo']));
      await testFixture.update((StringUpdateTest component) {
        component.string = null;
      });
      expect(content.classList.asIterable(), isEmpty);
    });

    test(
        'should take initial classes into account when '
        'switching from string to null', () async {
      var testBed = NgTestBed<StringUpdateWithInitialTest>(
          ng.createStringUpdateWithInitialTestFactory());
      var testFixture = await testBed.create();
      var content = testFixture.rootElement.querySelector('div')!;
      expect(content.classList.asIterable(), equals(['foo']));
      await testFixture.update((StringUpdateWithInitialTest component) {
        component.string = null;
      });
      expect(content.classList.asIterable(), equals(['foo']));
    });

    test('should ignore empty and blank strings', () async {
      var testBed = NgTestBed<StringUpdateWithInitialTest>(
          ng.createStringUpdateWithInitialTestFactory());
      var testFixture = await testBed.create();
      var content = testFixture.rootElement.querySelector('div')!;
      await testFixture.update((StringUpdateWithInitialTest component) {
        component.string = '';
      });
      expect(content.classList.asIterable(), equals(['foo']));
    });

    test('should cooperate with the class attribute', () async {
      var testBed = NgTestBed<MapUpdateWithInitialTest>(
          ng.createMapUpdateWithInitialTestFactory());
      var testFixture = await testBed.create();
      var content = testFixture.rootElement.querySelector('div')!;
      await testFixture.update((MapUpdateWithInitialTest component) {
        component.map!['bar'] = true;
      });
      expect(content.classList.asIterable(), equals(['init', 'foo', 'bar']));
      await testFixture.update((MapUpdateWithInitialTest component) {
        component.map!['foo'] = false;
      });
      expect(content.classList.asIterable(), equals(['init', 'bar']));
      await testFixture.update((MapUpdateWithInitialTest component) {
        component.map = null;
      });
      expect(content.classList.asIterable(), equals(['init', 'foo']));
    });

    test('should cooperate with interpolated class attribute', () async {
      var testBed = NgTestBed<MapUpdateWithInitialInterpolationTest>(
          ng.createMapUpdateWithInitialInterpolationTestFactory());
      var testFixture = await testBed.create();
      var content = testFixture.rootElement.querySelector('div')!;
      await testFixture
          .update((MapUpdateWithInitialInterpolationTest component) {
        component.map!['bar'] = true;
      });
      expect(content.classList.asIterable(), equals(['init', 'foo', 'bar']));
      await testFixture
          .update((MapUpdateWithInitialInterpolationTest component) {
        component.map!['foo'] = false;
      });
      expect(content.classList.asIterable(), equals(['init', 'bar']));
      await testFixture
          .update((MapUpdateWithInitialInterpolationTest component) {
        component.map = null;
      });
      expect(content.classList.asIterable(), equals(['init', 'foo']));
    });

    test('should cooperate with class attribute and binding to it', () async {
      var testBed = NgTestBed<MapUpdateWithInitialBindingTest>(
          ng.createMapUpdateWithInitialBindingTestFactory());
      var testFixture = await testBed.create();
      var content = testFixture.rootElement.querySelector('div')!;
      await testFixture.update((MapUpdateWithInitialBindingTest component) {
        component.map!['bar'] = true;
      });
      expect(content.classList.asIterable(), equals(['init', 'foo', 'bar']));
      await testFixture.update((MapUpdateWithInitialBindingTest component) {
        component.map!['foo'] = false;
      });
      expect(content.classList.asIterable(), equals(['init', 'bar']));
      await testFixture.update((MapUpdateWithInitialBindingTest component) {
        component.map = null;
      });
      expect(content.classList.asIterable(), equals(['init', 'foo']));
    });

    test('should cooperate with class attribute and class.name binding',
        () async {
      var testBed = NgTestBed<MapUpdateWithConditionBindingTest>(
          ng.createMapUpdateWithConditionBindingTestFactory());
      var testFixture = await testBed.create();
      var content = testFixture.rootElement.querySelector('div')!;
      expect(content.classList.asIterable(), equals(['init', 'foo', 'baz']));
      await testFixture.update((MapUpdateWithConditionBindingTest component) {
        component.map!['bar'] = true;
      });
      expect(content.classList.asIterable(),
          equals(['init', 'foo', 'baz', 'bar']));
      await testFixture.update((MapUpdateWithConditionBindingTest component) {
        component.map!['foo'] = false;
      });
      expect(content.classList.asIterable(), equals(['init', 'baz', 'bar']));
      await testFixture.update((MapUpdateWithConditionBindingTest component) {
        component.condition = false;
      });
      expect(content.classList.asIterable(), equals(['init', 'bar']));
    });

    test(
        'should cooperate with initial class and class '
        'attribute binding when binding changes', () async {
      var testBed = NgTestBed<MapUpdateWithStringBindingTest>(
          ng.createMapUpdateWithStringBindingTestFactory());
      var testFixture = await testBed.create();
      var content = testFixture.rootElement.querySelector('div')!;
      expect(content.classList.asIterable(), equals(['init', 'foo']));
      await testFixture.update((MapUpdateWithStringBindingTest component) {
        component.map!['bar'] = true;
      });
      expect(content.classList.asIterable(), equals(['init', 'foo', 'bar']));
      await testFixture.update((MapUpdateWithStringBindingTest component) {
        component.string = 'baz';
      });
      expect(content.classList.asIterable(),
          equals(['init', 'bar', 'baz', 'foo']));
      await testFixture.update((MapUpdateWithStringBindingTest component) {
        component.map = null;
      });
      expect(content.classList.asIterable(), equals(['init', 'baz']));
    });

    test(
        'should cooperate with interpolated class attribute '
        'and clas.name binding', () async {
      var testBed = NgTestBed<InterpolationWithConditionBindingTest>(
          ng.createInterpolationWithConditionBindingTestFactory());
      var testFixture = await testBed.create();
      var content = testFixture.rootElement.querySelector('div')!;
      expect(content.classList.asIterable(), equals(['foo', 'baz']));
      await testFixture
          .update((InterpolationWithConditionBindingTest component) {
        component.condition = false;
      });
      expect(content.classList.asIterable(), equals(['foo']));
      await testFixture
          .update((InterpolationWithConditionBindingTest component) {
        component.condition = true;
      });
      expect(content.classList.asIterable(), equals(['foo', 'baz']));
    });
  });

  group('should render static class', () {
    test('and ngClass', () async {
      final testBed = NgTestBed<TestStaticClassWithNgClass>(
        ng.createTestStaticClassWithNgClassFactory(),
      );
      final fixture = await testBed.create(
        beforeChangeDetection: (i) => i.name = 'dynamic',
      );
      expect(fixture.rootElement.allCssClasses, ['static', 'dynamic']);
    });

    test('and [class.]', () async {
      final testBed = NgTestBed<TestStaticClassWithClassDot>(
        ng.createTestStaticClassWithClassDotFactory(),
      );
      final fixture = await testBed.create(
        beforeChangeDetection: (i) => i.enabled = true,
      );
      expect(fixture.rootElement.allCssClasses, ['static', 'enabled']);
    });

    test('and [attr.class] but DOES NOT', () async {
      final testBed = NgTestBed<TestStaticClassWithAttrClass>(
        ng.createTestStaticClassWithAttrClassFactory(),
      );
      final fixture = await testBed.create(
        beforeChangeDetection: (i) => i.name = 'dynamic',
      );
      expect(
        fixture.rootElement.allCssClasses,
        ['dynamic'],
        reason: '"static" is overriden by [attr.class]',
      );
    });

    test('and @HostBinding but DOES NOT', () async {
      final testBed = NgTestBed<TestStaticClassWithHostClass>(
        ng.createTestStaticClassWithHostClassFactory(),
      );
      final fixture = await testBed.create(
        beforeChangeDetection: (i) => i.name = 'dynamic',
      );
      expect(
        fixture.rootElement.allCssClasses,
        ['dynamic'],
        reason: '"static" is overriden by the @HostBinding of the child',
      );
    });

    test('and [class.], and ngClass', () async {
      final testBed = NgTestBed<TestStaticClassWithClassDotNgClass>(
        ng.createTestStaticClassWithClassDotNgClassFactory(),
      );
      final fixture = await testBed.create(
        beforeChangeDetection: (i) => i
          ..name = 'dynamic'
          ..enabled = true,
      );
      expect(
        fixture.rootElement.allCssClasses,
        ['static', 'dynamic', 'enabled'],
      );
    });
  });

  group('should render dynamic class', () {
    test('and ngClass', () async {
      final testBed = NgTestBed<TestDynamicClassWithNgClass>(
        ng.createTestDynamicClassWithNgClassFactory(),
      );
      final fixture = await testBed.create(
        beforeChangeDetection: (i) => i
          ..name1 = 'dynamic1'
          ..name2 = 'dynamic2',
      );
      expect(fixture.rootElement.allCssClasses, ['dynamic1', 'dynamic2']);
    });

    test('and [class.] but DOES NOT', () async {
      final testBed = NgTestBed<TestDynamicClassWithClassDot>(
        ng.createTestDynamicClassWithClassDotFactory(),
      );
      final fixture = await testBed.create(
        beforeChangeDetection: (i) => i
          ..name = 'dynamic'
          ..enabled = true,
      );
      expect(
        fixture.rootElement.allCssClasses,
        ['dynamic'],
        reason: '"enabled" is overriden by class="{{..}}"',
      );
    });

    test('and [attr.class] but DOES NOT', () async {
      final testBed = NgTestBed<TestDynamicClassWithAttrClass>(
        ng.createTestDynamicClassWithAttrClassFactory(),
      );
      final fixture = await testBed.create(
        beforeChangeDetection: (i) => i
          ..name1 = 'dynamic1'
          ..name2 = 'dynamic2',
      );
      expect(
        fixture.rootElement.allCssClasses,
        ['dynamic1'],
        reason: '"dynamic2" is overriden by class="{{..}}"',
      );
    });

    test('and @HostBinding but DOES NOT', () async {
      final testBed = NgTestBed<TestDynamicClassWithHostClass>(
        ng.createTestDynamicClassWithHostClassFactory(),
      );
      final fixture = await testBed.create(
        beforeChangeDetection: (i) => i
          ..name1 = 'dynamic1'
          ..name2 = 'dynamic2',
      );
      expect(
        fixture.rootElement.allCssClasses,
        ['dynamic2'],
        reason: '"dynamic1" is overriden by child\'s @HostBinding',
      );
    });
  });
}

class Base {
  var condition = true;
  Map<String, bool>? map = {'foo': true, 'bar': false};
  var list = ['foo'];
  var set = <String>{};
  String? string = 'foo';
}

@Component(
  selector: 'ngclass-destroy',
  directives: [NgClass, NgFor],
  template: '<div *ngFor="let item of items" [ngClass]="item"></div>',
)
class DestroyClassTest {
  List<List<String>>? items;
}

@Component(
  selector: 'class-with-names',
  directives: [NgClass],
  template: '<div [ngClass]="classes"></div>',
)
class ClassWithNames {
  static const classes = {
    'foo-bar': true,
    'fooBar': true,
  };
}

@Component(
  selector: 'condition-map-test',
  directives: [NgClass],
  template: '<div [ngClass]="conditionMap"></div>',
)
class ConditionMapTest extends Base {
  Map<String, bool>? _conditionMap;
  bool _prevCondition = false;

  Map<String, bool> get conditionMap {
    if (_prevCondition != condition) {
      _conditionMap = {
        'foo': condition,
        'bar': !condition,
      };
      _prevCondition = condition;
    }
    return _conditionMap!;
  }
}

@Component(
  selector: 'map-update-test',
  directives: [NgClass],
  template: '<div [ngClass]="map"></div>',
)
class MapUpdateTest extends Base {}

@Component(
  selector: 'list-update-test',
  directives: [NgClass],
  template: '<div [ngClass]="list"></div>',
)
class ListUpdateTest extends Base {}

@Component(
  selector: 'list-update-with-initial-test',
  directives: [NgClass],
  template: '<div class="foo" [ngClass]="list"></div>',
)
class ListUpdateWithInitialTest extends Base {}

@Component(
  selector: 'list-update-test',
  directives: [NgClass],
  template: '<div [ngClass]="set"></div>',
)
class SetUpdateTest extends Base {}

@Component(
  selector: 'string-literal-test',
  directives: [NgClass],
  template: '<div [ngClass]="\'foo bar foo-bar fooBar\'"></div>',
)
class StringLiteralTest {}

@Component(
  selector: 'string-update-test',
  directives: [NgClass],
  template: '<div [ngClass]="string"></div>',
)
class StringUpdateTest extends Base {}

@Component(
  selector: 'string-update-with-initial-test',
  directives: [NgClass],
  template: '<div class="foo" [ngClass]="string"></div>',
)
class StringUpdateWithInitialTest extends Base {}

@Component(
  selector: 'map-update-with-initial-test',
  directives: [NgClass],
  template: '<div [ngClass]="map" class="init foo"></div>',
)
class MapUpdateWithInitialTest extends Base {}

@Component(
  selector: 'map-update-with-initial-interpolation-test',
  directives: [NgClass],
  template: '<div [ngClass]="map" class="{{\'init foo\'}}"></div>',
)
class MapUpdateWithInitialInterpolationTest extends Base {}

@Component(
  selector: 'map-update-with-initial-binding-test',
  directives: [NgClass],
  template: '<div [ngClass]="map" class="init" [class]="\'foo\'"></div>',
)
class MapUpdateWithInitialBindingTest extends Base {}

@Component(
  selector: 'map-update-with-condition-binding-test',
  directives: [NgClass],
  template:
      '<div class="init foo" [ngClass]="map" [class.baz]="condition"></div>',
)
class MapUpdateWithConditionBindingTest extends Base {}

@Component(
  selector: 'map-update-with-string-binding-test',
  directives: [NgClass],
  template: '<div class="init" [ngClass]="map" [class]="string"></div>',
)
class MapUpdateWithStringBindingTest extends Base {}

@Component(
  selector: 'interpolation-with-condition-binding-test',
  directives: [NgClass],
  template: '<div [class.baz]="condition" class="{{string}}" ngClass></div>',
)
class InterpolationWithConditionBindingTest extends Base {}

extension _SumCssClasses on Element {
  Iterable<String> get allCssClasses {
    return querySelectorAll('*')
        .asIterable()
        .whereType<Element>()
        .map((e) => e.classList.asIterable())
        .expand((c) => c);
  }
}

@Component(
  selector: 'child',
  template: '',
)
class ChildWithHostClass {
  @Input()
  String? name;

  @HostBinding('class')
  String get className => name ?? '';
}

@Component(
  selector: 'test',
  directives: [
    NgClass,
  ],
  template: r'''
    <div class="static" [ngClass]="name"></div>
  ''',
)
class TestStaticClassWithNgClass {
  String? name;
}

@Component(
  selector: 'test',
  template: r'''
    <div class="static" [class.enabled]="enabled"></div>
  ''',
)
class TestStaticClassWithClassDot {
  bool enabled = false;
}

@Component(
  selector: 'test',
  template: r'''
    <div class="static" [attr.class]="name"></div>
  ''',
)
class TestStaticClassWithAttrClass {
  String name = '';
}

@Component(
  selector: 'test',
  directives: [
    ChildWithHostClass,
  ],
  template: r'''
    <child class="static" [name]="name"></child>
  ''',
)
class TestStaticClassWithHostClass {
  String? name;
}

@Component(
  selector: 'test',
  directives: [
    NgClass,
  ],
  template: r'''
    <div class="static" [class.enabled]="enabled" [ngClass]="name"></div>
  ''',
)
class TestStaticClassWithClassDotNgClass {
  bool enabled = false;
  String? name;
}

@Component(
  selector: 'test',
  directives: [
    NgClass,
  ],
  template: r'''
    <div class="{{name1}}" [ngClass]="name2"></div>
  ''',
)
class TestDynamicClassWithNgClass {
  String? name1;
  String? name2;
}

@Component(
  selector: 'test',
  template: r'''
    <div class="{{name}}" [class.enabled]="enabled"></div>
  ''',
)
class TestDynamicClassWithClassDot {
  String? name;
  bool enabled = false;
}

@Component(
  selector: 'test',
  template: r'''
    <div class="{{name1}}" [attr.class]="name2"></div>
  ''',
)
class TestDynamicClassWithAttrClass {
  String? name1;
  String name2 = '';
}

@Component(
  selector: 'test',
  directives: [
    ChildWithHostClass,
  ],
  template: r'''
    <child class="{{name1}}" [name]="name2"></child>
  ''',
)
class TestDynamicClassWithHostClass {
  String? name1;
  String? name2;
}
