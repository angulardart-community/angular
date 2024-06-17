@JS()
library golden;

import 'dart:js_interop';
import 'package:ngdart/angular.dart';

import 'default.template.dart' as ng;

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
)
class GoldenComponent {
  String name = deopt('World');
}

@Component(
  selector: 'child',
  template: 'Name: {{name}}',
)
class Child {
  @Input()
  String? name;
}

@Component(
  selector: 'child-with-do-check',
  template: 'Name: {{name}}',
)
class ChildWithDoCheck implements DoCheck {
  @Input()
  String? name;

  @override
  void ngDoCheck() {}
}
