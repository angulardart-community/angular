// ignore_for_file: argument_type_not_assignable

import 'dart:html';

import 'package:test/test.dart';
import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';
import 'package:ngtest/angular_test.dart';

import 'ng_form_control_test.template.dart' as ng;

void main() {
  group('NgFormControlTest', () {
    late NgTestFixture<NgFormControlTest> fixture;

    tearDown(() => disposeAnyRunningTest());

    setUp(() async {
      var testBed =
          NgTestBed<NgFormControlTest>(ng.createNgFormControlTestFactory());
      fixture = await testBed.create();
    });

    void checkProperties(NgFormControl controlDir, Control control) {
      expect(controlDir.control, control);
      expect(controlDir.value, control.value);
      expect(controlDir.valid, control.valid);
      expect(controlDir.errors, control.errors);
      expect(controlDir.pristine, control.pristine);
      expect(controlDir.dirty, control.dirty);
      expect(controlDir.touched, control.touched);
      expect(controlDir.untouched, control.untouched);
    }

    test('should reexport control properties', () async {
      await fixture.update((cmp) {
        checkProperties(cmp.formControl!, cmp.loginControl);
      });
    });

    test('should reexport new control properties', () async {
      var newControl = Control(null);

      await fixture.update((cmp) {
        cmp.loginControl = newControl;
      });
      await fixture.update((cmp) {
        checkProperties(cmp.formControl!, newControl);
      });
    });

    test('should set up validator', () async {
      await fixture.update((cmp) {
        expect(cmp.loginControl.valid, false);
      });
    });

    test('should disable element', () async {
      expect(fixture.assertOnlyInstance.inputElement!.disabled, false);
      await fixture.update((cmp) => cmp.loginControl.markAsDisabled());
      expect(fixture.assertOnlyInstance.inputElement!.disabled, true);
      await fixture.update((cmp) => cmp.loginControl.markAsEnabled());
      expect(fixture.assertOnlyInstance.inputElement!.disabled, false);
    });
  });

  group('NgFormControlInitTest', () {
    late NgTestFixture<NgFormControlInitTest> fixture;

    tearDown(() => disposeAnyRunningTest());

    setUp(() async {
      var testBed = NgTestBed<NgFormControlInitTest>(
          ng.createNgFormControlInitTestFactory());
      fixture = await testBed.create();
    });

    test('should call writeValue once with init value', () async {
      await fixture.update((cmp) {
        final writeCalls = cmp.valueAccessor!.writeValueCalls;
        expect(writeCalls.length, 1);
        expect(writeCalls, ['Test']);
      });
    });
  });
}

@Component(
  selector: 'ng-form-control-test',
  directives: [
    formDirectives,
  ],
  template: '''
<div ngForm>
  <input [ngFormControl]="loginControl" #login="ngForm" #input required />
</div>
''',
)
class NgFormControlTest {
  @ViewChild('login')
  NgFormControl? formControl;

  @ViewChild('input')
  InputElement? inputElement;

  Control loginControl = Control(null);
}

@Directive(selector: '[dummy]', providers: [
  ExistingProvider.forToken(
    ngValueAccessor,
    DummyControlValueAccessor,
  )
])
class DummyControlValueAccessor implements ControlValueAccessor<dynamic> {
  final writeValueCalls = [];

  @override
  void writeValue(dynamic obj) {
    writeValueCalls.add(obj);
  }

  @override
  void registerOnChange(fn) {}
  @override
  void registerOnTouched(fn) {}
  @override
  void onDisabledChanged(bool isDisabled) {}
}

@Component(
  selector: 'ng-form-control-test',
  directives: [
    formDirectives,
    DummyControlValueAccessor,
  ],
  template: '''
<div ngForm>
  <input [ngFormControl]="loginControl" ngModel="Test" dummy />
</div>
''',
)
class NgFormControlInitTest {
  @ViewChild(DummyControlValueAccessor)
  DummyControlValueAccessor? valueAccessor;

  Control loginControl = Control('Test2');
}
