import 'dart:async';
import 'dart:html';

import 'package:test/test.dart';
import 'package:angular/angular.dart';
import 'package:angular_test/angular_test.dart';

import 'outputs_test.template.dart' as ng;

void main() {
  tearDown(disposeAnyRunningTest);

  test('should support directive outputs on regular elements', () async {
    final testBed =
        NgTestBed(ng.createElementWithEventDirectivesComponentFactory());
    final testFixture = await testBed.create();
    final emitter = testFixture.assertOnlyInstance.emitter;
    final listener = testFixture.assertOnlyInstance.listener!;
    expect(listener.msg, isNull);
    await testFixture.update((_) => emitter!.fireEvent('fired!'));
    expect(listener.msg, 'fired!');
  });

  test('should support directive outputs on template elements', () async {
    final testBed =
        NgTestBed(ng.createTemplateWithEventDirectivesComponentFactory());
    final testFixture = await testBed.create();
    final component = testFixture.assertOnlyInstance;
    expect(component.msg, isNull);
    expect(component.listener!.msg, isNull);
    await testFixture.update((_) => component.emitter!.fireEvent('fired!'));
    expect(component.msg, 'fired!');
    expect(component.listener!.msg, 'fired!');
  });

  test('should support [()] syntax', () async {
    final testBed = NgTestBed(ng.createTwoWayBindingComponentFactory());
    final testFixture = await testBed.create();
    final component = testFixture.assertOnlyInstance;
    expect(component.directive!.control, 'one');
    await testFixture.update((_) => component.directive!.triggerChange('two'));
    expect(component.ctxProp, 'two');
    expect(component.directive!.control, 'two');
  });

  test('should support render events', () async {
    final testBed = NgTestBed(ng.createElementWithDomEventComponentFactory());
    final testFixture = await testBed.create();
    final div = testFixture.rootElement.children.first;
    final listener = testFixture.assertOnlyInstance.listener;
    await testFixture.update((_) => div.dispatchEvent(Event('click')));
    expect(listener!.eventTypes, ['click']);
  });

  test('should support preventing default on render events', () async {
    final testBed = NgTestBed(ng.createTestPreventDefaultComponentFactory());
    final testFixture = await testBed.create();
    final inputPrevent = testFixture.rootElement.children[0] as InputElement;
    final inputNoPrevent = testFixture.rootElement.children[1] as InputElement;
    final clickPrevent = MouseEvent('click');
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
    final testBed = NgTestBed(ng.createTestMismatchedHandlerFactory());
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

@directive(
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

@directive(
  selector: '[listener]',
)
class EventListenerDirective {
  String? msg;

  @HostListener('event')
  void onEvent(String msg) {
    this.msg = msg;
  }
}

@component(
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

@component(
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

@directive(
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

@component(
  selector: 'two-way-binding',
  template: '<div [(control)]="ctxProp" two-way></div>',
  directives: [DirectiveWithTwoWayBinding],
)
class TwoWayBindingComponent {
  String ctxProp = 'one';

  @ViewChild(DirectiveWithTwoWayBinding)
  DirectiveWithTwoWayBinding? directive;
}

@directive(
  selector: '[listener]',
)
class DomEventListenerDirective {
  List<String> eventTypes = [];

  @HostListener('click', [r'$event.type'])
  void onClick(String eventType) {
    eventTypes.add(eventType);
  }
}

@component(
  selector: 'element-with-dom-event',
  template: '<div listener></div>',
  directives: [DomEventListenerDirective],
)
class ElementWithDomEventComponent {
  @ViewChild(DomEventListenerDirective)
  DomEventListenerDirective? listener;
}

@directive(
  selector: '[listenerprevent]',
)
class DirectiveListeningDomEventPrevent {
  @HostListener('click')
  void onEvent(Event event) {
    event.preventDefault();
  }
}

@directive(
  selector: '[listenernoprevent]',
)
class DirectiveListeningDomEventNoPrevent {
  @HostListener('click')
  void onEvent(Event event) {}
}

@component(
  selector: 'test-prevent-default',
  template: '<input type="checkbox" listenerprevent>'
      '<input type="checkbox" listenernoprevent>',
  directives: [
    DirectiveListeningDomEventNoPrevent,
    DirectiveListeningDomEventPrevent,
  ],
)
class TestPreventDefaultComponent {}

@component(
  selector: 'output',
  template: '',
)
class OutputComponent {
  @Output()
  Stream<String> output = Stream.empty();
}

@component(
  selector: 'test',
  template: '<output (output)="handle"></output>',
  directives: [OutputComponent],
)
class TestMismatchedHandler {
  void handle(int value) {}
}
