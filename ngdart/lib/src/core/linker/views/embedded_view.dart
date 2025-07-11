import 'dart:async';

import 'package:meta/dart2js.dart' as dart2js;
import 'package:meta/meta.dart';
import 'package:ngdart/src/core/change_detection/host.dart';
import 'package:ngdart/src/core/linker/style_encapsulation.dart';
import 'package:ngdart/src/core/linker/view_container.dart';
import 'package:ngdart/src/core/linker/view_fragment.dart';
import 'package:ngdart/src/core/linker/view_ref.dart';
import 'package:ngdart/src/meta.dart';
import 'package:ngdart/src/runtime/dom_helpers.dart';
import 'package:ngdart/src/utilities.dart';
import 'package:web/web.dart';

import 'dynamic_view.dart';
import 'render_view.dart';

/// The base type of a view that implements a `<template>` element.
///
/// For every `<template>` element (used explicitly, or implicitly via a
/// `*`-binding), the compiler will generate an embedded view that extends this
/// class. This view is used to back a `TemplateRef`, whose purpose is to
/// instantiate the content of the `<template>` element imperatively. Once
/// instantiated, the returned [EmbeddedViewRef] can be used the manage this
/// view.
///
/// The type parameter [T] is the type of the component whose template defines
/// the `<template>` element this view represents. This component instance,
/// along with any [componentStyles] and [projectedNodes] are inherited from the
/// [parentView].
abstract class EmbeddedView<T> extends RenderView
    implements DynamicView, EmbeddedViewRef {
  EmbeddedView(RenderView parentView, int parentIndex)
      : _data = _EmbeddedViewData(parentView, parentIndex);

  final _EmbeddedViewData<T> _data;

  @override
  T get ctx => _data.ctx;

  @override
  ComponentStyles get componentStyles => _data.componentStyles;

  // This is never null, but matching the return type of our base classes make
  // the compiler's work much easier (we _always_ use `parentView!.` instead of
  // conditionally).
  @override
  RenderView? get parentView => _data.parentView;

  @override
  int get parentIndex => _data.parentIndex;

  @override
  List<List<Object>> get projectedNodes => _data.projectedNodes;

  @override
  bool get destroyed => _data.destroyed;

  // A convenience getter exposed for generated code.
  Map<String, dynamic> get locals => _data.locals;

  @override
  List<Node> get rootNodes => viewFragment!.flattenDomNodes();

  @override
  ViewFragment? get viewFragment => _data.viewFragment;

  @override
  bool hasLocal(String name) => locals.containsKey(name);

  @override
  void setLocal(String name, dynamic value) {
    locals[name] = value;
  }

  // Initialization ------------------------------------------------------------

  /// Creates this view.
  void create() {
    // Unlike component and host views, embedded views don't require any
    // additional setup before calling `build()`, but we wrap it anyways to keep
    // `View.build()` protected.
    build();
  }

  /// Optimized [initRootNodesAndSubscriptions] for a `<template>` with a single
  /// root node and no output subscriptions.
  @dart2js.noInline
  void initRootNode(Object rootNodeOrViewContainer) {
    initRootNodesAndSubscriptions([rootNodeOrViewContainer], null);
  }

  /// Called by [build] once all root node and subscriptions are created.
  @dart2js.noInline
  void initRootNodesAndSubscriptions(
    List<Object> rootNodesOrViewContainers,
    List<StreamSubscription<void>>? subscriptions,
  ) {
    _data
      ..viewFragment = ViewFragment(rootNodesOrViewContainers)
      ..subscriptions = subscriptions;
  }

  // Destruction ---------------------------------------------------------------

  @override
  void destroy() {
    final viewContainer = _data.viewContainer;
    viewContainer?.detachView(viewContainer.nestedViews!.indexOf(this));
    destroyInternalState();
  }

  @override
  void destroyInternalState() {
    if (!_data.destroyed) {
      _data.destroy();
      destroyInternal();
      dirtyParentQueriesInternal();
    }
  }

  @override
  void onDestroy(void Function() callback) {
    _data.addOnDestroyCallback(callback);
  }

  // Change detection ----------------------------------------------------------

  @override
  bool get firstCheck =>
      _data.changeDetectorState == ChangeDetectorState.neverChecked;

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

  // View manipulation ---------------------------------------------------------

  @override
  void addRootNodesAfter(Node node) {
    insertNodesAsSibling(rootNodes, node);
    domRootRendererIsDirty = true;
  }

  @override
  void removeRootNodes() {
    // Cache to avoid computing twice.
    final rootNodes = this.rootNodes;
    removeNodes(rootNodes);
    domRootRendererIsDirty = domRootRendererIsDirty || rootNodes.isNotEmpty;
  }

  /// Marks queries in parent views as dirty.
  ///
  /// Implementations may override this method to mark parent queries for
  /// reevaluation as a result of changes within this view.
  @protected
  void dirtyParentQueriesInternal() {}

  @override
  void wasInserted(ViewContainer viewContainer) {
    _data.viewContainer = viewContainer;
    dirtyParentQueriesInternal();
  }

  @override
  void wasMoved() {
    dirtyParentQueriesInternal();
  }

  @override
  void wasRemoved() {
    dirtyParentQueriesInternal();
    _data.viewContainer = null;
  }
}

/// Data for [EmbeddedView] bundled together as an optimization.
@sealed
class _EmbeddedViewData<T> implements DynamicViewData, RenderViewData {
  @dart2js.noInline
  factory _EmbeddedViewData(RenderView parentView, int parentIndex) {
    return _EmbeddedViewData._(parentView, parentIndex);
  }

  _EmbeddedViewData._(this.parentView, this.parentIndex)
      :
        // The `parentView` is always a `ComponentView<T>` or `EmbeddedView<T>`
        // but `RenderView` lacks this type parameter (to avoid the cost of
        // reifying it), so the cast is necessary, but safe.
        ctx = unsafeCast(parentView.ctx),
        componentStyles = parentView.componentStyles,
        projectedNodes = parentView.projectedNodes;

  /// Storage for [RenderView.ctx].
  final T ctx;

  /// Storage for [RenderView.componentStyles].
  final ComponentStyles componentStyles;

  @override
  final RenderView parentView;

  @override
  final int parentIndex;

  @override
  final List<List<Object>> projectedNodes;

  /// Storage for any template local variables defined for this view.
  final locals = <String, dynamic>{};

  @override
  ViewFragment? viewFragment;

  @override
  ViewContainer? viewContainer;

  @override
  List<StreamSubscription<void>>? subscriptions;

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
    final subscriptions = this.subscriptions;
    if (subscriptions != null) {
      for (var i = 0, length = subscriptions.length; i < length; ++i) {
        subscriptions[i].cancel();
      }
    }
  }

  void _updateShouldSkipChangeDetection() {
    _shouldSkipChangeDetection = _changeDetectionMode ==
            ChangeDetectionCheckedState.waitingToBeAttached ||
        _changeDetectorState == ChangeDetectorState.errored;
  }
}
