import 'package:test/test.dart';
import 'package:angular/angular.dart';
import 'package:angular_test/angular_test.dart';

import 'visibility_test.template.dart' as ng;

final throwsNoProviderError = throwsA(const TypeMatcher<NoProviderError>());

void main() {
  tearDown(disposeAnyRunningTest);

  group('Visibility', () {
    group('local', () {
      test('component should not be injectable by child component', () async {
        final testBed =
            NgTestBed(ng.createShouldFailToInjectParentComponentFactory());
        expect(testBed.create(), throwsNoProviderError);
      });

      test('directive should be accessible via a query', () async {
        final testBed = NgTestBed(ng.createShouldQueryDirectiveFactory());
        final testFixture = await testBed.create();
        expect(testFixture.assertOnlyInstance.directive, isNotNull);
      });

      test('directive should be injectable on same element', () async {
        final testBed = NgTestBed(ng.createShouldInjectFromElementFactory());
        final testFixture = await testBed.create();
        expect(testFixture.assertOnlyInstance.child!.directive, isNotNull);
      });

      test('directive should be injectable in same view', () async {
        final testBed = NgTestBed(ng.createShouldInjectFromViewFactory());
        final testFixture = await testBed.create();
        expect(testFixture.assertOnlyInstance.child!.directive, isNotNull);
      });

      test('directive should not be injectable in child view', () async {
        final testBed =
            NgTestBed(ng.createShouldFailToInjectFromParentViewFactory());
        expect(testBed.create(), throwsNoProviderError);
      });

      test('directive should inject host component', () async {
        final testBed = NgTestBed(ng.createShouldInjectHostFactory());
        final testFixture = await testBed.create();
        expect(testFixture.assertOnlyInstance.directive!.host, isNotNull);
      });

      test('service on Visibility.none component is injectable', () async {
        final testBed = NgTestBed(ng.createMyComponentWithServiceTestFactory());
        var testFixture = await testBed.create();
        expect(testFixture.rootElement, isNotNull);
      });

      test('component may provide itself via another token', () async {
        final testBed = NgTestBed(ng.createShouldInjectAliasedLocalFactory());
        final testFixture = await testBed.create();
        expect(testFixture.text, testFixture.assertOnlyInstance.text);
      });

      test('directive may provide itself for a multi-token', () async {
        final testBed = NgTestBed(ng.createShouldInjectMultiTokenFactory());
        final testFixture = await testBed.create();
        expect(testFixture.assertOnlyInstance.child!.dependencies, [
          const TypeMatcher<VisibilityLocalImplementation>(),
          const TypeMatcher<VisibilityAllImplementation>(),
        ]);
      });

      test('should support $FactoryProvider', () async {
        final testBed =
            NgTestBed(ng.createShouldSupportFactoryProviderFactory());
        final testFixture = await testBed.create();
        expect(testFixture.assertOnlyInstance.child!.interface, isNotNull);
      });

      test('should support $ClassProvider', () async {
        final testBed = NgTestBed(ng.createShouldSupportClassProviderFactory());
        final testFixture = await testBed.create();
        expect(testFixture.assertOnlyInstance.child!.interface, isNotNull);
      });
    });

    group('all', () {
      test('component should be injectable by child component', () async {
        final testBed =
            NgTestBed(ng.createShouldInjectParentComponentFactory());
        final testFixture = await testBed.create();
        final testComponent = testFixture.assertOnlyInstance;
        expect(testComponent.child!.parent, testComponent);
      });
    });
  });
}

@component(
  selector: 'injects-visibility-local',
  template: '',
)
class InjectsVisibilityLocalComponent {
  ShouldFailToInjectParentComponent parent;

  InjectsVisibilityLocalComponent(this.parent);
}

@component(
  selector: 'should-fail-to-inject-parent-component',
  template: '<injects-visibility-local></injects-visibility-local>',
  directives: [InjectsVisibilityLocalComponent],
)
class ShouldFailToInjectParentComponent {}

@directive(
  selector: '[visibility-none]',
)
class VisibilityNoneDirective {}

@component(
  selector: 'should-query-directive',
  template: '<div visibility-none></div>',
  directives: [VisibilityNoneDirective],
)
class ShouldQueryDirective {
  @ViewChild(VisibilityNoneDirective)
  VisibilityNoneDirective? directive;
}

@component(
  selector: 'injects-directive',
  template: '',
)
class InjectsDirectiveComponent {
  VisibilityNoneDirective directive;

  InjectsDirectiveComponent(this.directive);
}

@component(
  selector: 'should-fail-to-inject-from-element',
  template: '<injects-directive visibility-none></injects-directive>',
  directives: [InjectsDirectiveComponent, VisibilityNoneDirective],
)
class ShouldInjectFromElement {
  @ViewChild(InjectsDirectiveComponent)
  InjectsDirectiveComponent? child;
}

@component(
  selector: 'should-fail-to-inject-from-view',
  template: '''
  <div visibility-none>
    <injects-directive></injects-directive>
  </div>
  ''',
  directives: [InjectsDirectiveComponent, VisibilityNoneDirective],
)
class ShouldInjectFromView {
  @ViewChild(InjectsDirectiveComponent)
  InjectsDirectiveComponent? child;
}

@component(
  selector: 'injects-directive-host',
  template: '<injects-directive></injects-directive>',
  directives: [InjectsDirectiveComponent],
)
class InjectsDirectiveHostComponent {}

