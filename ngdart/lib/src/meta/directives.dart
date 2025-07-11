import 'package:meta/meta_meta.dart';

import 'change_detection_constants.dart';
import 'typed.dart';
import 'view.dart';
import 'visibility.dart';

/// An annotation that marks a class as an Angular directive, allowing you to
/// attach behavior to elements in the DOM.
///
/// <?code-excerpt "docs/attribute-directives/lib/src/highlight_directive_1.dart"?>
/// ```dart
/// import 'package:web/web.dart';
///
/// import 'package:ngdart/angular.dart';
///
/// @Directive(selector: '[myHighlight]')
/// class HighlightDirective {
///   HighlightDirective(Element el) {
///     el.style.backgroundColor = 'yellow';
///   }
/// }
/// ```
///
/// Use `@Directive` to mark a class as an Angular directive and provide
/// additional metadata that determines how the directive should be processed,
/// instantiated, and used at runtime.
///
/// In addition to the metadata configuration specified via the Directive
/// decorator, directives can control their runtime behavior by implementing
/// various lifecycle hooks.
///
/// See also:
///
/// * [Attribute Directives](https://webdev.dartlang.org/angular/guide/attribute-directives)
/// * [Lifecycle Hooks](https://webdev.dartlang.org/angular/guide/lifecycle-hooks)
///
@Target({TargetKind.classType})
class Directive {
  /// The CSS selector that triggers the instantiation of the directive.
  ///
  /// Angular only allows directives to trigger on CSS selectors that do not
  /// cross element boundaries.
  ///
  /// The [selector] may be declared as one of the following:
  ///
  /// - `element-name`: select by element name.
  /// - `.class`: select by class name.
  /// - `[attribute]`: select by attribute name.
  /// - `[attribute=value]` : select by attribute name and value.
  /// - `:not(sub_selector)`: select only if the element does not match the
  ///   `sub_selector`.
  /// - `selector1, selector2`: select if either `selector1` or `selector2`
  ///   matches.
  ///
  /// ### Example
  ///
  /// Suppose we have a directive with an `input[type=text]` selector
  /// and the following HTML:
  ///
  /// ```html
  /// <form>
  ///   <input type="text">
  ///   <input type="radio">
  /// </form>
  /// ```
  ///
  /// The directive would only be instantiated on the `<input type="text">`
  /// element.
  final String selector;

  /// The set of injectable objects that are visible to the directive and
  /// its light DOM children.
  ///
  /// ### Example
  /// Here is an example of a class that can be injected:
  ///
  /// ```dart
  /// class Greeter {
  ///   String greet(String name) => 'Hello ${name}!';
  /// }
  ///
  /// @Directive(
  ///   selector: 'greet',
  ///   providers: const [ Greeter])
  /// class HelloWorld {
  ///   final Greeter greeter;
  ///
  ///   HelloWorld(this.greeter);
  /// }
  /// ```
  final List<Object> providers;

  /// A name that can be used in the template to assign this directive
  /// to a variable.
  ///
  /// ### Example
  ///
  /// ```dart
  /// @Directive(
  ///   selector: 'child-dir',
  ///   exportAs: 'child')
  /// class ChildDir {}
  ///
  /// @Component(
  ///   selector: 'main',
  ///   template: `<child-dir #c="child"></child-dir>`,
  ///   directives: const [ChildDir])
  /// class MainComponent {}
  /// ```
  final String? exportAs;

  /// Whether this directive will be provided for injection.
  ///
  /// By default this is [Visibility.local], which prevents injecting the
  /// directive class by default, but provides a code-size and runtime
  /// performance benefit. See [Visibility] for details.
  final Visibility visibility;

  const Directive({
    required this.selector,
    this.providers = const [],
    this.exportAs,
    this.visibility = Visibility.local,
  });
}

/// Declare reusable UI building blocks for an application.
///
/// Each Angular component requires a single `@Component` annotation. The
/// `@Component` annotation specifies when a component is instantiated.
///
/// When a component is instantiated, Angular
///
/// - creates a shadow DOM for the component,
/// - loads the selected template into the shadow DOM and
/// - creates all the injectable objects configured with [providers] and
///   [viewProviders].
///
/// All template expressions and statements are then evaluated against the
/// component instance.
///
/// ### Lifecycle hooks
///
/// When the component class implements some [lifecycle-hooks][LCH]
/// the callbacks are called by the change detection at defined points in time
/// during the life of the component.
///
/// [LCH]: https://webdev.dartlang.org/angular/guide/lifecycle-hooks
@Target({TargetKind.classType})
class Component extends Directive {
  /// Defines the used change detection strategy.
  ///
  /// When a component is instantiated, Angular creates a change detector, which
  /// is responsible for propagating the component's bindings.
  ///
  /// The [changeDetection] property defines, whether the change detection will
  /// be checked every time or only when the component tells it to do so.
  final ChangeDetectionStrategy changeDetection;

