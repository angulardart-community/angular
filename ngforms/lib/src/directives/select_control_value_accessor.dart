import 'package:ngdart/angular.dart';
import 'package:ngdart/src/utilities.dart';
import 'package:web/web.dart';

import 'control_value_accessor.dart'
    show ChangeHandler, ControlValueAccessor, ngValueAccessor, TouchHandler;

const selectValueAccessor = ExistingProvider.forToken(
  ngValueAccessor,
  SelectControlValueAccessor,
);

String _buildValueString(String? id, Object? value) {
  if (id == null) return '$value';
  if (!value!.isPrimitive) value = 'Object';
  var s = '$id: $value';
  // TODO: Fix this magic maximum 50 characters (from TS-transpile).
  if (s.length > 50) {
    s = s.substring(0, 50);
  }
  return s;
}

String _extractId(String valueString) => valueString.split(':')[0];

/// The accessor for writing a value and listening to changes on a select
/// element.
///
/// Note: We have to listen to the 'change' event because 'input' events aren't
/// fired for selects in Firefox and IE:
/// https://bugzilla.mozilla.org/show_bug.cgi?id=1024350
/// https://developer.microsoft.com/en-us/microsoft-edge/platform/issues/4660045
@Directive(
  selector: 'select[ngControl],select[ngFormControl],select[ngModel]',
  providers: [selectValueAccessor],
  // SelectControlValueAccessor must be visible to NgSelectOption.
  visibility: Visibility.all,
)
class SelectControlValueAccessor extends Object
    with TouchHandler, ChangeHandler<dynamic>
    implements ControlValueAccessor<Object?> {
  final HTMLSelectElement _element;
  Object? value;
  final Map<String, Object?> _optionMap = <String, Object?>{};
  num _idCounter = 0;

  SelectControlValueAccessor(HTMLElement element)
      : _element = element as HTMLSelectElement;

  @HostListener('change', ['\$event.target.value'])
  void handleChange(String value) {
    onChange(_getOptionValue(value), rawValue: value);
  }

  @override
  void writeValue(Object? value) {
    this.value = value;
    var valueString = _buildValueString(_getOptionId(value), value);
    _element.value = valueString;
  }

  @override
  void onDisabledChanged(bool isDisabled) {
    _element.disabled = isDisabled;
  }

  String _registerOption() => (_idCounter++).toString();

  String? _getOptionId(Object? value) {
    for (var id in _optionMap.keys) {
      if (identical(_optionMap[id], value)) return id;
    }
    return null;
  }

  dynamic _getOptionValue(String valueString) {
    var value = _optionMap[_extractId(valueString)];
    return value ?? valueString;
  }
}

/// Marks `<option>` as dynamic, so Angular can be notified when options change.
///
/// ### Example
///
///     <select ngControl="city">
///       <option *ngFor="let c of cities" [value]="c"></option>
///     </select>
@Directive(
  selector: 'option',
)
class NgSelectOption implements OnDestroy {
  final HTMLOptionElement _element;
  final SelectControlValueAccessor? _select;
  late final String id;
  NgSelectOption(HTMLElement element, @Optional() @Host() this._select)
      : _element = element as HTMLOptionElement {
    if (_select != null) id = _select._registerOption();
  }

  @Input('ngValue')
  set ngValue(Object? value) {
    var select = _select;
    if (select == null) return;
    select._optionMap[id] = value;
    _setElementValue(_buildValueString(id, value));
    select.writeValue(select.value);
  }

  @Input('value')
  set value(Object? value) {
    var select = _select;
    _setElementValue(value as String);
    if (select != null) select.writeValue(select.value);
  }

  void _setElementValue(String value) {
    _element.value = value;
  }

  @override
  void ngOnDestroy() {
    var select = _select;
    if (select != null) {
      select._optionMap.remove(id);
      select.writeValue(select.value);
    }
  }
}
