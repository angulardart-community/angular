/// Describes the current state of the change detector.
enum ChangeDetectorState {
  /// [neverChecked] means that the change detector has not been checked yet,
  /// and initialization methods should be called during detection.
  neverChecked,

  /// [checkedBefore] means that the change detector has successfully completed
  /// at least one detection previously.
  checkedBefore,

  /// [errored] means that the change detector encountered an error checking a
  /// binding or calling a directive lifecycle method and is now in an
  /// inconsistent state. Change detectors in this state will no longer detect
  /// changes.
  errored,
}

/// Describes within the change detector which strategy will be used the next
/// time change detection is triggered.
///
/// ! Changes to this class require updates to view_compiler/constants.dart.
enum ChangeDetectionStrategy {
  /// The default type of change detection, always checking for changes.
  ///
  /// When an asynchronous event (such as user interaction or an RPC) occurs
  /// within the app, the root component of the app is checked for changes,
  /// and then all children in a depth-first search.
  checkAlways,

  /// An optimized form of change detection, skipping some checks for changes.
  ///
  /// Unlike [checkAlways], [onPush] waits for the following signals to check a
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
  /// **WARNING**: It is currently _undefined behavior_ to have a [checkAlways]
  /// configured component as a child (or directive) of a component that is
  /// using [OnPush]. We hope to introduce more guidance here in the future.
  onPush,
}

/// **TRANSITIONAL**: These are runtime internal states to the `AppView`.
///
/// TODO(b/128441899): Refactor into a change detection state machine.
enum ChangeDetectionCheckedState {
  /// `AppView.detectChanges` should be invoked once.
  ///
  /// The next state is [waitingForMarkForCheck].
  checkOnce,

  /// `AppView.detectChanges` should bail out.
  ///
  /// Upon use of `AppView.markForCheck`, the next state is [checkOnce].
  waitingForMarkForCheck,

  /// `AppView.detectChanges` should always be invoked.
  checkAlways,

  /// `AppView.detectChanges` should bail out.
  ///
  /// Attaching a view should transition to either [checkOnce] or [checkAlways]
  /// depending on whether `OnPush` or `Default` change detection strategies are
  /// configured for the view.
  waitingToBeAttached,
}
