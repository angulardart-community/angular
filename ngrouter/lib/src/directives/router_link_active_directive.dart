import 'dart:async';

import 'package:collection/collection.dart';
import 'package:ngdart/angular.dart';
import 'package:ngdart/src/utilities.dart';
import 'package:web/web.dart';

import '../router/router.dart';
import '../router/router_state.dart';
import 'router_link_directive.dart';

/// Adds a CSS class to the bound element when the link's route becomes active.
///
/// ```html
/// <a routerLink="/user/bob" routerLinkActive="active-link">Bob</a>
/// ```
///
/// May also be used on an element containing a [RouterLink].
/// ```html
/// <div routerLinkActive="active-link">
///   <a routerLink="/user/bob">Bob</a>
/// </div>
/// ```
@Directive(
  selector: '[routerLinkActive]',
)
class RouterLinkActive implements AfterViewInit, OnDestroy {
  final Element _element;
  final Router _router;

  late StreamSubscription<RouterState> _routeChanged;
  late List<String> _classes;

  @ContentChildren(RouterLink)
  List<RouterLink>? links;

  RouterLinkActive(this._element, this._router);

  @override
  void ngOnDestroy() => _routeChanged.cancel();

  @override
  void ngAfterViewInit() {
    _routeChanged = _router.stream.listen(_update);
    _update(_router.current);
  }

  @Input()
  set routerLinkActive(Object classes) {
    if (classes is String) {
      _classes = [classes];
    } else if (classes is List<String>) {
      _classes = classes;
    } else if (isDevMode) {
      throw ArgumentError(
        'Expected a string or list of strings. Got $classes.',
      );
    }
  }

  void _update(RouterState? routerState) {
    var isActive = false;
    var links = this.links;
    if (routerState != null && links != null) {
      for (var link in links) {
        final url = link.url;
        if (url.path != routerState.path) continue;
        // Only compare query parameters if specified in the [routerLink].
        if (url.queryParameters.isNotEmpty &&
            !const MapEquality<String, String>()
                .equals(url.queryParameters, routerState.queryParameters)) {
          continue;
        }
        // Only compare fragment identifier if specified in the [routerLink].
        if (url.fragment.isNotEmpty && url.fragment != routerState.fragment) {
          continue;
        }
        // The link matches the current router state and should be activated.
        isActive = true;
        break;
      }
    }
    _element.classList.toggleAll(_classes, isActive);
  }
}

extension on DOMTokenList {
  void toggleAll(Iterable<String> iterable, bool shouldAdd) {
    for (var e in iterable) {
      toggle(e, shouldAdd);
    }
  }

  // bool toggle(String value, [bool? shouldAdd]) {
  //   _validateToken(value);
  //   Set<String> s = readClasses();
  //   bool result = false;
  //   if (shouldAdd == null) shouldAdd = !s.contains(value);
  //   if (shouldAdd) {
  //     s.add(value);
  //     result = true;
  //   } else {
  //     s.remove(value);
  //   }
  //   writeClasses(s);
  //   return result;
  // }
}
