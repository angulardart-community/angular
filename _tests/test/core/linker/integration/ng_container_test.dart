import 'package:_tests/matchers.dart';
import 'package:ngdart/angular.dart';
import 'package:ngtest/angular_test.dart';
import 'package:test/test.dart';

// ignore: uri_has_not_been_generated
import 'ng_container_test.template.dart' as ng;

void main() {
  tearDown(disposeAnyRunningTest);

  test('renders nothing', () async {
    final testBed = NgTestBed<RendersNothing>(ng.createRendersNothingFactory());
    final testFixture = await testBed.create();
    expect(testFixture.rootElement.childNodes, isEmpty);
  });

  test('renders children in place of self', () async {
    final testBed =
        NgTestBed<RendersChildren>(ng.createRendersChildrenFactory());
    final testFixture = await testBed.create();
    expect(testFixture.rootElement, hasInnerHtml(html));
  });

  test('supports *ngFor', () async {
    final testBed = NgTestBed<SupportsNgFor>(ng.createSupportsNgForFactory());
    final testFixture = await testBed.create();
    expect(testFixture.rootElement, hasInnerHtml(anchorHtml));
    final values = ['a', 'b', 'c'];
    final html = values.join();
    await testFixture.update((component) => component.values.addAll(values));
    expect(testFixture.rootElement, hasInnerHtml('$anchorHtml$html'));
  });

  test('supports *ngIf', () async {
    final testBed = NgTestBed<SupportsNgIf>(ng.createSupportsNgIfFactory());
    final testFixture = await testBed.create();
    expect(testFixture.rootElement, hasInnerHtml(anchorHtml));
    await testFixture.update((component) => component.visible = true);
    expect(testFixture.rootElement, hasInnerHtml('$anchorHtml$html'));
  });

  test('supports *ngTemplateOutlet', () async {
    final testBed = NgTestBed<SupportsNgTemplateOutlet>(
        ng.createSupportsNgTemplateOutletFactory());
    final testFixture = await testBed.create();
    expect(
        testFixture.rootElement,
        hasInnerHtml('$anchorHtml ' // <template #ref> anchor
            '$anchorHtml' // <template> and ViewContainerRef anchor for *-directive
            '${testFixture.assertOnlyInstance.context['message']}'));
  });

  test('supports nested *-syntax', () async {
    final testBed =
        NgTestBed<SupportsNesting>(ng.createSupportsNestingFactory());
    final testFixture = await testBed.create();
    expect(testFixture.rootElement, hasInnerHtml(anchorHtml));
    await testFixture.update((component) => component.integers = [1, 2, 3]);
    expect(
      testFixture.rootElement,
      hasInnerHtml(
        '$anchorHtml' // NgFor
        '$anchorHtml' // NgIf true
        '<li>1</li>'
        '$anchorHtml' // NgIf true
        '<li>2</li>'
        '$anchorHtml' // NgIf true
        '<li>3</li>',
      ),
    );
    await testFixture.update((component) => component.filterOdd = true);
    expect(
      testFixture.rootElement,
      hasInnerHtml(
        '$anchorHtml' // NgFor
        '$anchorHtml' // NgIf false
        '$anchorHtml' // NgIf true
        '<li>2</li>'
        '$anchorHtml', // NgIf false
      ),
    );
  });

  test('can be projected', () async {
    final testBed = NgTestBed<CanBeProjected>(ng.createCanBeProjectedFactory());
    final testFixture = await testBed.create();
    expect(testFixture.rootElement,
        hasInnerHtml('<content-host>$anchorHtml$html</content-host>'));
    await testFixture.update((component) => component.visible = false);
    expect(testFixture.rootElement,
        hasInnerHtml('<content-host>$anchorHtml</content-host>'));
  });

  test('can host projected content', () async {
    final testBed = NgTestBed<CanHostProjectedContent>(
        ng.createCanHostProjectedContentFactory());
    final testFixture = await testBed.create();
    expect(testFixture.rootElement,
        hasInnerHtml('<contained-content-host>$html</contained-content-host>'));
  });
}

const anchorHtml = '<!---->';
const html = '<span>Hello!</span>';

@Component(
  selector: 'test',
  template: '<ng-container></ng-container>',
)
class RendersNothing {}

@Component(
  selector: 'test',
  template: '<ng-container>$html</ng-container>',
)
class RendersChildren {}

@Component(
  selector: 'test',
  template: '''
    <ng-container *ngFor="let value of values">
      {{value}}
    </ng-container>
  ''',
  directives: [NgFor],
)
class SupportsNgFor {
  List<String> values = [];
}

@Component(
  selector: 'test',
  template: '<ng-container *ngIf="visible">$html</ng-container>',
  directives: [NgIf],
)
class SupportsNgIf {
  bool visible = false;
}

@Component(
  selector: 'test',
  template: '''
    <template #ref let-msg="message">{{msg}}</template>
    <ng-container *ngTemplateOutlet="ref; context: context"></ng-container>
  ''',
  directives: [NgTemplateOutlet],
)
class SupportsNgTemplateOutlet {
  Map<String, dynamic> context = {'message': 'Hello'};
}

@Component(
  selector: 'test',
  template: '''
    <ng-container *ngFor="let i of integers">
      <li *ngIf="!filterOdd || i.isEven">
        {{i}}
      </li>
    </ng-container>
  ''',
  directives: [NgFor, NgIf],
)
class SupportsNesting {
  List<int> integers = [];
  bool filterOdd = false;
}

@Component(
  selector: 'content-host',
  template: '<ng-content></ng-content>',
)
class ContentHost {}

@Component(
  selector: 'test',
  template: '''
    <content-host>
      <ng-container *ngIf="visible">$html</ng-container>
    </content-host>
  ''',
  directives: [ContentHost, NgIf],
)
class CanBeProjected {
  bool visible = true;
}

@Component(
  selector: 'contained-content-host',
  template: '<ng-container><ng-content></ng-content></ng-container>',
)
class ContainedContentHost {}

@Component(
  selector: 'test',
  template: '<contained-content-host>$html</contained-content-host>',
  directives: [ContainedContentHost],
)
class CanHostProjectedContent {}
