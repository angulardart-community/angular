@JS()
library golden;

import 'package:js/js.dart';
import 'package:ngdart/angular.dart';

import 'on_push.template.dart' as ng;

/// Avoids Dart2JS thinking something is constant/unchanging.
@JS()
external T deopt<T>([Object? any]);

void main() {
  runApp(ng.createGoldenComponentFactory());
}

@Component(
  selector: 'golden',
  directives: [
    Child,
    ChildWithDoCheck,
  ],
  template: r'''
    <child [name]="name"></child>
    <child-with-do-check [name]="name"></child-with-do-check>
  ''',
  changeDetection: ChangeDetectionStrategy.onPush,
)
class GoldenComponent {
  String name = deopt();
}

@Component(
  selector: 'child',
  template: 'Name: {{name}}',
  changeDetection: ChangeDetectionStrategy.onPush,
)
class Child {
  @Input()
  String? name;
}

@Component(
  selector: 'child-with-do-check',
  template: 'Name: {{name}}',
  changeDetection: ChangeDetectionStrategy.onPush,
)
class ChildWithDoCheck implements DoCheck {
  @Input()
  String? name;

  @override
  void ngDoCheck() {}
}
