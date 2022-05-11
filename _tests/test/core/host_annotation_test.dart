import 'dart:html';

import 'package:angular/angular.dart';
import 'package:angular_test/angular_test.dart';
import 'package:test/test.dart';

import 'host_annotation_test.template.dart' as ng;

void main() {
  tearDown(disposeAnyRunningTest);

  /// Returns the root [Element] created by initializing [component].
  Future<Element> rootElementOf<T extends Object>(
    ComponentFactory<T> component,
  ) {
    final testBed = NgTestBed(component);
    return testBed.create().then((fixture) => fixture.rootElement);
  }

  group('@HostBinding', () {
    test('should assign "title" based on a static', () async {
      final element = await rootElementOf(
        ng.createHostBindingStaticTitleFactory(),
      );
      expect(element.title, 'Hello World');
    });

    test('should assign "title" based on an instance member', () async {
      final element = await rootElementOf(
        ng.createHostBindingInstanceTitleFactory(),
      );
      expect(element.title, 'Hello World');
    });

    test('should *not* assign "title" based on an inherited static', () async {
      // The language does not inherit static members, so AngularDart inheriting
      // them would (a) seem out of place and (b) make the compilation process
      // for these bindings considerably more complex.
      //
      // This test verifies that nothing is inherited. A user can always use an
      // instance getter or field and everything would work exactly as intended.
      //
      // https://github.com/angulardart/angular/issues/1272
      final element = await rootElementOf(
        ng.createHostBindingStaticTitleNotInheritedFactory(),
      );
      expect(element.title, isEmpty);
    });

    test('should assign "title" based on an inherited instance', () async {
      final element = await rootElementOf(
        ng.createHostBindingInstanceTitleInheritedFactory(),
      );
      expect(element.title, 'Hello World');
    });

    test('should support tabIndex of 0', () async {
      final element = await rootElementOf(
        ng.createHostBindingTabIndex0Factory(),
      );
      expect(element.tabIndex, 0);
    });

    test('should support tabIndex of 0', () async {
      final element = await rootElementOf(
        ng.createHostBindingTabIndexNegative1Factory(),
      );
      expect(element.tabIndex, -1);
    });

    test('should support class [static]', () async {
      final element = await rootElementOf(
        ng.createHostBindingStaticClassFactory(),
      );
      expect(element.className, 'themeable');
    });

    test('should support class [instance]', () async {
      final element = await rootElementOf(
        ng.createHostBindingInstanceClassFactory(),
      );
      expect(element.className, 'themeable');
    });

    test('should support conditional attributes', () async {
      final testBed = NgTestBed(
        ng.createHostBindingConditionalAttributeFactory(),
      );
      final fixture = await testBed.create();
      final element = fixture.rootElement;
      expect(element.attributes, isNot(contains('disabled')));
      expect(element.attributes, isNot(contains('aria-disabled')));

      await fixture.update((c) => c.disabledBackingValue = true);
      expect(element.attributes, contains('disabled'));
      expect(element.attributes, contains('aria-disabled'));

      await fixture.update((c) => c.disabledBackingValue = false);
      expect(element.attributes, isNot(contains('disabled')));
      expect(element.attributes, isNot(contains('aria-disabled')));
    });

    test('should support conditional attributes on static members', () async {
      final testBed = NgTestBed(
        ng.createHostBindingConditionalStaticsFactory(),
      );
      final fixture = await testBed.create();
      final element = fixture.rootElement;
      expect(element.attributes, contains('disabled'));
      expect(element.attributes, contains('aria-disabled'));
    });

    test('should support conditional classes', () async {
      final testBed = NgTestBed(
        ng.createHostBindingConditionalClassFactory(),
      );
      final fixture = await testBed.create();
      final element = fixture.rootElement;
      expect(element.classes, isNot(contains('fancy')));

      await fixture.update((c) => c.fancy = true);
      expect(element.classes, contains('fancy'));

      await fixture.update((c) => c.fancy = false);
      expect(element.classes, isNot(contains('fancy')));
    });

    test('should support multiple annotations on a single field', () async {
      final element = await rootElementOf(ng.createHostBindingMultiFactory());
      expect(element.className, 'hello');
      expect(element.title, 'hello');
    });
  });

  group('@HostListener', () {
    test('should support click', () async {
      final testBed = NgTestBed(
        ng.createHostListenerClickFactory(),
      );
      final fixture = await testBed.create();
      fixture.assertOnlyInstance.clickHandler = expectAsync0(() {});
      await fixture.update((_) => fixture.rootElement.click());
    });

    test('should support click through inheritance', () async {
      final testBed = NgTestBed(
        ng.createHostListenerInheritedClickFactory(),
      );
      final fixture = await testBed.create();
      fixture.assertOnlyInstance.clickHandler = expectAsync0(() {});
      await fixture.update((_) => fixture.rootElement.click());
    });

    test('should support multiple annotations on a single field', () async {
      final testBed = NgTestBed(
        ng.createHostListenerMultiFactory(),
      );
      final fixture = await testBed.create();
      fixture.assertOnlyInstance.blurOrFocusHandler = expectAsync0(
        () {},
        count: 2,
      );
      await fixture.update((_) {
        fixture.rootElement.dispatchEvent(FocusEvent('focus'));
      });
      await fixture.update((_) {
        fixture.rootElement.dispatchEvent(FocusEvent('blur'));
      });
    });
  });
}

