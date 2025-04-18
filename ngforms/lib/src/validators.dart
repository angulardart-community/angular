import 'package:ngdart/angular.dart';

import 'directives/validators.dart' show ValidatorFn;
import 'model.dart';

/// Providers for validators to be used for [AbstractControl]s in a form.
///
/// Provide this using `ExistingProvider.forToken` to add validators.
const ngValidators = MultiToken<Object>('NgValidators');

/// Provides a set of validators used by form controls.
///
/// A validator is a function that processes a [AbstractControl]or collection
/// of controls and returns a map of errors. A null map means that validation
/// has passed.
///
/// ### Example
///
/// ```dart
/// Control loginControl = Control("", Validators.required)
/// ```
class Validators {
  ///  Validator that requires controls to have a non-empty value.
  static Map<String, bool>? required(AbstractControl control) {
    return control.value == null || control.value == ''
        ? {'required': true}
        : null;
  }

  ///  Validator that requires controls to have a value of a minimum length.
  static ValidatorFn minLength(num minLength) {
    return /* Map < String , dynamic >? */ (AbstractControl control) {
      if (Validators.required(control) != null) return null;
      final v = control.value as String;
      return v.length < minLength
          ? {
              'minlength': {
                'requiredLength': minLength,
                'actualLength': v.length
              }
            }
          : null;
    };
  }

  ///  Validator that requires controls to have a value of a maximum length.
  static ValidatorFn maxLength(num maxLength) {
    return /* Map < String , dynamic >? */ (AbstractControl control) {
      if (Validators.required(control) != null) return null;
      final v = control.value as String;
      return v.length > maxLength
          ? {
              'maxlength': {
                'requiredLength': maxLength,
                'actualLength': v.length
              }
            }
          : null;
    };
  }

  ///  Validator that requires a control to match a regex to its value.
  static ValidatorFn pattern(String pattern) {
    return /* Map < String , dynamic >? */ (AbstractControl control) {
      if (Validators.required(control) != null) return null;
      var regex = RegExp('^$pattern\$');
      final v = control.value as String;
      return regex.hasMatch(v)
          ? null
          : {
              'pattern': {'requiredPattern': '^$pattern\$', 'actualValue': v}
            };
    };
  }

  ///  No-op validator.
  static Map<String, bool>? nullValidator(AbstractControl c) => null;

  ///  Compose multiple validators into a single function that returns the union
  ///  of the individual error maps.
  static ValidatorFn? compose(List<ValidatorFn?>? validators) {
    if (validators == null) return null;
    final presentValidators = _removeNullValidators(validators);
    if (presentValidators.isEmpty) return null;
    return (AbstractControl control) {
      return _executeValidators(control, presentValidators);
    };
  }

  // TODO(tsander): Remove the need to filter the validation. The list of
  // validators should not contain null values.
  static List<T> _removeNullValidators<T>(List<T?> validators) {
    final result = <T>[];
    for (var i = 0, len = validators.length; i < len; i++) {
      var validator = validators[i];
      if (validator != null) result.add(validator);
    }
    return result;
  }
}

Map<String, dynamic>? _executeValidators(
    AbstractControl control, List<ValidatorFn> validators) {
  var result = <String, dynamic>{};
  for (var i = 0, len = validators.length; i < len; i++) {
    final validator = validators[i];
    final localResult = validator(control);
    if (localResult != null) result.addAll(localResult);
  }
  return result.isEmpty ? null : result;
}
