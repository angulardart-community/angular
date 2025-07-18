import 'dart:js_interop';

import 'package:ngdart/angular.dart';
import 'package:ngtest/angular_test.dart';
import 'package:test/test.dart';
import 'package:web/web.dart';

import 'bed_lifecycle_test.template.dart' as ng;

void main() {
  late Element docRoot;
  late Element testRoot;

  setUp(() {
    docRoot = document.createElement('doc-root');
    testRoot = document.createElement('ng-test-bed-example-test');
    docRoot.append(testRoot);
  });

  tearDown(disposeAnyRunningTest);

  test('should render, update, and destroy a component', () async {
    // We are going to verify that the document root has a new node created (our
    // component), the node is updated (after change detection), and after
    // destroying the test the document root has been cleared.
    final testBed = NgTestBed<AngularLifecycle>(
      ng.createAngularLifecycleFactory(),
      host: testRoot,
    );
    final NgTestFixture<AngularLifecycle> fixture = await testBed.create();
    expect(docRoot.textContent, isEmpty);
    await fixture.update((c) => c.value = 'New value');
    expect(docRoot.textContent, equals('New value'));
    await fixture.dispose();
    print((docRoot.innerHTML as JSString).toDart);
    expect(docRoot.textContent, isEmpty);
  });

  test('should invoke ngAfterChanges, then ngOnInit', () async {
    final NgTestFixture<NgAfterChangesInitOrder> fixture =
        await NgTestBed<NgAfterChangesInitOrder>(
      ng.createNgAfterChangesInitOrderFactory(),
    ).create(
      beforeChangeDetection: (NgAfterChangesInitOrder root) =>
          root.name = 'Hello',
    );
    expect(
      fixture.assertOnlyInstance.child!.events,
      ['AfterChanges:name=Hello', 'OnInit'],
    );
  });

  test(
      'should invoke ngAfterChanges with asynchronous beforeChangeDetection,'
      ' then ngOnInit', () async {
    final NgTestFixture<NgAfterChangesInitOrder> fixture =
        await NgTestBed<NgAfterChangesInitOrder>(
      ng.createNgAfterChangesInitOrderFactory(),
    ).create(
      beforeChangeDetection: (NgAfterChangesInitOrder root) async =>
          root.name = 'Hello',
    );
    expect(
      fixture.assertOnlyInstance.child!.events,
      ['AfterChanges:name=Hello', 'OnInit'],
    );
  });
}

@Component(
  selector: 'test',
  template: '{{value}}',
)
class AngularLifecycle {
  String value = '';
}

@Component(
  selector: 'test',
  directives: [ChildWithLifeCycles],
  template: '<child [name]="name"></child>',
)
class NgAfterChangesInitOrder {
  String? name;

  @ViewChild(ChildWithLifeCycles)
  ChildWithLifeCycles? child;
}

@Component(
  selector: 'child',
  template: '',
  visibility: Visibility.all,
)
class ChildWithLifeCycles implements AfterChanges, OnInit {
  final events = <String>[];

  @Input()
  String? name = '';

  @override
  void ngAfterChanges() {
    events.add('AfterChanges:name=$name');
  }

  @override
  void ngOnInit() {
    events.add('OnInit');
  }
}
