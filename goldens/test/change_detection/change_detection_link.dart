@JS()
library golden;

import 'package:js/js.dart';
import 'package:angular/angular.dart';
import 'package:angular/experimental.dart';

import 'change_detection_link.template.dart' as ng;

/// Avoids Dart2JS thinking something is constant/unchanging.
@JS()
external T deopt<T>([Object? any]);

void main() {
  runApp(ng.createGoldenComponentFactory());
}

/// This demonstrates the code generated to implement `@changeDetectionLink`.
///
/// In practice, you'd only use `@changeDetectionLink` if this component were
/// passing a [componentFactory] that loads another Default component to its
/// OnPush descendants. However, this isn't needed to generate the code in
/// interest.
@component(
  selector: 'golden',
  template: '''
    <on-push-link></on-push-link>
  ''',
  directives: [OnPushLink],
)
class GoldenComponent {}

@changeDetectionLink
@component(
  selector: 'on-push-link',
  template: '''
    <template #container></template>
    <ng-container *ngIf="isVisible">
      <template #embeddedContainer></template>
    </ng-container>
    <nested-on-push></nested-on-push>
    <nested-on-push-link></nested-on-push-link>
    <nested-on-push-link *ngIf="isVisible"></nested-on-push-link>
  ''',
  directives: [
    NestedOnPush,
    NestedOnPushLink,
    NgIf,
  ],
  changeDetection: changeDetectionStrategy.OnPush,
)
class OnPushLink {
  @ViewChild('container', read: viewContainerRef)
  set container(viewContainerRef? _) => deopt(_);

  @ViewChild('embeddedContainer', read: viewContainerRef)
  set embeddedContainer(viewContainerRef? _) => deopt(_);

  bool isVisible = deopt();
}

// Should not be linked.
@component(
  selector: 'nested-on-push',
  template: '',
  changeDetection: changeDetectionStrategy.OnPush,
)
class NestedOnPush {}

@changeDetectionLink
@component(
  selector: 'nested-on-push-link',
  template: '''
    <template #container></template>
  ''',
  changeDetection: changeDetectionStrategy.OnPush,
)
class NestedOnPushLink {
  @ViewChild('container', read: viewContainerRef)
  set container(viewContainerRef? _) => deopt(_);
}