  /// Defines the set of injectable objects that are visible to its view
  /// DOM children.
  ///
  /// ## Simple Example
  ///
  /// Here is an example of a class that can be injected:
  ///
  ///     class Greeter {
  ///        greet(String name) => 'Hello ${name}!';
  ///     }
  ///
  ///     @Directive(
  ///       selector: 'needs-greeter'
  ///     )
  ///     class NeedsGreeter {
  ///       final Greeter greeter;
  ///
  ///       NeedsGreeter(this.greeter);
  ///     }
  ///
  ///     @Component(
  ///       selector: 'greet',
  ///       viewProviders: [
  ///         Greeter
  ///       ],
  ///       template: '<needs-greeter></needs-greeter>',
  ///       directives: [NeedsGreeter]
  ///     )
  ///     class HelloWorld {
  ///     }
  ///
  final List<Object> viewProviders;

  /// A list of identifiers that may be referenced in the template.
  ///
  /// ## Small Example
  ///
  /// Suppose you want to use an enum value in your template:
  ///
  ///     enum MyEnum { foo, bar, baz }
  ///
  ///     @Component(
  ///       selector: 'example',
  ///       exports: const [MyEnum],
  ///       template: '<p>{{MyEnum.bar}}</p>',
  ///     )
  ///     class Example {}
  ///
  final List<Object?> exports;

  final String? templateUrl;
  final String? template;

  /// Removes all whitespace except `&ngsp;` and `&nbsp;` from template if set
  /// to false.
  ///
  /// &ngsp; (Angular space) can be used to insert regular space character into
  /// a template.
  /// &nbsp; represents the standard non-breaking space entity in html markup.
  final bool preserveWhitespace;
  final List<String> styleUrls;
  final List<String> styles;
  final List<Object> directives;

  /// Declares generic type arguments for any generic [directives].
  ///
  /// See [Typed] for details.
  final List<Typed<Object>> directiveTypes;

  final List<Object> pipes;
  final ViewEncapsulation encapsulation;

  const Component({
    required super.selector,
    super.exportAs,
    super.providers = const [],
    super.visibility = Visibility.local,
    this.viewProviders = const [],
    this.exports = const [],
    this.changeDetection = ChangeDetectionStrategy.checkAlways,
    this.templateUrl,
    this.template,
    this.preserveWhitespace = false,
    this.styleUrls = const [],
    this.styles = const [],
    this.directives = const [],
    this.directiveTypes = const [],
    this.pipes = const [],
    this.encapsulation = ViewEncapsulation.emulated,
  });
}

/// Declare reusable pipe function.
///
/// A "pure" pipe is only re-evaluated when either the input or any of the
/// arguments change. When not specified, pipes default to being pure.
///
@Target({TargetKind.classType})
class Pipe {
  final String name;
  final bool pure;

  const Pipe(this.name, {this.pure = true});
}

/// An annotation specifying that a constant attribute value should be injected.
///
/// The directive will inject a compile-time constant string literal of the host
/// element's matching attribute.
///
/// > **NOTE**: `@Attribute` is not affected by any updates to attributes to the
/// > host element (including the `[attr.*]` template syntax, or imperative
/// > updates to the DOM using `package:web/web.dart`).
///
/// ### Example
///
/// Suppose we have an `<input>` element and want to know its `type`.
///
/// ```html
/// <input type="text">
/// ```
///
/// A [Directive] could read the string literal `'text'` like so:
///
/// ```dart
/// @Directive(selector: 'input')
/// class InputAttrDirective {
///   InputAttrDirective(@Attribute('type') String type) {
///     print(type); // 'text'
///   }
/// }
/// ```
@Target({TargetKind.parameter})
class Attribute {
  final String attributeName;

  const Attribute(this.attributeName);
}

abstract class _Query {
  /// Either the class [Type] or selector [String].
  final Object selector;

  /// Whether to query only direct children (`false`) or all children (`true`).
  final bool descendants;

  /// Whether to only query the first child.
  final bool first;

  /// The DI token to read from an element that matches the selector.
  final Object? read;

