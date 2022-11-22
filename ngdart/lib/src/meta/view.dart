// TODO: review if this enum at
//    > ngdart/lib/src/meta/view.dart
// and the similar enum at
//    > ngcompiler/lib/v1/src/compiler/ir/model.dart
// could be merged as there is a conversion at
//    > ngcompiler/lib/v1/src/compiler/angular_compiler.dart:118

/// Defines template and style encapsulation options available for Component's
/// [View].
///
/// See [View#encapsulation].
enum ViewEncapsulation {
  /// Emulate `Native` scoping of styles by adding an attribute containing
  /// surrogate id to the Host Element and pre-processing the style rules
  /// provided via [View#styles] or [View#stylesUrls], and
  /// adding the new Host Element attribute to all selectors.
  ///
  /// This is the default option.
  emulated,

  /// Don't provide any template or style encapsulation.
  none,
}
