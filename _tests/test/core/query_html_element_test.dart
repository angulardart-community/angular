import 'dart:html';

import 'package:test/test.dart';
import 'package:angular/angular.dart';
import 'package:angular_test/angular_test.dart';

import 'query_html_element_test.template.dart' as ng;

void main() {
  tearDown(disposeAnyRunningTest);

  test('should support @ViewChild with Element', () async {
    final fixture = await NgTestBed(ng.createUsesElementFactory()).create();
    expect(fixture.assertOnlyInstance.element!.text, '1');
  });

  test('should support @ViewChild with HtmlElement', () async {
    final fixture = await NgTestBed(ng.createUsesHtmlElementFactory()).create();
    expect(fixture.assertOnlyInstance.element!.text, '2');
  });

  test('should support @ViewChildren with Element', () async {
    final fixture =
        await NgTestBed(ng.createUsesListOfElementFactory()).create();
    expect(fixture.assertOnlyInstance.elements!.map((e) => e.text), ['1', '2']);
  });

  test('should support @ViewChildren with HtmlElement', () async {
    final fixture =
        await NgTestBed(ng.createUsesListOfHtmlElementFactory()).create();
    expect(fixture.assertOnlyInstance.elements!.map((e) => e.text), ['1', '2']);
  });
}

@component(
  selector: 'uses-element',
  template: '<div #div>1</div>',
)
class UsesElement {
  @ViewChild('div')
  Element? element;
}

@component(
  selector: 'uses-element',
  template: '<div #div>2</div>',
)
class UsesHtmlElement {
  @ViewChild('div')
  HtmlElement? element;
}

@component(
  selector: 'uses-list-of-element',
  template: '<div #div>1</div><div #div>2</div>',
)
class UsesListOfElement {
  @ViewChildren('div')
  List<Element>? elements;
}

@component(
  selector: 'uses-list-of-element',
  template: '<div #div>1</div><div #div>2</div>',
)
class UsesListOfHtmlElement {
  @ViewChildren('div')
  List<HtmlElement>? elements;
}
