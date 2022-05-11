import 'dart:async';
import 'dart:html';

import 'package:test/test.dart';
import 'package:angular/angular.dart';
import 'package:angular_test/angular_test.dart';

import 'directive_integration_test.template.dart' as ng;

void main() {
  tearDown(disposeAnyRunningTest);

  test('should support nested components', () async {
    final testBed = NgTestBed(ng.createParentComponentFactory());
    final testFixture = await testBed.create();
    expect(testFixture.text, 'hello');
  });

  test('should consume directive input binding', () async {
    final testBed = NgTestBed(ng.createBoundDirectiveInputComponentFactory());
    final testFixture = await testBed.create();
    final directives = testFixture.assertOnlyInstance.directives!;
    await testFixture.update((component) => component.value = 'New property');
    expect(directives[0].dirProp, 'New property');
    expect(directives[1].dirProp, 'Hi there!');
    expect(directives[2].dirProp, 'Hey there!!');
    expect(directives[3].dirProp, 'One more New property');
  });

  test('should support multiple directives on a single node', () async {
    final testBed = NgTestBed(ng.createMultipleDirectivesComponentFactory());
    final testFixture = await testBed.create();
    final directive = testFixture.assertOnlyInstance.directive;
    expect(directive!.dirProp, 'Hello world!');
    expect(testFixture.text, 'hello');
  });

  test('should support directives missing input bindings', () async {
    final testBed = NgTestBed(ng.createUnboundDirectiveInputComponentFactory());
    final testFixture = await testBed.create();
    expect(testFixture.text, isEmpty);
  });

  test('should execute a directive once, even if specified multiple times',
      () async {
    final testBed = NgTestBed(ng.createDuplicateDirectivesComponentFactory());
    final testFixture = await testBed.create();
    expect(testFixture.text, 'noduplicate');
  });

  test('should support directives whose selector matches native property',
      () async {
    final testBed =
        NgTestBed(ng.createOverrideNativePropertyComponentFactory());
    final testFixture = await testBed.create();
    final directive = testFixture.assertOnlyInstance.directive!;
    expect(directive.id, 'some_id');
    await testFixture.update((component) => component.value = 'other_id');
    expect(directive.id, 'other_id');
  });

  test('should support directives whose selector matches event binding',
      () async {
    final testBed = NgTestBed(ng.createEventDirectiveComponentFactory());
    final testFixture = await testBed.create();
    expect(testFixture.assertOnlyInstance.directive, isNotNull);
  });

  test('should read directives metadata from their binding token', () async {
    final testBed =
        NgTestBed(ng.createRetrievesDependencyFromHostComponentFactory());
    final testFixture = await testBed.create();
    final needsPublicApi = testFixture.assertOnlyInstance.needsPublicApi;
    expect(needsPublicApi!.api, const TypeMatcher<PrivateImpl>());
  });

  test('should consume pipe binding', () async {
    final testBed = NgTestBed(ng.createPipedDirectiveInputComponentFactory());
    final testFixture = await testBed.create();
    final directive = testFixture.assertOnlyInstance.directive;
    expect(directive!.dirProp, 'aa');
  });

  test('should not bind attribute matcher when generating host view', () async {
    // This test will fail on DDC if [width] in host template generates
    // invalid code to initialize width.
    final testBed = NgTestBed(ng.createSimpleButtonFactory());
    await testBed.create();
  });
  test('should not bind attribute matcher when generating host view', () async {
    // This test will fail on DDC if [width] in host template generates
    // invalid code to initialize width.
    final testBed = NgTestBed(ng.createSimpleInputFactory());
    await testBed.create();
  });
}

@component(
  selector: 'input[type=text][width]',
  template: 'Test',
)
class SimpleInput {
  @Input()
  int? width;
}

@component(
  selector: 'button[width]',
  template: 'Test',
)
class SimpleButton {
  @Input()
  int? width;
}

