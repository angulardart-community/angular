import 'dart:html';

import 'package:test/test.dart';
import 'package:ngdart/angular.dart';
import 'package:ngtest/angular_test.dart';
import 'package:ngtest/compatibility.dart';

import 'compatibility_test.template.dart' as ng;

void main() {
  late Element docRoot;
  late Element testRoot;

  setUp(() {
    docRoot = Element.tag('doc-root');
    testRoot = Element.tag('ng-test-bed-example-test');
    docRoot.append(testRoot);
  });

  tearDown(disposeAnyRunningTest);

  group('with injector', () {
    late NgTestBed<AngularInjector> testBed;
    TestService? testService;

    setUp(() {
      testService = null;
      testBed = NgTestBed(
        ng.createAngularInjectorFactory(),
        host: testRoot,
        rootInjector: (i) => Injector.map({TestService: TestService()}, i),
      );
    });

    test('should render, update, and destroy a component', () async {
      // We are going to verify that the document root has a new node created
      // (our component), the node is updated (after change detection), and
      // after destroying the test the document root has been cleared.
      final fixture = await testBed.create();
      expect(docRoot.text, isEmpty);
      testService = injectFromFixture(fixture, TestService);
      await fixture.update((_) => testService!.value = 'New value');
      expect(docRoot.text, 'New value');
      await fixture.dispose();
      print(docRoot.innerHtml);
      expect(docRoot.text, isEmpty);
    });
    group('and beforeComponentCreated without error', () {
      test('should handle synchronous fn', () async {
        final fixture = await testBed.create(beforeComponentCreated: (i) {
          testService = i.provideType(TestService);
          testService!.value = 'New value';
        }, beforeChangeDetection: (_) {
          expect(testService, isNotNull);
        });
        expect(docRoot.text, 'New value');
        await fixture.dispose();
      });

      test('should handle asynchronous fn', () async {
        final fixture = await testBed.create(beforeComponentCreated: (i) async {
          testService = i.provideType(TestService);
          testService!.value = 'New value';
        }, beforeChangeDetection: (_) {
          expect(testService, isNotNull);
        });
        expect(docRoot.text, 'New value');
        await fixture.dispose();
      });

      test('should handle asynchronous fn with delayed future', () async {
        final fixture = await testBed.create(beforeComponentCreated: (i) async {
          await Future.delayed(Duration(milliseconds: 200));
          testService = i.provideType(TestService);
          testService!.value = 'New value';
        }, beforeChangeDetection: (_) {
          expect(testService, isNotNull);
        });
        expect(docRoot.text, 'New value');
        await fixture.dispose();
      });
    });

    group('and beforeComponentCreated with error', () {
      test('should handle synchronous fn', () async {
        // ignore: void_checks
        expect(testBed.create(beforeComponentCreated: (_) {
          throw Error();
        }), throwsA(const TypeMatcher<Error>()));
      });

      test('should handle asynchronous fn', () async {
        expect(testBed.create(beforeComponentCreated: (_) async {
          throw Error();
        }), throwsA(const TypeMatcher<Error>()));
      });

      test('should handle asynchronous fn with delayed future', () async {
        expect(testBed.create(beforeComponentCreated: (_) async {
          await Future<void>.delayed(Duration(milliseconds: 200));
          throw Error();
        }), throwsA(const TypeMatcher<Error>()));
      });
    });
  });
}

@Component(
  selector: 'test',
  template: '{{value}}',
)
class AngularInjector {
  final TestService _testService;

  AngularInjector(this._testService);

  String? get value => _testService.value;
}

@Injectable()
class TestService {
  String? value;
}
