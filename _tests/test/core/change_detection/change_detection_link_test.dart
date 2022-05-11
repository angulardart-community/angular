import 'package:test/test.dart';
import 'package:angular/angular.dart';
import 'package:angular/experimental.dart';
import 'package:angular_test/angular_test.dart';

import 'change_detection_link_test.template.dart' as ng;

void main() {
  tearDown(disposeAnyRunningTest);

  group('CheckAlways component should always be checked when loaded', () {
    late MutableState state;

    setUp(() {
      state = MutableState('Initial value');
    });

    Future<void> testComponent(
      componentFactory<Object> componentFactory,
    ) async {
      final testBed = NgTestBed(
        componentFactory,
        rootInjector: (parent) {
          return injector.map({MutableState: state}, parent);
        },
      );
      final testFixture = await testBed.create();
      expect(testFixture.text, 'Initial value');
      await testFixture.update((_) {
        state.value = 'Changed value';
      });
      expect(testFixture.text, 'Changed value');
    }

    // CheckAlways component -------.
    //                    |         |
    //   (passes factory) |         |
    //                    v         |
    //        @changeDetectionLink  | (change detection link)
    //        OnPush component      |
    //                    |         |
    //    (loads factory) |         |
    //                    v         v
    //                CheckAlways component
    //
    test('in a @changeDetectionLink OnPush component', () {
      return testComponent(ng.createLoadInOnPushFactory());
    });

    // CheckAlways component -------.
    //                    |         |
    //   (passes factory) |         |
    //                    v         |
    //        @changeDetectionLink  |
    //        OnPush component      |
    //                    |         |
    //   (passes factory) |         | (change detection link)
    //                    v         |
    //        @changeDetectionLink  |
    //        OnPush component      |
    //                    |         |
    //    (loads factory) |         |
    //                    v         v
    //                CheckAlways component
    //
    test('through multiple @changeDetectionLink OnPush components', () {
      return testComponent(ng.createLoadInOnPushDescendantFactory());
    });

    // CheckAlways component -------.
    //                    |         |
    //   (passes factory) |         |
    //                    v         |
    //        @changeDetectionLink  |
    //        OnPush component      |
    //                    |         |
    //   (loads template) |         | (change detection link)
    //                    v         |
    //              embedded view   |
    //                    |         |
    //    (loads factory) |         |
    //                    v         v
    //                CheckAlways component
    //
    test('in an embedded view of a @changeDetectionLink OnPush component', () {
      return testComponent(ng.createLoadInOnPushEmbeddedViewFactory());
    });
  });
}

/// A shared model whose internal state is mutable.
class MutableState {
  MutableState(this.value);

  String value;
}

/// A component that relies on default change detection to observe mutations.
@component(
  selector: 'default',
  template: '{{state.value}}',
)
class DefaultComponent {
  DefaultComponent(this.state);

  final MutableState state;
}

@changeDetectionLink
@component(
  selector: 'on-push-container',
  template: '<template #container></template>',
  changeDetection: changeDetectionStrategy.OnPush,
)
class OnPushContainerComponent {
  @Input()
  set componentFactory(componentFactory<Object>? value) {
    viewContainerRef!.createComponent(value!);
  }

  @ViewChild('container', read: viewContainerRef)
  viewContainerRef? viewContainerRef;
}

@component(
  selector: 'test',
  template: '''
    <on-push-container [componentFactory]="defaultComponentFactory">
    </on-push-container>
  ''',
  directives: [OnPushContainerComponent],
)
class LoadInOnPush {
  static final defaultComponentFactory = ng.createDefaultComponentFactory();
}

@changeDetectionLink
@component(
  selector: 'on-push-ancestor',
  template: '''
    <on-push-container [componentFactory]="componentFactory">
    </on-push-container>
  ''',
  directives: [OnPushContainerComponent],
  changeDetection: changeDetectionStrategy.OnPush,
)
class OnPushAncestorComponent {
  @Input()
  componentFactory<Object>? componentFactory;
}

@component(
  selector: 'test',
  template: '''
    <on-push-ancestor [componentFactory]="defaultComponentFactory">
    </on-push-ancestor>
  ''',
  directives: [OnPushAncestorComponent],
)
class LoadInOnPushDescendant {
  static final defaultComponentFactory = ng.createDefaultComponentFactory();
}

@changeDetectionLink
@component(
  selector: 'on-push-embedded-container',
  template: '''
    <ng-container *ngIf="isContainerVisible">
      <template #container></template>
    </ng-container>
  ''',
  directives: [NgIf],
  changeDetection: changeDetectionStrategy.OnPush,
)
class OnPushEmbeddedContainerComponent {
  OnPushEmbeddedContainerComponent(this._changeDetectorRef, this._ngZone);

  final changeDetectorRef _changeDetectorRef;
  final NgZone _ngZone;

  var isContainerVisible = true;

  @Input()
  componentFactory<Object>? componentFactory;

  @ViewChild('container', read: viewContainerRef)
  set viewContainerRef(viewContainerRef? value) {
    if (value != null) {
      _ngZone.runAfterChangesObserved(() {
        value
          ..clear()
          ..createComponent(componentFactory!);
        _changeDetectorRef.markForCheck();
      });
    }
  }
}

@component(
  selector: 'test',
  template: '''
    <on-push-embedded-container [componentFactory]="defaultComponentFactory">
    </on-push-embedded-container>
  ''',
  directives: [OnPushEmbeddedContainerComponent],
)
class LoadInOnPushEmbeddedView {
  static final defaultComponentFactory = ng.createDefaultComponentFactory();
}
