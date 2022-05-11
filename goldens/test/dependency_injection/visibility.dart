import 'package:angular/angular.dart';

import 'visibility.template.dart' as ng;

void main() {
  runApp(ng.createGoldenComponentFactory());
}

@component(
  selector: 'golden',
  directives: [
    HasVisibilityAll,
    HasVisibilityLocal,
  ],
  template: '''
    <has-visibility-all></has-visibility-all>
    <has-visibility-local></has-visibility-local>
  ''',
)
class GoldenComponent {}

@component(
  selector: 'has-visibility-all',
  template: '',
  visibility: Visibility.all,
)
class HasVisibilityAll {}

@component(
  selector: 'has-visibility-local',
  template: '',
)
class HasVisibilityLocal {}
