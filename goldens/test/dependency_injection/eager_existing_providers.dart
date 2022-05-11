@JS()
library golden;

import 'package:js/js.dart';
import 'package:angular/angular.dart';

import 'eager_existing_providers.template.dart' as ng;

/// Avoids Dart2JS thinking something is constant/unchanging.
@JS()
external T deopt<T>([Object? any]);

/// This golden demonstrates how existing providers are injected eagerly.
///
/// Note that its the act of injecting a provider from the same view in which
/// its defined that makes it eager. Providers which are unused locally are
/// lazy.
void main() {
  runApp(ng.createGoldenComponentFactory());
}

@component(
  selector: 'golden',
  directives: [
    InjectsServicesComponent,
    ProvidesServicesComponent,
  ],
  template: '''
    <provides-services>
      <injects-services></injects-services>
    </provides-services>
  ''',
)
class GoldenComponent {
  GoldenComponent(injector i) {
    deopt(i.get);
  }
}

abstract class EagerProviderA {}

abstract class EagerProviderB {}

abstract class LazyProviderA {}

abstract class LazyProviderB {}

@component(
  selector: 'provides-services',
  directives: [],
  providers: [
    ExistingProvider(EagerProviderA, ProvidesServicesComponent),
    ExistingProvider(EagerProviderB, ProvidesServicesComponent),
    ExistingProvider(LazyProviderA, ProvidesServicesComponent),
    ExistingProvider(LazyProviderB, ProvidesServicesComponent),
  ],
  template: '<ng-content></ng-content>',
)
class ProvidesServicesComponent
    implements EagerProviderA, EagerProviderB, LazyProviderA, LazyProviderB {}

@component(
  selector: 'injects-services',
  template: '',
)
class InjectsServicesComponent {
  InjectsServicesComponent(this.a, this.b);

  final EagerProviderA a;
  final EagerProviderB b;
}
