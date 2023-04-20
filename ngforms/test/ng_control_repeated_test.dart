// ignore_for_file: argument_type_not_assignable

import 'dart:async';

import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';
import 'package:ngtest/angular_test.dart';
import 'package:test/test.dart';

import 'ng_control_repeated_test.template.dart' as ng;

void main() {
  tearDown(disposeAnyRunningTest);

  // Regression test for https://github.com/angulardart/angular/issues/164.
  test('should update an NgForm without throwing an NPE', () async {
    final testBed = NgTestBed<AppComponent>(ng.createAppComponentFactory());
    expect(
      (await testBed.create()).rootElement.innerHtml,
      contains(r'<input title="Input #0:true">'),
    );
  });
}

@Component(
  selector: 'root',
  directives: [
    formDirectives,
    NgFor,
  ],
  template: r'''
    <form>
      <input *ngFor="let val of values; let idx = index"
             [ngModel]="val"
             ngControl="input-{{idx}}"
             title="Input #{{idx}}:{{val}}">
    </form>
  ''',
)
class AppComponent {
  late Iterable<String> values;
  bool b = false;

  AppComponent() {
    _update();
    Timer.run(_update);
  }

  void _update() {
    values = List.from([b.toString()]);
    print(values);
    b = !b;
  }
}
