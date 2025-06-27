/// @docImport 'ng_control_name.dart';
/// @docImport 'ng_form_control.dart';
/// @docImport 'ng_model.dart';
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:ngdart/angular.dart';
import 'package:ngforms/src/directives/shared.dart' show setElementDisabled;
import 'package:web/web.dart';

import 'control_value_accessor.dart'
    show ChangeHandler, ControlValueAccessor, ngValueAccessor, TouchHandler;
import 'ng_control.dart' show NgControl;

const radioValueAccessor = ExistingProvider.forToken(
  ngValueAccessor,
  RadioControlValueAccessor,
);

/// Internal class used by Angular to uncheck radio buttons with the matching
/// name.
@Injectable()
class RadioControlRegistry {
  final List<dynamic> _accessors = [];
  void add(NgControl control, RadioControlValueAccessor accessor) {
    _accessors.add([control, accessor]);
  }

  void remove(RadioControlValueAccessor accessor) {
    var indexToRemove = -1;
    for (var i = 0; i < _accessors.length; ++i) {
      if (identical(_accessors[i][1], accessor)) {
        indexToRemove = i;
      }
    }
    _accessors.removeAt(indexToRemove);
  }

  void select(RadioControlValueAccessor accessor) {
    for (var c in _accessors) {
      if (identical(c[0].control.root, accessor._control.control?.root) &&
          !identical(c[1], accessor)) {
        c[1].fireUncheck();
      }
    }
  }
}

/// The value provided by the forms API for radio buttons.
class RadioButtonState {
  final bool checked;
  final String value;

  RadioButtonState(this.checked, this.value);
}

/// The accessor for writing a radio control value and listening to changes that
/// is used by the [NgModel], [NgFormControl], and [NgControlName] directives.
///
/// ### Example
///
/// ```dart
/// @Component(
///   template: '''
///     <input type="radio" name="food" [(ngModel)]="foodChicken">
///     <input type="radio" name="food" [(ngModel)]="foodFish">
///   '''
/// )
/// class FoodCmp {
///   RadioButtonState foodChicken = new RadioButtonState(true, "chicken");
///   RadioButtonState foodFish = new RadioButtonState(false, "fish");
/// }
/// ```
@Directive(
  selector: 'input[type=radio][ngControl],'
      'input[type=radio][ngFormControl],'
      'input[type=radio][ngModel]',
  providers: [radioValueAccessor],
)
class RadioControlValueAccessor extends Object
    with TouchHandler, ChangeHandler<RadioButtonState>
    implements ControlValueAccessor<RadioButtonState>, OnDestroy, OnInit {
  final HTMLInputElement _element;
  final RadioControlRegistry _registry;
  final Injector _injector;
  RadioButtonState? _state;
  late NgControl _control;

  @Input()
  String? name;

  RadioControlValueAccessor(HTMLElement element, this._registry, this._injector)
      : _element = element as HTMLInputElement;

  @HostListener('change')
  void changeHandler() {
    onChange(RadioButtonState(true, _state!.value), rawValue: _state!.value);
    _registry.select(this);
  }

  @override
  void ngOnInit() {
    _control = _injector.provideType(NgControl);
    _registry.add(_control, this);
  }

  @override
  void ngOnDestroy() {
    _registry.remove(this);
  }

  @override
  void writeValue(RadioButtonState? value) {
    _state = value;
    if (value?.checked ?? false) {
      _element['checked'] = true.toJS;
    }
  }

  void fireUncheck() {
    onChange(RadioButtonState(false, _state!.value), rawValue: _state!.value);
  }

  @override
  void onDisabledChanged(bool isDisabled) {
    setElementDisabled(_element, isDisabled);
  }
}
