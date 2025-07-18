import 'dart:async';
import 'dart:js_interop';

import 'package:ngdart/angular.dart';
import 'package:ngrouter/ngrouter.dart';
import 'package:ngrouter/testing.dart';
import 'package:test/test.dart';
import 'package:web/web.dart';

import 'routing_state_crash_test.template.dart' as ng;

void main() {
  test('should not crash entire app when a routed component throws', () async {
    final appComponent = runApp<AppComponent>(
      ng.createAppComponentFactory(),
      createInjector: (parent) {
        final ngZone = parent.provideType<NgZone>(NgZone);
        return Injector.map({
          ExceptionHandler: LoggingExceptionHandler(),
          Testability: Testability(ngZone),
          TestabilityRegistry: TestabilityRegistry(),
        }, parent);
      },
    );
    Future<void> onStable() => appComponent.instance.onStable;

    E query<E extends Element>(String selector) {
      return appComponent.location.querySelector(selector) as E;
    }

    final locationStrategy = appComponent.instance._locationStrategy;
    final routeContainer = query('.route-container');

    await onStable();
    expect(_logs, isEmpty);
    expect(locationStrategy.path(), isEmpty);
    expect(routeContainer.textContent, contains('Home Page'));

    // "Navigate" to /another
    await appComponent.instance.updateUrl('/another');
    expect(_logs, isEmpty);
    expect(routeContainer.textContent, contains('Another Page'));

    // "Navigate" to /throws.
    await appComponent.instance.updateUrl('/throws');
    expect(_logs, [contains('$IntentionalException')]);
    // Since navigation fails, we should still be at the previous route.
    expect(routeContainer.textContent, contains('Another Page'));

    // "Navigate" back to /home.
    _logs.clear();
    await appComponent.instance.updateUrl('/home');
    expect(_logs, isEmpty);
    expect(routeContainer.textContent, contains('Home Page'));
  });
}

/// Exceptions that have been caught by the [ExceptionHandler].
final _logs = <String>[];

class ServiceThatThrows {
  bool get getterThatThrows {
    throw IntentionalException();
  }
}

/// A custom [ExceptionHandler] that writes to the top-level [_logs] field.
class LoggingExceptionHandler implements ExceptionHandler {
  LoggingExceptionHandler() {
    _logs.clear();
  }

  @override
  void call(exception, [stack, __]) {
    _logs.add('$exception: $stack');

    if (exception is! IntentionalException) {
      console.error('$exception\n$stack'.toJS);
    } else {
      console.info('ExceptionHandler caught the intentional exception'.toJS);
    }
  }
}

@Component(
  selector: 'app',
  template: r'''
    <form class="url-form" (submit)="updateUrl(urlBar.value!)">
      <label for="url-bar">Mock URL: </label>
      <input #urlBar id="url-bar" [value]="currentUrl" />
      <button type="submit">Update</button>
    </form>

    Navigation:
    <a routerLink="/home">Home</a> |
    <a routerLink="/throws">Throws</a> |
    <a routerLink="/another">Another</a>

    Page:
    <div class="route-container">
      <router-outlet [routes]="routes"></router-outlet>
    </div>
  ''',
  directives: [
    RouterLink,
    RouterOutlet,
  ],
  providers: [
    routerProvidersTest,
    ClassProvider(ServiceThatThrows),
  ],
)
class AppComponent {
  static final routes = [
    RouteDefinition(
      path: 'home',
      useAsDefault: true,
      component: ng.createHomeComponentFactory(),
    ),
    RouteDefinition(
      path: 'another',
      component: ng.createAnotherComponentFactory(),
    ),
    RouteDefinition(
      path: 'throws',
      component: ng.createThrowingComponentFactory(),
    ),
  ];

  final MockLocationStrategy _locationStrategy;
  final NgZone _ngZone;
  final Testability _testability;

  AppComponent(
    @Inject(LocationStrategy) this._locationStrategy,
    this._ngZone,
    this._testability,
  );

  String get currentUrl => _locationStrategy.path();

  /// Returns a future that completes when [Testability] reports stability.
  Future<void> get onStable async {
    // Await an artificial amount of extra time.
    await Future.delayed(Duration.zero);

    // Then wait for an async completion.
    final completer = Completer<void>();
    _testability.whenStable(completer.complete);
    return completer.future;
  }

  /// Updates the application [LocationStrategy] as-if the URL was changed.
  ///
  /// Can also be used as a poor-man's stability API.
  ///
  /// Returns a [Future] that completes (a) after changing and (b) after stable.
  Future<void> updateUrl(String newUrl) {
    // Enters the zone manually if needed.
    return _ngZone.run(() {
      _locationStrategy.simulatePopState(newUrl);
      return onStable;
    });
  }
}

@Component(
  selector: 'home',
  template: 'Home Page',
)
class HomeComponent {}

@Component(
  selector: 'another',
  template: 'Another Page',
)
class AnotherComponent {}

@Component(
  selector: 'throws',
  directives: [
    NgIf,
  ],
  template: r'''
    <ng-container *ngIf="service.getterThatThrows">
      Should not be shown.
    </ng-container>
  ''',
)
class ThrowingComponent {
  final ServiceThatThrows service;

  ThrowingComponent(this.service);
}

class IntentionalException implements Exception {}