@Component(  selector: 'host-binding-static',
  template: '',
)
class HostBindingStaticTitle {
  @HostBinding('title')
  static const hostTitle = 'Hello World';
}

@Component(  selector: 'host-binding-instance',
  template: '',
)
class HostBindingInstanceTitle {
  @HostBinding('title')
  final hostTitle = 'Hello World';
}

@Component(  selector: 'host-binding-static-not-inherited',
  template: '',
)
class HostBindingStaticTitleNotInherited extends HostBindingStaticTitle {}

@Component(  selector: 'host-binding-instance-inherited',
  template: '',
)
class HostBindingInstanceTitleInherited extends HostBindingInstanceTitle {}

@Component(  selector: 'host-binding-tab-index',
  template: '',
)
class HostBindingTabIndex0 {
  @HostBinding('tabIndex')
  static const hostTabIndex = 0;
}

@Component(  selector: 'host-binding-tab-index',
  template: '',
)
class HostBindingTabIndexNegative1 {
  @HostBinding('tabIndex')
  static const hostTabIndex = -1;
}

@Component(  selector: 'host-binding-static-class',
  template: '',
)
class HostBindingStaticClass {
  @HostBinding('class')
  static const hostClass = 'themeable';
}

@Component(  selector: 'host-binding-static-class',
  template: '',
)
class HostBindingInstanceClass {
  @HostBinding('class')
  var hostClass = 'themeable';
}

@Component(  selector: 'host-binding-conditional-attribute',
  template: '',
)
class HostBindingConditionalAttribute {
  // Old Style
  @HostBinding('attr.disabled')
  String? get disabled => disabledBackingValue ? 'disabled' : null;

  // New Style
  @HostBinding('attr.aria-disabled.if')
  bool disabledBackingValue = false;
}

@Component(  selector: 'host-binding-conditional-attribute-statics',
  template: '',
)
class HostBindingConditionalStatics {
  @HostBinding('attr.disabled.if')
  static const bool disabled = true;

  // An example of using a getter instead of a field.
  @HostBinding('attr.aria-disabled.if')
  static bool get ariaDisabled => disabled;
}

@Component(  selector: 'host-binding-conditional-attribute',
  template: '',
)
class HostBindingConditionalClass {
  @HostBinding('class.fancy')
  var fancy = false;
}

@Component(  selector: 'host-binding-multi',
  template: '',
)
class HostBindingMulti {
  @HostBinding('class')
  @HostBinding('title')
  static const hostClassAndTitle = 'hello';
}

@Component(  selector: 'host-listener-click',
  template: '',
)
class HostListenerClick {
  @HostListener('click')
  void onClick() => clickHandler();

  /// To be provided in test cases.
  /// ignore: prefer_function_declarations_over_variables
  void Function() clickHandler = () => throw UnimplementedError();
}

@Component(  selector: 'host-listener-inherited-click',
  template: '',
)
class HostListenerInheritedClick extends HostListenerClick {}

@Component(  selector: 'host-listener-multi',
  template: '',
)
class HostListenerMulti {
  @HostListener('blur')
  @HostListener('focus')
  void onBlurOrFocus() => blurOrFocusHandler();

  /// To be provided in test cases.
  /// ignore: prefer_function_declarations_over_variables
  void Function() blurOrFocusHandler = () => throw UnimplementedError();
}
