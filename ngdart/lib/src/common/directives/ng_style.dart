import 'dart:html';

import 'package:ngdart/src/meta.dart';
import 'package:ngdart/src/utilities.dart';

import '../../core/change_detection/differs/default_keyvalue_differ.dart';

/// The `NgStyle` directive changes an element's style based on the bound style
/// expression:
/// ```html
/// <div [ngStyle]="styleExp"></div>
/// ```
/// _styleExp_ must evaluate to a `Map<String, String>`. Element style properties
/// are set based on the map entries: each _key_:_value_ pair identifies a
/// style property _name_ and its _value_.
///
/// For details, see the [`ngStyle` discussion in the Template Syntax][guide]
/// page.
///
/// ### Examples
///
/// Try the [live example][ex] from the [Template Syntax][guide] page. Here are
/// the relevant excerpts from the example's template and the corresponding
/// component class:
///
/// <?code-excerpt "docs/template-syntax/lib/app_component.html (NgStyle-2)"?>
/// ```html
/// <div [ngStyle]="currentStyles">
///   This div is initially italic, normal weight, and extra large (24px).
/// </div>
/// ```
///
/// <?code-excerpt "docs/template-syntax/lib/app_component.dart (setStyles)"?>
/// ```dart
/// Map<String, String> currentStyles = <String, String>{};
/// void setCurrentStyles() {
///   currentStyles = <String, String>{
///     'font-style': canSave ? 'italic' : 'normal',
///     'font-weight': !isUnchanged ? 'bold' : 'normal',
///     'font-size': isSpecial ? '24px' : '12px'
///   };
/// }
/// ```
///
/// In this example, user changes to the `<input>` elements result in updates
/// to the corresponding style properties of the first paragraph.
///
/// [guide]: https://angulardart.xyz/guide/template-syntax.html#ngStyle
/// [ex]: https://angulardart.xyz/examples/template-syntax#ngStyle
@Directive(
  selector: '[ngStyle]',
)
class NgStyle implements DoCheck {
  final Element _ngElement;
  Map<String, String?>? _rawStyle;
  DefaultKeyValueDiffer? _differ;

  NgStyle(this._ngElement);

  @Input('ngStyle')
  set rawStyle(Map<String, String?>? v) {
    _rawStyle = v;
    if (_differ == null && v != null) {
      _differ = DefaultKeyValueDiffer();
    }
  }

  @override
  void ngDoCheck() {
    final differ = _differ;
    if (differ == null || !differ.diff(_rawStyle)) {
      return;
    }
    differ
      ..forEachAddedItem(_setProperty)
      ..forEachChangedItem(_setProperty)
      ..forEachRemovedItem(_setProperty);
  }

  void _setProperty(KeyValueChangeRecord record) {
    _ngElement.style.setProperty(
      unsafeCast(record.key),
      unsafeCast(record.currentValue),
    );
  }
}
