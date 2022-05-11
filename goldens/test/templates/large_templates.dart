@JS()
library golden;

// This code is roughly intended to reflect large-internal clients, i.e.
// https://source.corp.google.com/piper///depot/google3/ads/awapps2/cm/client/overview/root/lib/overview.template.dart

import 'package:js/js.dart';
import 'package:angular/angular.dart';

import 'large_templates.template.dart' as ng;

/// Avoids Dart2JS thinking something is constant/unchanging.
@JS()
external T deopt<T>([Object? any]);

void main() {
  runApp(ng.createGoldenComponentFactory());
}

@component(
  selector: 'golden',
  directives: [
    ChildComponent,
    NgIf,
  ],
  template: '''
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
    <child *ngIf="isLoading"></child>
  ''',
)
class GoldenComponent {
  bool get isLoading => deopt();
}

@component(
  selector: 'child',
  template: '',
)
class ChildComponent {}
