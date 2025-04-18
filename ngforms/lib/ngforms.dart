/// This module is used for handling user input, by defining and building a
/// [ControlGroup] that consists of [Control] objects, and mapping them onto
/// the DOM. [Control] objects can then be used to read information from the
/// form DOM elements.
///
/// This module is not included in the `angular` module; you must import the
/// forms module explicitly.
///
/// @docImport 'src/model.dart';
library; // name the library so we can run dartdoc on it by name.

import 'src/directives/radio_control_value_accessor.dart'
    show RadioControlRegistry;

export 'src/directives.dart'
    show
        composeValidators,
        setUpControl,
        setUpControlGroup,
        formDirectives,
        AbstractControlDirective,
        AbstractNgForm,
        ChangeFunction,
        CheckboxControlValueAccessor,
        ControlContainer,
        ControlValueAccessor,
        DefaultValueAccessor,
        Form,
        MaxLengthValidator,
        MemorizedForm,
        MinLengthValidator,
        NgControl,
        NgControlGroup,
        NgControlName,
        NgControlStatus,
        NgForm,
        NgFormControl,
        NgFormModel,
        NgModel,
        NgSelectOption,
        ngValueAccessor,
        NumberValueAccessor,
        PatternValidator,
        RadioControlValueAccessor,
        RadioButtonState,
        RequiredValidator,
        SelectControlValueAccessor,
        TouchFunction,
        Validator,
        ValidatorFn;
export 'src/form_builder.dart' show FormBuilder;
export 'src/model.dart'
    show
        AbstractControl,
        ControlStatus,
        Control,
        AbstractControlGroup,
        ControlGroup,
        ControlArray;
export 'src/validators.dart' show ngValidators, Validators;

/// Shorthand set of providers used for building Angular forms.
///
/// ### Example
///
/// ```dart
/// @GenerateInjector(formProviders)
/// final InjectorFactory injector = ng.injector$Injector;
///
/// runApp(MyAppNgFactory, createInjector: injector);
/// ````
const List<Type> formProviders = [RadioControlRegistry];

/// See [formProviders] instead.
const List<Type> formBindings = formProviders;
