import 'package:mockito/annotations.dart';
import 'package:ngforms/ngforms.dart';
import 'package:ngforms/src/directives/shared.dart';
import 'package:test/test.dart';
import 'package:web/web.dart';

@GenerateMocks([ControlValueAccessor])
import 'directives_test.mocks.dart'; // ignore: uri_does_not_exist

class DummyControlValueAccessor implements ControlValueAccessor<dynamic> {
  dynamic writtenValue;

  @override
  void writeValue(dynamic obj) {
    writtenValue = obj;
  }

  @override
  void registerOnChange(fn) {}
  @override
  void registerOnTouched(fn) {}
  @override
  void onDisabledChanged(bool isDisabled) {}
}

class CustomValidatorDirective implements Validator {
  @override
  Map<String, dynamic> validate(AbstractControl c) {
    return {'custom': true};
  }
}

Matcher throwsWith(String s) =>
    throwsA(predicate((e) => e.toString().contains(s)));

Future<void> flushMicrotasks() async => await Future.microtask(() => null);

void main() {
  group('Shared selectValueAccessor', () {
    late DefaultValueAccessor defaultAccessor;

    setUp(() {
      defaultAccessor = DefaultValueAccessor(HTMLInputElement());
    });
    test('should throw when given an empty array', () {
      expect(() => selectValueAccessor([]),
          throwsWith('No valid value accessor for'));
    });
    test('should return the default value accessor when no other provided', () {
      expect(selectValueAccessor([defaultAccessor]), defaultAccessor);
    });
    test('should return checkbox accessor when provided', () {
      var checkboxAccessor = CheckboxControlValueAccessor(HTMLInputElement());
      expect(selectValueAccessor([defaultAccessor, checkboxAccessor]),
          checkboxAccessor);
    });
    test('should return select accessor when provided', () {
      var selectAccessor = SelectControlValueAccessor(HTMLSelectElement());
      expect(selectValueAccessor([defaultAccessor, selectAccessor]),
          selectAccessor);
    });
    test('should throw when more than one build-in accessor is provided', () {
      var checkboxAccessor = CheckboxControlValueAccessor(HTMLInputElement());
      var selectAccessor = SelectControlValueAccessor(HTMLSelectElement());
      expect(() => selectValueAccessor([checkboxAccessor, selectAccessor]),
          throwsWith('More than one built-in value accessor matches'));
    });
    test('should return custom accessor when provided', () {
      // ignore: undefined_function
      var customAccessor = MockControlValueAccessor();
      var checkboxAccessor = CheckboxControlValueAccessor(HTMLInputElement());
      expect(
          selectValueAccessor(
              [defaultAccessor, customAccessor, checkboxAccessor]),
          customAccessor);
    });
    test('should throw when more than one custom accessor is provided', () {
      // ignore: undefined_function
      var customAccessor = MockControlValueAccessor();
      expect(() => selectValueAccessor([customAccessor, customAccessor]),
          throwsWith('More than one custom value accessor matches'));
    });
  });
  group('Shared composeValidators', () {
    test('should compose functions', () {
      Map<String, dynamic> dummy1(_) => {'dummy1': true};
      Map<String, dynamic> dummy2(_) => {'dummy2': true};
      var v = composeValidators([dummy1, dummy2])!;
      expect(v(Control('')), {'dummy1': true, 'dummy2': true});
    });

    test('should compose validator directives', () {
      Map<String, dynamic> dummy1(_) => {'dummy1': true};
      var v = composeValidators([dummy1, CustomValidatorDirective()])!;
      expect(v(Control('')), {'dummy1': true, 'custom': true});
    });
  });
}