  const _Query(
    this.selector, {
    this.descendants = false,
    this.first = false,
    this.read,
  });
}

/// Declares a reference to multiple child nodes projected into `<ng-content>`.
///
/// The annotated [List] is replaced when the DOM is updated.
///
/// ### Example
///
/// ```dart
/// @Component(
///   selector: 'root-comp',
///   directives: [TabPanelComponent, TabComponent],
///   template: '''
///     <tab-panel>
///       <tab-comp></tab-comp>
///       <tab-comp></tab-comp>
///       <tab-comp></tab-comp>
///     </tab-panel>
///   ''',
/// )
/// class RootComponent {}
///
/// @Component(
///   selector: 'tab-comp',
///   template: 'I am a Tab!',
/// )
/// class TabComponent {}
///
/// @Component(
///   selector: 'tab-panel',
///   template: '<ng-content></ng-content>',
/// )
/// class TabPanelComponent implements AfterContentInit {
///   @ContentChildren(TabComponent)
///   List<TabComponent> tabs;
///
///   @override
///   void ngAfterContentInit() {
///     for (var tab in tabs) {
///       // Do something.
///     }
///   }
/// }
/// ```
///
/// See [ViewChildren] for a full documentation of parameters and more examples.
///
/// **WARNING**: There is a known issue (b/129297484) where, when used in
/// combination with an `NgFor` (or a custom directive that supports moving
/// embedded views) this field or setter may _not_ be updated. For details see
/// go/angular-dart/dev/template-queries.
@Target({
  TargetKind.field,
  TargetKind.setter,
})
class ContentChildren extends _Query {
  const ContentChildren(
    super.selector, {
    super.descendants = true,
    super.read,
  });
}

/// Declares a reference to a single child node projected into `<ng-content>`.
///
/// This annotation semantically similar to [ContentChildren], but instead
/// represents a single (or first, if more than one is found) node being queried
/// - similar to `querySelector` instead of `querySelectorAll`.
///
/// See [ContentChildren] and [ViewChildren] for full documentation.
@Target({
  TargetKind.field,
  TargetKind.setter,
})
class ContentChild extends _Query {
  const ContentChild(
    super.selector, {
    super.read,
  }) : super(descendants: true, first: true);
}

abstract class _ViewQuery extends _Query {
  const _ViewQuery(
    super.selector, {
    super.descendants = false,
    super.first = false,
    super.read,
  });
}