@component(
  selector: 'should-fail-to-inject-from-parent-view',
  template: '''
  <div visibility-none>
    <injects-directive-host></injects-directive-host>
  </div>
  ''',
  directives: [
    InjectsDirectiveHostComponent,
    VisibilityNoneDirective,
  ],
)
class ShouldFailToInjectFromParentView {}

@component(
  selector: 'visibility-local',
  template: '',
)
class VisibilityLocalComponent {}

@directive(selector: '[injects-visibility-local]')
class InjectsVisibilityLocal {
  final VisibilityLocalComponent host;

  InjectsVisibilityLocal(this.host);
}

@component(
  selector: 'test',
  template: '<visibility-local injects-visibility-local></visibility-local>',
  directives: [InjectsVisibilityLocal, VisibilityLocalComponent],
)
class ShouldInjectHost {
  @ViewChild(InjectsVisibilityLocal)
  InjectsVisibilityLocal? directive;
}

/// This service is exposed through a component that is marked Visibility.none.
/// The test verifies that injectorGet calls in compiler use the service not
/// useExisting token.
abstract class SomeService {
  void foo();
}

@component(
  selector: 'my-component-with-service-test',
  template: '''
    <child-component-provides-service>
      <div *dirNeedsService></div>
    </child-component-provides-service>
  ''',
  directives: [MyChildComponentProvidesService, MyDirectiveNeedsService],
)
class MyComponentWithServiceTest {}

@component(
  selector: 'child-component-provides-service',
  providers: [ExistingProvider(SomeService, MyChildComponentProvidesService)],
  template: '<div><ng-content></ng-content></div>',
)
class MyChildComponentProvidesService implements SomeService {
  @override
  void foo() {}
}

@directive(
  selector: '[dirNeedsService]',
)
class MyDirectiveNeedsService {
  final SomeService someService;

  MyDirectiveNeedsService(
      this.someService, viewContainerRef ref, templateRef templateRef);
}

abstract class Dependency {
  String get text;
}

@component(
  selector: 'should-inject-aliased-local',
  template: '<injects-aliased-local></injects-aliased-local>',
  directives: [InjectsAliasedLocal],
  providers: [
    ExistingProvider(Dependency, ShouldInjectAliasedLocal),
  ],
)
class ShouldInjectAliasedLocal extends Dependency {
  @override
  final String text = 'Hello';
}

@component(
  selector: 'injects-aliased-local',
  template: '{{dependency.text}}',
)
class InjectsAliasedLocal {
  final Dependency dependency;

  InjectsAliasedLocal(this.dependency);
}

@component(
  selector: 'injects-visibility-all',
  template: '',
)
class InjectsVisibilityAllComponent {
  final ShouldInjectParentComponent parent;

  InjectsVisibilityAllComponent(this.parent);
}

@component(
  selector: 'should-inject-parent-component',
  template: '<injects-visibility-all></injects-visibility-all>',
  directives: [InjectsVisibilityAllComponent],
  visibility: Visibility.all,
)
class ShouldInjectParentComponent {
  @ViewChild(InjectsVisibilityAllComponent)
  InjectsVisibilityAllComponent? child;
}

abstract class Interface {}

const implementations = MultiToken<Interface>();

@directive(
  selector: '[all]',
  providers: [
    ExistingProvider.forToken(
      implementations,
      VisibilityAllImplementation,
    ),
  ],
  visibility: Visibility.all,
)
class VisibilityAllImplementation implements Interface {}

@directive(
  selector: '[local]',
  providers: [
    ExistingProvider.forToken(
      implementations,
      VisibilityLocalImplementation,
    ),
  ],
)
class VisibilityLocalImplementation implements Interface {}

@component(
  selector: 'injects-multi-token',
  template: '',
)
class InjectsMultiToken {
  final List<Interface> dependencies;

  InjectsMultiToken(@implementations this.dependencies);
}

@component(
  selector: 'should-inject-multi-token',
  template: '<injects-multi-token local all></injects-multi-token>',
  directives: [
    InjectsMultiToken,
    VisibilityLocalImplementation,
    VisibilityAllImplementation,
  ],
)
class ShouldInjectMultiToken {
  @ViewChild(InjectsMultiToken)
  InjectsMultiToken? child;
}

Interface getInterfaceFromImpl(ShouldSupportFactoryProvider impl) => impl;

@component(
  selector: 'test',
  template: '<should-inject-interface></should-inject-interface>',
  directives: [
    ShouldInjectInterface,
  ],
  providers: [
    FactoryProvider(Interface, getInterfaceFromImpl),
  ],
)
class ShouldSupportFactoryProvider implements Interface {
  @ViewChild(ShouldInjectInterface)
  ShouldInjectInterface? child;
}

@component(
  selector: 'should-inject-interface',
  template: '',
)
class ShouldInjectInterface {
  Interface interface;
  ShouldInjectInterface(this.interface);
}

@component(
  selector: 'test',
  template: '<should-inject-interface></should-inject-interface>',
  directives: [
    ShouldInjectInterface,
  ],
  providers: [
    ClassProvider(Interface, useClass: ShouldSupportClassProvider),
  ],
)
class ShouldSupportClassProvider implements Interface {
  @ViewChild(ShouldInjectInterface)
  ShouldInjectInterface? child;
}
