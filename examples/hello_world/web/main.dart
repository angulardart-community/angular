import 'package:angular/angular.dart';

import 'main.template.dart' as ng;

void main() => runApp(ng.HelloWorldComponentNgFactory);

@component(
  selector: 'hello-world',
  template: 'Hello World',
)
class HelloWorldComponent {}
