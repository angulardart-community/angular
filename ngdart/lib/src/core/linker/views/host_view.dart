import 'package:meta/dart2js.dart' as dart2js;
import 'package:meta/meta.dart';
import 'package:ngdart/src/core/change_detection/host.dart';
import 'package:ngdart/src/core/linker/component_factory.dart';
import 'package:ngdart/src/core/linker/view_container.dart';
import 'package:ngdart/src/core/linker/view_fragment.dart';
import 'package:ngdart/src/di/injector.dart';
import 'package:ngdart/src/meta.dart';
import 'package:ngdart/src/runtime/dom_helpers.dart';
import 'package:ngdart/src/utilities.dart';
import 'package:web/web.dart';

import 'component_view.dart';
import 'dynamic_view.dart';
import 'view.dart';

/// The base type of a view that hosts a [component] for imperative use.
///
/// For every component (a class annotated with `@Component()`), the compiler
/// will generate exactly one host view that extends this class. This view is
/// used to back a [ComponentFactory], whose purpose is to instantiate the
/// [component] imperatively. Once instantiated, the [ComponentRef] can be used
/// to manage the underlying [componentView].
///
/// The responsibilities of this view include:
///
///   * Initializing [component] and its [componentView].
///
///   * Making any services provided by [component] available for injection by
///   [component] and its descendants.
///
///   * Invoking any life cycle interfaces implemented by the [component] at the
///   appropriate times.
///
/// The type parameter [T] is the type of the hosted [component].
abstract class HostView<T extends Object> extends View implements DynamicView {
  /// The hosted component instance.
  ///
  /// To be instantiated in [build] by the generated implementation.
  late final T component;

  /// The hosted component view.
  ///
  /// To be instantiated in [build] by the generated implementation.
  late final ComponentView<T> componentView;

  /// The host injector provided by this view's creator.
  late final Injector _injector;

  final _data = _HostViewData();

  @override
  bool get destroyed => _data.destroyed;

  // TODO(b/132122866): this could just return `componentView.firstCheck`.
  @override
  bool get firstCheck =>
      _data.changeDetectorState == ChangeDetectorState.neverChecked;

  @override
  int? get parentIndex => null;

  @override
  View get parentView => throw UnsupportedError('$HostView has no parentView');

  @override
  ViewFragment? get viewFragment => _data.viewFragment;

  // Initialization ------------------------------------------------------------

  /// Creates this view and returns a reference to the hosted component.
  ///
  /// The [projectedNodes] specify the nodes and [ViewContainer]s to project
  /// into each content slot by index in the [componentView].
  ///
  /// The [injector] is provided by the caller, and is typically used to connect
  /// this host view to the rest of the dependency injection hierarchy. See
  /// [ViewContainer.createComponent] for details.
  ComponentRef<T> create(List<List<Object>> projectedNodes, Injector injector) {
    _injector = injector;
    build(); // This initializes `component` and `componentView`.
    componentView.createAndProject(component, projectedNodes);
    return ComponentRef(this, componentView.rootElement, component);
  }

  /// Called by [build] once all root nodes are created.
  @dart2js.noInline
  void initRootNode(Object nodeOrViewContainer) {
    _data.viewFragment = ViewFragment([nodeOrViewContainer]);
  }

  // Destruction ---------------------------------------------------------------

  void destroy() {
    final viewContainer = _data.viewContainer;
    viewContainer?.detachView(viewContainer.nestedViews!.indexOf(this));
    destroyInternalState();
  }

  // Default implementation for simple host views whose component meets the
  // following criteria:
  //
  //    * Does not inject the following classes:
  //        * `ComponentLoader`
  //        * `ViewContainerRef`
  //
  //    * Does not implement the following lifecycle interfaces:
  //        * `OnDestroy`
  //
  // If the above criteria aren't met, a new implementation responsible for
  // destroying any additional state and calling the appropriate lifecycle
  // methods will be generated.
  @override
  void destroyInternal() {}

  @override
  void destroyInternalState() {
    if (!_data.destroyed) {
      _data.destroy();
      componentView.destroyInternalState();
      destroyInternal();
    }
  }

  @override
  void onDestroy(void Function() callback) {
    _data.addOnDestroyCallback(callback);
  }

  // Change detection ----------------------------------------------------------

  @override
  void detectChangesDeprecated() {
    if (_data.shouldSkipChangeDetection) return;

    // Sanity check in dev-mode that a destroyed view is not checked again.
    if (isDevMode && _data.destroyed) {
      throw StateError('detectChanges');
    }

    if (ChangeDetectionHost.checkForCrashes) {
      // Run change detection in "slow-mode" to catch thrown exceptions.
      detectCrash();
    } else {
      // Normally run change detection.
      detectChangesInternal();
    }

    // Set the state to already checked at least once.
    _data.changeDetectorState = ChangeDetectorState.checkedBefore;
  }

