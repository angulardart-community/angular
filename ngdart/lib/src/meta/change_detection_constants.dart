/// Describes the current state of the change detector.
class ChangeDetectorState {
  /// [neverChecked] means that the change detector has not been checked yet,
  /// and initialization methods should be called during detection.
  static const int neverChecked = 0;

  /// [checkedBefore] means that the change detector has successfully completed
  /// at least one detection previously.
  static const int checkedBefore = 1;

  /// [errored] means that the change detector encountered an error checking a
  /// binding or calling a directive lifecycle method and is now in an
  /// inconsistent state. Change detectors in this state will no longer detect
  /// changes.
  static const int errored = 2;
}

/// Describes within the change detector which strategy will be used the next
/// time change detection is triggered.
///
/// ! Changes to this class require updates to view_compiler/constants.dart.
class ChangeDetectionStrategy {
  /// The default type of change detection, always checking for changes.
  ///
  /// When an asynchronous event (such as user interaction or an RPC) occurs
  /// within the app, the root component of the app is checked for changes,
  /// and then all children in a depth-first search.
  static const int default_ = 0;

  @Deprecated('Not intended to be a public API. Use "onPush" instead.')
  static const int checkOnce = ChangeDetectionCheckedState.checkOnce;

  @Deprecated('Not intended to be a public API. Use "onPush" instead.')
  static const int checked = ChangeDetectionCheckedState.waitingForMarkForCheck;

  @Deprecated('Not intended to be a public API. Use "default_" instead.')
  static const int checkAlways = ChangeDetectionCheckedState.checkAlways;

  @Deprecated('Not intended to be a public API. Use "ChangeDetectorRef.detach" instead.')
  static const int detached = ChangeDetectionCheckedState.waitingToBeAttached;

  /// An optimized form of change detection, skipping some checks for changes.
  ///
  /// Unlike [default_], [onPush] waits for the following signals to check a
  /// component:
  /// * An `@Input()` on the component being changed.
  /// * An `@Output()` or event listener (i.e. `(click)="..."`) being executed
  ///   in the template of the component or a descendant.
  /// * A call to `<ChangeDetectorRef>.markForCheck()` in the component or a
  ///   descendant.
  ///
  /// Otherwise, change detection is skipped for this component and its
  /// descendants. An [onPush] configured component as a result can afford to be
  /// a bit less defensive about caching the result of bindings, for example.
  ///
  /// **WARNING**: It is currently _undefined behavior_ to have a [default_]
  /// configured component as a child (or directive) of a component that is
  /// using [onPush]. We hope to introduce more guidance here in the future.
  static const int onPush = 5;

  static String toPrettyString(int strategy) {
    switch (strategy) {
      case default_:
        return 'default';
      case onPush:
        return 'onPush';
      default:
        return 'internal';
    }
  }
}

/// **TRANSITIONAL**: These are runtime internal states to the `AppView`.
///
/// TODO(b/128441899): Refactor into a change detection state machine.
class ChangeDetectionCheckedState {
  /// `AppView.detectChanges` should be invoked once.
  ///
  /// The next state is [waitingForMarkForCheck].
  static const int checkOnce = 1;

  /// `AppView.detectChanges` should bail out.
  ///
  /// Upon use of `AppView.markForCheck`, the next state is [checkOnce].
  static const int waitingForMarkForCheck = 2;

  /// `AppView.detectChanges` should always be invoked.
  static const int checkAlways = 3;

  /// `AppView.detectChanges` should bail out.
  ///
  /// Attaching a view should transition to either [checkOnce] or [checkAlways]
  /// depending on whether `onPush` or `default_` change detection strategies are
  /// configured for the view.
  static const int waitingToBeAttached = 4;
}
