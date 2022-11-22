import 'package:meta/meta.dart';
import 'package:meta/meta_meta.dart';

/// Used to annotate an "onPush" component that may load "default_" components.
///
/// This can only be used to annotate a component that uses the "onPush" change
/// detection strategy.
///
/// It should only be used for "onPush" components that imperatively load
/// another component from a user provided `ComponentFactory`, which could use
/// the "default_" change detection strategy.
///
/// It should also only be used for common components that will be used in both
/// "default_" and "onPush" contexts. If the component is only used in a single
/// app, consider migrating the components it loads to "onPush" instead.
///
/// An annotated component serves as a link between a "default_" parent and any
/// imperatively loaded "default_" children during change detection. This link
/// allows the "default_" children to be change detected even when the annotated
/// component is skipped, thus honoring both of their change detection
/// contracts. A link may span multiple "onPush" components, so long as each one
/// is annotated.
///
/// The following example demonstrates how this annotation may be used.
///
/// ```
/// @changeDetectionLink
/// @Component(
///   selector: 'example',
///   template: '<template #container></template>',
///   changeDetection: ChangeDetectionStrategy.onPush,
/// )
/// class ExampleComponent {
///   @Input()
///   set componentFactory(ComponentFactory<Object> value) {
///     container.createComponent(value);
///   }
///
///   @ViewChild('container', read: ViewContainerRef)
///   ViewContainerRef container;
/// }
/// ```
///
/// This annotated component may be used by a "default_" component to
/// imperatively load another "default_" component via the `componentFactory`
/// input. Without this annotation, the imperatively loaded component would not
/// get updated during change detection when the annotated component is skipped
/// due to "onPush" semantics.
@experimental
const changeDetectionLink = _ChangeDetectionLink();

@Target({TargetKind.classType})
class _ChangeDetectionLink {
  const _ChangeDetectionLink();
}