  @override
  void detectChangesInCheckAlwaysViews() {
    if (componentView.usesDefaultChangeDetection) {
      // Change detect the component, and any view containers it injects.
      detectChangesDeprecated();
    }
  }

  // Default implementation for simple host views whose component meets the
  // following criteria:
  //
  //    * Does not inject the following classes:
  //        * `ComponentLoader`
  //        * `ViewContainerRef`
  //
  //    * Does not implement the following life cycle interfaces:
  //        * `OnInit`
  //        * `AfterChanges`
  //        * `AfterContentInit`
  //        * `AfterContentChecked`
  //        * `AfterViewInit`
  //        * `AfterViewChecked`
  //
  // If the above criteria aren't met, a new implementation responsible for
  // change detecting any additional state and calling the appropriate life
  // cycle methods will be generated.
  @override
  void detectChangesInternal() {
    componentView.detectChangesDeprecated();
  }

  @override
  void disableChangeDetection() {
    _data.changeDetectorState = ChangeDetectorState.errored;
  }

  @override
  void markForCheck() {
    // TODO(b/129780288): remove check for whether this view is detached.
    if (_data.changeDetectionMode !=
        ChangeDetectionCheckedState.waitingToBeAttached) {
      _data.viewContainer?.parentView?.markForCheck();
    }
  }

  @override
  void detachDeprecated() {
    _data.changeDetectionMode = ChangeDetectionCheckedState.waitingToBeAttached;
  }

  @override
  void reattachDeprecated() {
    _data.changeDetectionMode = ChangeDetectionCheckedState.checkAlways;
    markForCheck();
  }

  // Dependency injection ------------------------------------------------------

  @override
  Object? injectFromAncestry(Object token, Object? notFoundResult) =>
      unsafeCast(_injector.get(token, notFoundResult));

  // View manipulation ---------------------------------------------------------

  @override
  void addRootNodesAfter(Node node) {
    final rootNodes = viewFragment!.flattenDomNodes();
    insertNodesAsSibling(rootNodes, node);
    domRootRendererIsDirty = true;
  }

  @override
  void removeRootNodes() {
    final rootNodes = viewFragment!.flattenDomNodes();
    removeNodes(rootNodes);
    domRootRendererIsDirty = domRootRendererIsDirty || rootNodes.isNotEmpty;
  }

  @override
  void wasInserted(ViewContainer viewContainer) {
    _data.viewContainer = viewContainer;
  }

  @override
  void wasMoved() {
    // Nothing to update.
  }

  @override
  void wasRemoved() {
    _data.viewContainer = null;
  }
}

/// Data for [HostView] bundled together as an optimization.
@sealed
class _HostViewData implements DynamicViewData {
  @override
  ViewContainer? viewContainer;

  @override
  ViewFragment? viewFragment;

  /// Storage for any callbacks registered with [addOnDestroyCallback].
  List<void Function()>? _onDestroyCallbacks;

  @override
  ChangeDetectionCheckedState get changeDetectionMode => _changeDetectionMode;
  ChangeDetectionCheckedState _changeDetectionMode =
      ChangeDetectionCheckedState.checkAlways;
  set changeDetectionMode(ChangeDetectionCheckedState mode) {
    if (_changeDetectionMode != mode) {
      _changeDetectionMode = mode;
      _updateShouldSkipChangeDetection();
    }
  }

  @override
  ChangeDetectorState get changeDetectorState => _changeDetectorState;
  ChangeDetectorState _changeDetectorState = ChangeDetectorState.neverChecked;
  set changeDetectorState(ChangeDetectorState state) {
    if (_changeDetectorState != state) {
      _changeDetectorState = state;
      _updateShouldSkipChangeDetection();
    }
  }

  @override
  bool get destroyed => _destroyed;
  bool _destroyed = false;

  @override
  bool get shouldSkipChangeDetection => _shouldSkipChangeDetection;
  bool _shouldSkipChangeDetection = false;

  /// Registers a [callback] to be invoked by [destroy].
  @override
  void addOnDestroyCallback(void Function() callback) {
    (_onDestroyCallbacks ??= []).add(callback);
  }

  @override
  void destroy() {
    _destroyed = true;
    final onDestroyCallbacks = _onDestroyCallbacks;
    if (onDestroyCallbacks != null) {
      for (var i = 0, length = onDestroyCallbacks.length; i < length; ++i) {
        onDestroyCallbacks[i]();
      }
    }
  }

  void _updateShouldSkipChangeDetection() {
    _shouldSkipChangeDetection = _changeDetectionMode ==
            ChangeDetectionCheckedState.waitingToBeAttached ||
        _changeDetectorState == ChangeDetectorState.errored;
  }
}
