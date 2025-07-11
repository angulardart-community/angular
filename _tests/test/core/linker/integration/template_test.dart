import 'dart:js_interop';

import 'package:ngdart/angular.dart';
import 'package:ngtest/angular_test.dart';
import 'package:test/test.dart';
import 'package:web/web.dart';

import 'template_test.template.dart' as ng;

void main() {
  tearDown(disposeAnyRunningTest);

  test('should support template directives via <template> elements', () async {
    final testBed = NgTestBed<TemplateDirectiveComponent>(
        ng.createTemplateDirectiveComponentFactory());
    final testFixture = await testBed.create();
    // 1 template + 2 copies.
    expect(testFixture.rootElement.childNodes.length, equals(3));
    expect(testFixture.rootElement.childNodes.item(1)!.textContent, 'hello');
    expect(testFixture.rootElement.childNodes.item(2)!.textContent, 'again');
  });

  test('should not detach views when parent is destroyed', () async {
    final testBed = NgTestBed<DestroyParentViewComponent>(
        ng.createDestroyParentViewComponentFactory());
    final testFixture = await testBed.create();
    final ngIfElement = testFixture.rootElement.children.item(0)!;
    final someViewport = testFixture.assertOnlyInstance.viewport!;
    expect(ngIfElement.children, hasLength(2));
    expect(someViewport.container, hasLength(2));
    await testFixture.update((component) => component.visible = false);
    expect(testFixture.rootElement.children, hasLength(0));
    expect(someViewport.container, hasLength(2));
  });

  test('should use a comment while stamping out <template> elements', () async {
    final testBed = NgTestBed<EmptyTemplateComponent>(
        ng.createEmptyTemplateComponentFactory());
    final testFixture = await testBed.create();
    final childNodes = testFixture.rootElement.childNodes;
    expect(childNodes, hasLength(1));
    expect(childNodes.item(0).isA<Comment>(), isTrue);
  });

  test('should transplant TemplateRef into another ViewContainer', () async {
    final testBed = NgTestBed<TemplateRefTransplantComponent>(
        ng.createTemplateRefTransplantComponentFactory());
    final testFixture = await testBed.create();
    expect(testFixture.text,
        'From component,From toolbar,Component with an injected host');
  });
}

@Directive(
  selector: '[some-viewport]',
)
class SomeViewport {
  final ViewContainerRef container;

  SomeViewport(this.container, TemplateRef templateRef) {
    container.createEmbeddedView(templateRef).setLocal('some-tmpl', 'hello');
    container.createEmbeddedView(templateRef).setLocal('some-tmpl', 'again');
  }
}

@Component(
  selector: 'template-directive',
  template:
      '<template some-viewport let-x="some-tmpl"><div>{{x}}</div></template>',
  directives: [
    SomeViewport,
  ],
)
class TemplateDirectiveComponent {}

@Component(
  selector: 'destroy-parent-view',
  template: '<div *ngIf="visible">'
      '<template some-viewport let-x="someTmpl"><span>{{x}}</span></template>'
      '</div>',
  directives: [
    NgIf,
    SomeViewport,
  ],
)
class DestroyParentViewComponent {
  bool visible = true;

  @ViewChild(SomeViewport)
  SomeViewport? viewport;
}

@Component(
  selector: 'empty-template',
  template: '<template></template>',
)
class EmptyTemplateComponent {}

@Directive(
  selector: '[toolbarpart]',
)
class ToolbarPart {
  final TemplateRef templateRef;

  ToolbarPart(this.templateRef);
}

@Directive(
  selector: '[toolbarVc]',
)
class ToolbarViewContainer {
  final ViewContainerRef vc;

  ToolbarViewContainer(this.vc);

  @Input()
  set toolbarVc(ToolbarPart part) {
    final view = vc.insertEmbeddedView(part.templateRef, 0);
    view.setLocal('toolbarProp', 'From toolbar');
  }
}

@Component(
  selector: 'toolbar',
  template: '<div *ngFor="let part of query" [toolbarVc]="part"></div>',
  directives: [
    NgFor,
    ToolbarViewContainer,
  ],
)
class ToolbarComponent {
  @ContentChildren(ToolbarPart)
  List<ToolbarPart>? query;

  String prop = 'hello world';
}

@Directive(
  selector: 'some-directive',
  visibility: Visibility.all,
)
class SomeDirective {}

@Component(
  selector: 'cmp-with-host',
  template: '<p>Component with an injected host</p>',
  directives: [SomeDirective],
)
class CompWithHost {
  SomeDirective myHost;

  CompWithHost(@Host() this.myHost);
}

@Component(
  selector: 'template-ref-transplant',
  template: '<some-directive><toolbar>'
      '<template toolbarpart let-toolbarProp="toolbarProp">'
      '{{prop}},{{toolbarProp}},<cmp-with-host></cmp-with-host>'
      '</template>'
      '</toolbar></some-directive>',
  directives: [
    CompWithHost,
    SomeDirective,
    ToolbarComponent,
    ToolbarPart,
  ],
)
class TemplateRefTransplantComponent {
  String prop = 'From component';
}
