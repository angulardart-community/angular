import 'dart:async';

import 'package:ngdart/angular.dart';
import 'package:ngtest/angular_test.dart';
import 'package:test/test.dart';
import 'package:web/web.dart';

import 'bed_error_test.template.dart' as ng;

void main() {
  tearDown(disposeAnyRunningTest);

  test('should be able to catch errors that occur synchronously',
      CatchSynchronousErrors._runTest);

  test('should be able to catch errors that occur asynchronously',
      CatchAsynchronousErrors._runTest);

  test('should be able to catch errors that occur in the constructor',
      CatchConstructorErrors._runTest);

  test('should be able to catch errors asynchronously in constructor',
      CatchConstructorAsyncErrors._runTest);

  test('should be able to catch asynchronous errors from a native event',
      CatchNativeEventAsynchronousErrors._runTest);

  test('should be able to catch synchronously errors from a native event',
      CatchNativeEventSynchronousErrors._runTest);

  test('should be able to catch errors that occur in `ngOnInit`',
      CatchOnInitErrors._runTest);

  test('should be able to catch errors that occur in change detection',
      CatchInChangeDetection._runTest);

  test('should not have uncaught errors silenty passed', () async {
    await NoExceptionsSwallowedTest._runTest();
  });
}

@Component(
  selector: 'test',
  template: '',
)
class CatchSynchronousErrors {
  static Future<void> _runTest() async {
    final fixture = await NgTestBed<CatchSynchronousErrors>(
      ng.createCatchSynchronousErrorsFactory(),
    ).create();
    expect(
      fixture.update((_) => throw StateError('Test')),
      throwsA(isStateError),
    );
  }
}

@Component(
  selector: 'test',
  template: '',
)
class CatchAsynchronousErrors {
  static Future<void> _runTest() async {
    final fixture = await NgTestBed<CatchAsynchronousErrors>(
      ng.createCatchAsynchronousErrorsFactory(),
    ).create();
    expect(
      fixture.update((_) => Future<void>.error(StateError('Test'))),
      throwsA(isStateError),
    );
  }
}

@Component(
  selector: 'test',
  template: '',
)
class CatchConstructorErrors {
  static Future<void> _runTest() async {
    final testBed = NgTestBed<CatchConstructorErrors>(
      ng.createCatchConstructorErrorsFactory(),
    );
    expect(
      testBed.create(),
      throwsA(isStateError),
    );
  }

  CatchConstructorErrors() {
    throw StateError('Test');
  }
}

@Component(
  selector: 'test',
  template: '',
)
class CatchConstructorAsyncErrors {
  static Future<void> _runTest() async {
    final testBed = NgTestBed<CatchConstructorAsyncErrors>(
      ng.createCatchConstructorAsyncErrorsFactory(),
    );
    expect(
      testBed.create(),
      throwsA(isStateError),
    );
  }

  CatchConstructorAsyncErrors() {
    Timer.run(() {
      throw StateError('Test');
    });
  }
}

@Component(
  selector: 'test',
  template: '<button (click)="throwError">Throw</button>',
)
class CatchNativeEventSynchronousErrors {
  static Future<void> _runTest() async {
    final fixture = await NgTestBed<CatchNativeEventSynchronousErrors>(
      ng.createCatchNativeEventSynchronousErrorsFactory(),
    ).create();
    expect(
      fixture.update((_) {
        (fixture.rootElement.querySelector('button') as HTMLElement).click();
      }),
      throwsA(isStateError),
    );
  }

  void throwError() {
    throw StateError('Test');
  }
}

@Component(
  selector: 'test',
  template: '<button (click)="throwError">Throw</button>',
)
class CatchNativeEventAsynchronousErrors {
  static Future<void> _runTest() async {
    final fixture = await NgTestBed<CatchNativeEventSynchronousErrors>(
      ng.createCatchNativeEventSynchronousErrorsFactory(),
    ).create();
    expect(
      fixture.update((_) {
        (fixture.rootElement.querySelector('button') as HTMLElement).click();
      }),
      throwsA(isStateError),
    );
  }

  Future<void> throwError() async {
    throw StateError('Test');
  }
}

@Component(
  selector: 'test',
  template: '',
)
class CatchOnInitErrors implements OnInit {
  static Future<void> _runTest() async {
    final testBed = NgTestBed<CatchOnInitErrors>(
      ng.createCatchOnInitErrorsFactory(),
    );
    expect(
      testBed.create(),
      throwsA(isStateError),
    );
  }

  @override
  void ngOnInit() {
    throw StateError('Test');
  }
}

@Component(
  selector: 'test',
  template: '<child [trueToError]="value"></child>',
  directives: [ChildChangeDetectionError],
)
class CatchInChangeDetection {
  static Future<void> _runTest() async {
    final NgTestFixture<CatchInChangeDetection> fixture =
        await NgTestBed<CatchInChangeDetection>(
      ng.createCatchInChangeDetectionFactory(),
    ).create();
    expect(
      fixture.update((c) => c.value = true),
      throwsA(isStateError),
    );
  }

  bool value = false;
}

@Component(
  selector: 'child',
  template: '',
)
class ChildChangeDetectionError {
  @Input()
  set trueToError(bool trueToError) {
    if (trueToError) {
      throw StateError('Test');
    }
  }
}

@Component(
  selector: 'test',
  template: '<h1>Hello {{name}}</h1>',
)
class NoExceptionsSwallowedTest {
  static Future<void> _runTest() async {
    final simpleHandler = _CapturingExceptionHandler();
    final NgTestFixture<NoExceptionsSwallowedTest> fixture =
        await NgTestBed<NoExceptionsSwallowedTest>(
      ng.createNoExceptionsSwallowedTestFactory(),
      rootInjector: (i) => Injector.map(
        {ExceptionHandler: simpleHandler},
        i,
      ),
    ).create();

    expect(fixture.text, 'Hello Angular');
    await fixture.update((c) => c.name = 'World');
    expect(fixture.text, 'Hello World');
    final html = (fixture.rootElement as HTMLElement).innerHTML;
    expect(html, '<h1>Hello World</h1>');
    await fixture.dispose();

    expect(
      simpleHandler.exceptions,
      isEmpty,
      reason: 'No exceptions should have been thrown/caught',
    );
  }

  var name = 'Angular';
}

class _CapturingExceptionHandler implements ExceptionHandler {
  final exceptions = <String>[];

  @override
  void call(exception, [stackTrace, String? reason]) {
    exceptions.add('$exception: $stackTrace');
  }
}