/// Declares a reference to multiple child nodes in a component's template.
///
/// The annotated [List] is replaced when the DOM is updated.
///
/// The annotation requires a [selector] argument:
///
/// - If the argument is a [Type], directives or components with that exact
///   type, or injectable services available on directives or components will
///   be bound.
/// - If the argument is a [String], the string is interpreted as a list of
///   comma-separated selectors.  For each selector, an element containing the
///   matching template variable (e.g. `#child`) will be bound.
///
/// Optionally, a [read] parameter may be specified in order to read a specific
/// property on the bound directive, component, or element. Common values
/// include the types `TemplateRef`, `ViewContainerRef`, `Element`, or the
/// string value of [Directive.exportAs] (when it is ambiguous what node to
/// select from the template).,
///
/// View children are set before the `ngAfterViewInit` method is invoked, and
/// may be updated before the `ngAfterViewChecked` method is invoked. The
/// preferred method for being notified of the list instance changing is
/// creating a _setter_ instead of using a field.
///
/// ### Examples
///
/// With a [Type] selector:
///
/// ```dart
/// @Component(
///   selector: 'child-cmp',
///   template: '<p>child</p>'
/// )
/// class ChildCmp {
///   void doSomething() {}
/// }
///
/// @Component(
///   selector: 'some-cmp',
///   template: '''
///     <child-cmp></child-cmp>
///     <child-cmp></child-cmp>
///     <child-cmp></child-cmp>
///   ''',
///   directives: [ChildCmp],
/// )
/// class SomeCmp implements AfterViewInit {
///   @ViewChildren(ChildCmp)
///   List<ChildCmp> children;
///
///   @override
///   void ngAfterViewInit() {
///     // children are set
///     for (var child in children) {
///       child.doSomething();
///     }
///   }
/// }
/// ```
///
/// With a [String] selector:
///
/// ```dart
/// @Component(
///   selector: 'child-cmp',
///   template: '<p>child</p>',
/// )
/// class ChildCmp {
///   void doSomething() {}
/// }
///
/// @Component(
///   selector: 'some-cmp',
///   template: '''
///     <child-cmp #child1></child-cmp>
///     <child-cmp #child2></child-cmp>
///     <child-cmp #child3></child-cmp>
///   ''',
///   directives: [ChildCmp],
/// )
/// class SomeCmp implements AfterViewInit {
///   @ViewChildren('child1, child2, child3')
///   List<ChildCmp> children;
///
///   @override
///   void ngAfterViewInit() {
///     // Initial children are set
///     for (var child in children) {
///       child.doSomething();
///     }
///   }
/// }
/// ```
///
/// Using a _setter_ for update notifications:
///
/// ```dart
/// @Component(
///   selector: 'child-cmp',
///   template: '<p>child</p>',
/// )
/// class ChildCmp {
///   void doSomething() {}
/// }
///
/// @Component(
///   selector: 'some-cmp',
///   template: '''
///     <child-cmp *ngIf="condition1" #child1></child-cmp>
///     <child-cmp *ngIf="condition2" #child2></child-cmp>
///     <child-cmp *ngIf="condition3" #child3></child-cmp>
///   ''',
///   directives: [ChildCmp],
/// )
/// class SomeCmp {
///   @Input()
///   bool condition1 = false;
///
///   @Input()
///   bool condition2 = false;
///
///   @Input()
///   bool condition3 = false;
///
///   @ViewChildren('child1, child2, child3')
///   set children(List<ChildCmp> children) {
///     // Note above that the child components may or may not be created (they
///     // are guarded with '*ngIf'). This setter is called every time the
///     // visible children change (including the initial visibility, so we do
///     // not need 'ngAfterViewInit').
///     for (var child in children) {
///       child.doSomething();
///     }
///   }
/// }
/// ```
///
/// Reading an HTML element using `read`:
///
/// ```dart
/// @Component(
///   selector: 'child-cmp',
///   template: '<p>child</p>',
/// )
/// class ChildCmp {
///   void doSomething() {}
/// }
///
/// @Component(
///   selector: 'some-cmp',
///   template: '''
///     <child-cmp #child1></child-cmp>
///     <child-cmp #child2></child-cmp>
///     <child-cmp #child3></child-cmp>
///   ''',
///   directives: [ChildCmp],
/// )
/// class SomeCmp {
///   @ViewChildren('child1, child2, child3', read: Element)
///   List<Element> children;
/// }
/// ```
///
/// **WARNING**: Queries such as [ViewChildren], [ContentChildren] and related
/// are only meant to be used on _static_ content in the template. For example
/// writing a custom structural directive (like `*ngIf`) that changes the
/// structure of the DOM in custom ways will not work properly with queries and
/// could cause runtime type errors.
///
/// **WARNING**: There is a known issue (b/129297484) where, when used in
/// combination with an `NgFor` (or a custom directive that supports moving
/// embedded views) this field or setter may _not_ be updated. For details see
/// go/angular-dart/dev/template-queries.
@Target({
  TargetKind.field,
  TargetKind.setter,
})
class ViewChildren extends _ViewQuery {
  const ViewChildren(
    super.selector, {
    super.read,
  }) : super(descendants: true);
}

/// Declares a reference to a single child node in a component's template.
///
/// This annotation semantically similar to [ViewChildren], but instead
/// represents a single (or first, if more than one is found) node being queried
/// - similar to `querySelector` instead of `querySelectorAll`.
///
/// ```dart
/// @Component(
///   selector: 'child-cmp',
///   template: '<p>child</p>',
/// )
/// class ChildCmp {}
///
/// @Component(
///   selector: 'some-cmp',
///   template: '<child-cmp></child-cmp>',
///   directives: [ChildCmp],
/// )
/// class SomeCmp {
///   @ViewChild(ChildCmp)
///   ChildCmp child;
/// }
/// ```
///
/// See [ViewChildren] for a full documentation of parameters and more examples.
@Target({
  TargetKind.field,
  TargetKind.setter,
})
class ViewChild extends _ViewQuery {
  const ViewChild(
    super.selector, {
    super.read,
  }) : super(descendants: true, first: true);
}

