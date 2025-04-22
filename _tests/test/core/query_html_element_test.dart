import 'package:ngdart/angular.dart';
import 'package:ngtest/angular_test.dart';
import 'package:test/test.dart';
import 'package:web/web.dart';

import 'query_html_element_test.template.dart' as ng;

void main() {
  tearDown(disposeAnyRunningTest);

  test('should support @ViewChild with Element', () async {
    final fixture =
        await NgTestBed<UsesElement>(ng.createUsesElementFactory()).create();
    expect(fixture.assertOnlyInstance.element!.textContent, '1');
  });

  test('should support @ViewChild with HTMLElement', () async {
    final fixture =
        await NgTestBed<UsesHTMLElement>(ng.createUsesHTMLElementFactory())
            .create();
    expect(fixture.assertOnlyInstance.element!.textContent, '2');
  });

  test('should support @ViewChildren with Element', () async {
    final fixture =
        await NgTestBed<UsesListOfElement>(ng.createUsesListOfElementFactory())
            .create();
    expect(fixture.assertOnlyInstance.elements!.map((e) => e.textContent),
        ['1', '2']);
  });

  test('should support @ViewChildren with HTMLElement', () async {
    final fixture = await NgTestBed<UsesListOfHTMLElement>(
            ng.createUsesListOfHTMLElementFactory())
        .create();
    expect(fixture.assertOnlyInstance.elements!.map((e) => e.textContent),
        ['1', '2']);
  });
}

@Component(
  selector: 'uses-element',
  template: '<div #div>1</div>',
)
class UsesElement {
  @ViewChild('div')
  Element? element;
}

@Component(
  selector: 'uses-element',
  template: '<div #div>2</div>',
)
class UsesHTMLElement {
  @ViewChild('div')
  HTMLElement? element;
}

@Component(
  selector: 'uses-list-of-element',
  template: '<div #div>1</div><div #div>2</div>',
)
class UsesListOfElement {
  @ViewChildren('div')
  List<Element>? elements;
}

@Component(
  selector: 'uses-list-of-element',
  template: '<div #div>1</div><div #div>2</div>',
)
class UsesListOfHTMLElement {
  @ViewChildren('div')
  List<HTMLElement>? elements;
}
