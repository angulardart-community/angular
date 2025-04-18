import 'directives/validators.dart';
import 'model.dart';

/// Creates a form object from a user-specified configuration.
///
/// ```dart
/// @Component(
///   selector: 'my-app',
///   directives: const [formDirectives],
///   viewProviders: const [formBindings],
///   template: '''
///     <form [ngFormModel]="loginForm">
///       <p>Login <input ngControl="login"></p>
///       <div ngControlGroup="passwordRetry">
///         <p>Password <input type="password" ngControl="password"></p>
///         <p>Confirm password <input type="password"
///            ngControl="passwordConfirmation"></p>
///       </div>
///     </form>
///     <h3>Form value:</h3>
///     <pre>{{value}}</pre>
///   ''',
/// )
/// class App {
///   ControlGroup loginForm = FormBuilder.controlGroup({
///     'login': ['', Validators.required],
///     'passwordRetry': FormBuilder.controlGroup({
///       'password': ['', Validators.required],
///       'passwordConfirmation': ['', Validators.required]
///     })
///   });
///
///   String get value {
///     return json.encode(loginForm.value);
///   }
/// }
/// ```
class FormBuilder {
  /// Construct a new [ControlGroup] with the given map of configuration,
  /// with the given optional [validator].
  ///
  /// See the [ControlGroup] constructor for more details.
  static ControlGroup controlGroup(Map<String, dynamic> controlsConfig,
      {ValidatorFn? validator}) {
    var controls = _reduceControls(controlsConfig);
    return ControlGroup(controls, validator);
  }

  /// Construct an array of [Control]s from the given [controlsConfig] array of
  /// configuration, with the given optional [validator].
  static ControlArray controlArray(List<dynamic> controlsConfig,
      [ValidatorFn? validator]) {
    var controls = controlsConfig.map(_createControl).toList();
    return ControlArray(controls, validator);
  }

  static Map<String, AbstractControl> _reduceControls(
          Map<String, dynamic> controlsConfig) =>
      controlsConfig.map((controlName, controlConfig) =>
          MapEntry(controlName, _createControl(controlConfig)));

  static AbstractControl _createControl(dynamic controlConfig) {
    if (controlConfig is AbstractControl) {
      return controlConfig;
    } else if (controlConfig is List) {
      var value = controlConfig[0];
      var validator =
          controlConfig.length > 1 ? controlConfig[1] as ValidatorFn : null;
      return Control(value, validator);
    } else {
      return Control(controlConfig, null);
    }
  }

  // Prevents instantiating this class.
  FormBuilder._();
}
