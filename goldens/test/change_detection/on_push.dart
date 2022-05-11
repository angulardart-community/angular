@JS()
library golden;

import 'package:js/js.dart';
import 'package:angular/angular.dart';

import 'on_push.template.dart' as ng;

/// Avoids Dart2JS thinking something is constant/unchanging.
@JS()
external T deopt<T>([Object? any]);

void main() {
  runApp(ng.createGoldenComponentFactory());
}

@component(
  selector: 'golden',
  directives: [
    Child,
    ChildWithDoCheck,
  ],
  template: r'''
    <child [name]="name"></child>
    <child-with-do-check [name]="name"></child-with-do-check>
  ''',
  changeDetection: changeDetectionStrategy.OnPush,
)
class GoldenComponent {
  String name = deopt();
}

@component(
  selector: 'child',
  template: 'Name: {{name}}',
  changeDetection: changeDetectionStrategy.OnPush,
)
class Child {
  @Input()
  String? name;
}

@component(
  selector: 'child-with-do-check',
  template: 'Name: {{name}}',
  changeDetection: changeDetectionStrategy.OnPush,
)
class ChildWithDoCheck implements DoCheck {
  @Input()
  String? name;

  @override
  void ngDoCheck() {}
}
