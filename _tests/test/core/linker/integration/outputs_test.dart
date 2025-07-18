import 'dart:async';

import 'package:ngdart/angular.dart';
import 'package:ngtest/angular_test.dart';
import 'package:test/test.dart';
import 'package:web/web.dart';

import 'outputs_test.template.dart' as ng;

void main() {
  tearDown(disposeAnyRunningTest);

  test('should support directive outputs on regular elements', () async {
    final testBed = NgTestBed<ElementWithEventDirectivesComponent>(
        ng.createElementWithEventDirectivesComponentFactory());
    final testFixture = await testBed.create();
    final emitter = testFixture.assertOnlyInstance.emitter;
    final listener = testFixture.assertOnlyInstance.listener!;
    expect(listener.msg, isNull);
    await testFixture.update((_) => emitter!.fireEvent('fired!'));
    expect(listener.msg, 'fired!');
  });

  test('should support directive outputs on template elements', () async {
    final testBed = NgTestBed<TemplateWithEventDirectivesComponent>(
        ng.createTemplateWithEventDirectivesComponentFactory());
    final testFixture = await testBed.create();
    final component = testFixture.assertOnlyInstance;
    expect(component.msg, isNull);
    expect(component.listener!.msg, isNull);
    await testFixture.update((_) => component.emitter!.fireEvent('fired!'));
    expect(component.msg, 'fired!');
    expect(component.listener!.msg, 'fired!');
  });

  test('should support [()] syntax', () async {
    final testBed = NgTestBed<TwoWayBindingComponent>(
        ng.createTwoWayBindingComponentFactory());
    final testFixture = await testBed.create();
    final component = testFixture.assertOnlyInstance;
    expect(component.directive!.control, 'one');
    await testFixture.update((_) => component.directive!.triggerChange('two'));
    expect(component.ctxProp, 'two');
    expect(component.directive!.control, 'two');
  });

  test('should support render events', () async {
    final testBed = NgTestBed<ElementWithDomEventComponent>(
        ng.createElementWithDomEventComponentFactory());
    final testFixture = await testBed.create();
    final div = testFixture.rootElement.children.item(0)!;
    final listener = testFixture.assertOnlyInstance.listener;
    await testFixture.update((_) => div.dispatchEvent(Event('click')));
    expect(listener!.eventTypes, ['click']);
  });

  test('should support preventing default on render events', () async {
    final testBed = NgTestBed<TestPreventDefaultComponent>(
        ng.createTestPreventDefaultComponentFactory());
    final testFixture = await testBed.create();
    final inputPrevent =
        testFixture.rootElement.children.item(0) as HTMLInputElement;
    final inputNoPrevent =
        testFixture.rootElement.children.item(1) as HTMLInputElement;
    // `true` by default in the `dart:html` Event contructor
    final clickPrevent = MouseEvent('click', MouseEventInit(cancelable: true));
    final clickNoPrevent = MouseEvent('click');
    inputPrevent.dispatchEvent(clickPrevent);
    inputNoPrevent.dispatchEvent(clickNoPrevent);
    await testFixture.update();
    expect(clickPrevent.defaultPrevented, true);
    expect(clickNoPrevent.defaultPrevented, false);
    expect(inputPrevent.checked, false);
    expect(inputNoPrevent.checked, true);
  });

  test('should provide helpful error for incorrectly typed handler', () async {
    final testBed = NgTestBed<TestMismatchedHandler>(
        ng.createTestMismatchedHandlerFactory());
    expect(
      testBed.create,
      throwsA(const TypeMatcher<AssertionError>().having(
        (a) => a.message,
        'message',
        contains("isn't assignable to expected type"),
      )),
    );
  }, skip: 'https://github.com/dart-lang/sdk/issues/36832');
}

@Directive(
  selector: '[emitter]',
)
class EventEmitterDirective {
  String? msg;

  final _streamController = StreamController<String>();

  @Output()
  Stream<String> get event => _streamController.stream;

  void fireEvent(String msg) {
    _streamController.add(msg);
  }
}

@Directive(
  selector: '[listener]',
)
class EventListenerDirective {
  String? msg;

  @HostListener('event')
  void onEvent(String msg) {
    this.msg = msg;
  }
}

@Component(
  selector: 'event-directives',
  template: '<div emitter listener></div>',
  directives: [EventEmitterDirective, EventListenerDirective],
)
class ElementWithEventDirectivesComponent {
  @ViewChild(EventEmitterDirective)
  EventEmitterDirective? emitter;

  @ViewChild(EventListenerDirective)
  EventListenerDirective? listener;
}

@Component(
  selector: 'template-event-directives',
  template: '<template emitter listener (event)="msg=\$event"></template>',
  directives: [EventEmitterDirective, EventListenerDirective],
)
class TemplateWithEventDirectivesComponent {
  String? msg;

  @ViewChild(EventEmitterDirective)
  EventEmitterDirective? emitter;

  @ViewChild(EventListenerDirective)
  EventListenerDirective? listener;
}

@Directive(
  selector: '[two-way]',
)
class DirectiveWithTwoWayBinding {
  final _streamController = StreamController<String>();

  @Input()
  String? control;

  @Output()
  Stream<String> get controlChange => _streamController.stream;

  void triggerChange(String value) {
    _streamController.add(value);
  }
}

@Component(
  selector: 'two-way-binding',
  template: '<div [(control)]="ctxProp" two-way></div>',
  directives: [DirectiveWithTwoWayBinding],
)
class TwoWayBindingComponent {
  String ctxProp = 'one';

  @ViewChild(DirectiveWithTwoWayBinding)
  DirectiveWithTwoWayBinding? directive;
}

@Directive(
  selector: '[listener]',
)
class DomEventListenerDirective {
  List<String> eventTypes = [];

  @HostListener('click', [r'$event.type'])
  void onClick(String eventType) {
    eventTypes.add(eventType);
  }
}

@Component(
  selector: 'element-with-dom-event',
  template: '<div listener></div>',
  directives: [DomEventListenerDirective],
)
class ElementWithDomEventComponent {
  @ViewChild(DomEventListenerDirective)
  DomEventListenerDirective? listener;
}

@Directive(
  selector: '[listenerprevent]',
)
class DirectiveListeningDomEventPrevent {
  @HostListener('click')
  void onEvent(Event event) {
    event.preventDefault();
  }
}

@Directive(
  selector: '[listenernoprevent]',
)
class DirectiveListeningDomEventNoPrevent {
  @HostListener('click')
  void onEvent(Event event) {}
}

@Component(
  selector: 'test-prevent-default',
  template: '<input type="checkbox" listenerprevent>'
      '<input type="checkbox" listenernoprevent>',
  directives: [
    DirectiveListeningDomEventNoPrevent,
    DirectiveListeningDomEventPrevent,
  ],
)
class TestPreventDefaultComponent {}

@Component(
  selector: 'output',
  template: '',
)
class OutputComponent {
  @Output()
  Stream<String> output = Stream.empty();
}

@Component(
  selector: 'test',
  template: '<output (output)="handle"></output>',
  directives: [OutputComponent],
)
class TestMismatchedHandler {
  void handle(int value) {}
}