@directive(
  selector: '[my-dir]',
  exportAs: 'myDir',
)
class MyDir {
  @Input('elProp')
  String dirProp = '';
}

@component(
  selector: 'bound-directive-input',
  template: '<div my-dir [elProp]="value"></div>'
      '<div my-dir elProp="Hi there!"></div>'
      '<div my-dir elProp="Hey {{\'there!!\'}}"></div>'
      '<div my-dir elProp="One more {{value}}"></div>',
  directives: [
    MyDir,
  ],
)
class BoundDirectiveInputComponent {
  String value = 'Initial value';

  @ViewChildren(MyDir)
  List<MyDir>? directives;
}

@Injectable()
class MyService {
  String greeting = 'hello';
}

@component(
  selector: 'child',
  template: '{{value}}',
  viewProviders: [
    MyService,
  ],
)
class ChildComponent {
  late final String value;

  ChildComponent(MyService service) {
    value = service.greeting;
  }
}

@component(
  selector: 'parent',
  template: '<child></child>',
  directives: [
    ChildComponent,
  ],
)
class ParentComponent {}

@component(
  selector: 'multiple-directives',
  template: '<child my-dir [elProp]="value"></child>',
  directives: [
    ChildComponent,
    MyDir,
  ],
)
class MultipleDirectivesComponent {
  String value = 'Hello world!';

  @ViewChild(MyDir)
  MyDir? directive;
}

@component(
  selector: 'unbound-directive-input',
  template: '<div my-dir></div>',
  directives: [
    MyDir,
  ],
)
class UnboundDirectiveInputComponent {}

@directive(
  selector: '[no-duplicate]',
)
class DuplicateDir {
  DuplicateDir(HtmlElement element) {
    element.text = '${element.text}noduplicate';
  }
}

@component(
  selector: 'duplicate-directives',
  template: '<div no-duplicate></div>',
  directives: [
    DuplicateDir,
    DuplicateDir,
  ],
)
class DuplicateDirectivesComponent {}

@directive(
  selector: '[id]',
)
class IdDir {
  @Input()
  String? id;
}

@component(
  selector: 'override-native-property',
  template: '<div [id]="value"></div>',
  directives: [
    IdDir,
  ],
)
class OverrideNativePropertyComponent {
  String value = 'some_id';

  @ViewChild(IdDir)
  IdDir? directive;
}

@directive(
  selector: '[customEvent]',
)
class EventDir {
  final _streamController = StreamController<String>();

  @Output()
  Stream<String> get customEvent => _streamController.stream;
}

@component(
  selector: 'event-directive',
  template: '<p (customEvent)="doNothing()"></p>',
  directives: [
    EventDir,
  ],
)
class EventDirectiveComponent {
  @ViewChild(EventDir)
  EventDir? directive;

  void doNothing() {}
}

@Injectable()
class PublicApi {}

@directive(
  selector: '[public-api]',
  providers: [
    Provider(PublicApi, useExisting: PrivateImpl),
  ],
)
class PrivateImpl extends PublicApi {}

@directive(
  selector: '[needs-public-api]',
)
class NeedsPublicApi {
  final PublicApi api;

  NeedsPublicApi(@Host() this.api);
}

@component(
  selector: 'retrieves-dependency-from-host',
  template: '<div public-api><div needs-public-api></div></div>',
  directives: [
    PrivateImpl,
    NeedsPublicApi,
  ],
)
class RetrievesDependencyFromHostComponent {
  @ViewChild(NeedsPublicApi)
  NeedsPublicApi? needsPublicApi;
}

@Pipe('double')
class DoublePipe {
  String transform(dynamic value) => '$value$value';
}

@component(
  selector: 'piped-directive-input',
  template: r'''
    <div my-dir #dir="myDir" [elProp]="$pipe.double(value)"></div>
    ''',
  directives: [
    MyDir,
  ],
  pipes: [
    DoublePipe,
  ],
)
class PipedDirectiveInputComponent {
  String value = 'a';

  @ViewChild('dir')
  MyDir? directive;
}