/// Declares a data-bound input property.
///
/// Data-bound properties are automatically updated during change detection.
///
/// The [Input] annotation takes an optional parameter that specifies
/// the name used when instantiating a component in the template. When not
/// provided, the name of the decorated property is used.
///
/// ### Example
///
/// The following example creates a component with two input properties.
///
/// ```dart
/// @Component(
///    selector: 'bank-account',
///    template: '''
///      Bank Name: {{bankName}}
///      Account Id: {{id}}
///    ''')
///  class BankAccount {
///    @Input()
///    String bankName;
///
///    @Input('account-id')
///    String id;
///
///    // this property is not bound, and won't be automatically updated
///    String normalizedBankName;
///  }
///
///  @Component(
///    selector: 'app',
///    template: '''
///      <bank-account bank-name="RBC" account-id="4747"></bank-account>
///    ''',
///    directives: const [BankAccount])
///  class App {}
///  ```
@Target({
  TargetKind.field,
  TargetKind.setter,
})
class Input {
  /// Name used when instantiating a component in the template.
  final String? bindingPropertyName;
  const Input([this.bindingPropertyName]);
}

/// Declares an event-bound output property.
///
/// When an output property emits an event, an event handler attached to that
/// event the template is invoked.
///
/// The [Output] annotation takes an optional parameter that specifies
/// the name used when instantiating a component in the template. When not
/// provided, the name of the decorated property is used.
///
/// ### Example
///
/// ```dart
/// @Directive(selector: 'interval-dir')
/// class IntervalDir {
///   final _everySecond = new StreamController<String>();
///   @Output()
///   final get everySecond => _everySecond.stream;
///
///   final _every5Secs = new StreamController<void>();
///   @Output('everyFiveSeconds')
///   final get every5Secs => _every5Secs.stream;
///
///   IntervalDir() {
///     setInterval(() => _everySecond.add("event"), 1000);
///     setInterval(() => _every5Secs.add(null), 5000);
///   }
/// }
///
/// @Component(
///   selector: 'app',
///   template: '''
///     <interval-dir
///         (everySecond)="everySecond()"
///         (everyFiveSeconds)="everyFiveSeconds()">
///     </interval-dir>
///   ''',
///   directives: const [IntervalDir])
/// class App {
///   void everySecond() {
///     print('second');
///   }
///
///   everyFiveSeconds() {
///     print('five seconds');
///   }
/// }
/// ```
@Target({
  TargetKind.field,
  TargetKind.getter,
})
class Output {
  final String? bindingPropertyName;
  const Output([this.bindingPropertyName]);
}

/// Declares a host property on the host component or element.
///
/// This annotation is valid on:
/// * Public class members
/// * The class members may either be fields or getters
/// * The class members may either be static or instance
///
/// This annotation is _inherited_ if declared on an instance member.
///
/// If [hostPropertyName] is not specified, it defaults to the property or
/// getter name. For example in the following, `'title'` is implicitly used:
/// ```
/// @Directive(...)
/// class ImplicitName {
///   // Same as @HostBinding('title')
///   @HostBinding()
///   final title = 'Hello World';
/// }
/// ```
///
/// These bindings are nearly identical to using the template syntax to set
/// properties or attributes, and are automatically updated if the referenced
/// class member, instance or static, changes:
/// ```
/// @Directive(...)
/// class HostBindingExample {
///   // Similar to <example [value]="hostValue"> in a template.
///   @HostBinding('value')
///   String hostValue;
///
///   // Similar to <example [attr.debug-id]="debugId"> in a template.
///   @HostBinding('attr.debug-id')
///   String debugId;
/// }
/// ```
@Target({
  TargetKind.field,
  TargetKind.getter,
})
class HostBinding {
  final String? hostPropertyName;
  const HostBinding([this.hostPropertyName]);
}

/// Declares listening to [eventName] on the host element of the directive.
///
/// This annotation is valid on _instance_ methods of a class annotated with
/// either `@Directive` or `@Component`, and is inherited when a class
/// implements, extends, or mixes-in a class with this annotation.
///
/// ```dart
/// @Component(
///   selector: 'button-like',
///   template: 'CLICK ME',
/// )
/// class ButtonLikeComponent {
///   @HostListener('click')
///   void onClick() {}
/// }
/// ```
///
/// An optional second argument, [args], can define arguments to invoke the
/// method with, including a magic argument `'\$event'`, which is replaced with
/// the value of the event stream. In most cases [args] can be inferred when
/// bound to a method with a single argument:
/// ```dart
/// @Component(
///   selector: 'button-like',
///   template: 'CLICK ME',
/// )
/// class ButtonLikeComponent {
///   @HostListener('click') // == @HostListener('click', const ['\$event'])
///   void onClick(MouseEvent e) {}
/// }
/// ```
@Target({TargetKind.method})
class HostListener {
  final String eventName;
  final List<String>? args;
  const HostListener(this.eventName, [this.args]);
}
