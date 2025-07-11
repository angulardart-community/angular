import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:ngdart/angular.dart';
import 'package:ngrouter/ngrouter.dart';
import 'package:ngrouter/testing.dart';
import 'package:ngtest/angular_test.dart';
import 'package:test/test.dart';
import 'package:web/web.dart' hide Location;

import 'router_link_directive_test.template.dart' as ng;

void main() {
  late FakeRouter fakeRouter;
  late InjectorFactory addInjector;

  setUp(() {
    fakeRouter = FakeRouter();
    addInjector = (i) {
      final strategy = MockLocationStrategy();
      return Injector.map({
        Location: Location(strategy),
        LocationStrategy: strategy,
        Router: fakeRouter,
      }, i);
    };
  });

  tearDown(disposeAnyRunningTest);

  test('should attempt to navigate to the provided link', () async {
    final fixture = await NgTestBed<TestRouterLink>(
      ng.createTestRouterLinkFactory(),
    ).addInjector(addInjector).create(beforeChangeDetection: (comp) {
      comp.routerLink = '/users/bob';
    });
    final anchor = fixture.rootElement.querySelector('a') as HTMLAnchorElement;
    expect(anchor.pathname, '/users/bob');
    expect(fakeRouter.lastNavigatedPath, isNull);
    await fixture.update((_) => anchor.click());
    expect(fakeRouter.lastNavigatedPath, '/users/bob');
  });

  test('should attempt to navigate on Enter key press', () async {
    final testBed = NgTestBed<TestRouterLinkKeyPress>(
      ng.createTestRouterLinkKeyPressFactory(),
    ).addInjector(addInjector);
    final testFixture = await testBed.create();
    final div = testFixture.rootElement.querySelector('div')!;
    final keyboardEvent = createKeyboardEvent('keypress', KeyCode.ENTER);
    expect(fakeRouter.lastNavigatedPath, isNull);
    await testFixture.update((_) => div.dispatchEvent(keyboardEvent));
    expect(fakeRouter.lastNavigatedPath, '/foo/bar');
  });

  test('should parse out query params and fragment', () async {
    final fixture = await NgTestBed<TestRouterLink>(
      ng.createTestRouterLinkFactory(),
    ).addInjector(addInjector).create(beforeChangeDetection: (comp) {
      comp.routerLink = '/users/bob?param1=one&param2=2#frag';
    });
    final anchor = fixture.rootElement.querySelector('a') as HTMLAnchorElement;
    expect(anchor.pathname, '/users/bob');
    await fixture.update((_) => anchor.click());
    expect(fakeRouter.lastNavigatedPath, '/users/bob');
    expect(fakeRouter.lastNavigatedParams?.queryParameters, {
      'param1': 'one',
      'param2': '2',
    });
    expect(fakeRouter.lastNavigatedParams?.fragment, 'frag');
  });

  test('should not use the router when the target is not _self', () async {
    final fixture = await NgTestBed<TestRouterLinkWithTarget>(
      ng.createTestRouterLinkWithTargetFactory(),
    ).addInjector(addInjector).create(beforeChangeDetection: (comp) {
      comp.routerLink = '/users/bob';
    });
    final anchor = fixture.rootElement.querySelector('a') as HTMLAnchorElement;
    expect(anchor.pathname, '/users/bob');
    expect(anchor.target, '_parent');
    await fixture.update((_) => anchor.click());
    expect(fakeRouter.lastNavigatedPath, isNull);
  });
}

@Component(
  selector: 'test-router-link',
  directives: [RouterLink],
  template: r'''
    <a [routerLink]="routerLink"></a>
  ''',
)
class TestRouterLink {
  late String routerLink;
}

@Component(
  selector: 'test-router-link-keypress',
  template: '<div [routerLink]="routerLink"></div>',
  directives: [RouterLink],
)
class TestRouterLinkKeyPress {
  String routerLink = '/foo/bar';
}

@Component(
  selector: 'test-router-link',
  directives: [RouterLink],
  template: r'''
    <a (click)="onClick($event)" [routerLink]="routerLink" target="_parent"></a>
  ''',
)
class TestRouterLinkWithTarget {
  late String routerLink;

  void onClick(MouseEvent event) {
    // Prevent navigating away from test page.
    event.preventDefault();
  }
}

class FakeRouter implements Router {
  String? lastNavigatedPath;
  NavigationParams? lastNavigatedParams;

  @override
  Future<NavigationResult> navigate(
    String routerLink, [
    NavigationParams? navigationParams,
  ]) async {
    lastNavigatedPath = routerLink;
    lastNavigatedParams = navigationParams;
    return NavigationResult.success;
  }

  @override
  dynamic noSuchMethod(i) => super.noSuchMethod(i);
}

const _createKeyboardEventName = '__dart_createKeyboardEvent';
const _createKeyboardEventScript = '''
window['$_createKeyboardEventName'] = function(
    type, keyCode, ctrlKey, altKey, shiftKey, metaKey) {
  var event = document.createEvent('KeyboardEvent');

  // Chromium hack.
  Object.defineProperty(event, 'keyCode', {
    get: function() { return keyCode; }
  });

  // Creating keyboard events programmatically isn't supported and relies on
  // these deprecated APIs.
  if (event.initKeyboardEvent) {
    event.initKeyboardEvent(type, true, true, document.defaultView, keyCode,
        keyCode, ctrlKey, altKey, shiftKey, metaKey);
  } else {
    event.initKeyEvent(type, true, true, document.defaultView, ctrlKey, altKey,
        shiftKey, metaKey, keyCode, keyCode);
  }

  return event;
}
''';

Event createKeyboardEvent(
  String type,
  int keyCode, {
  bool ctrlKey = false,
  bool altKey = false,
  bool shiftKey = false,
  bool metaKey = false,
}) {
  if (!globalContext.has(_createKeyboardEventName)) {
    final script = document.createElement('script')
      ..setAttribute('type', 'text/javascript')
      ..textContent = _createKeyboardEventScript;
    document.body!.append(script);
  }
  return globalContext.callMethodVarArgs(
    _createKeyboardEventName.toJS,
    [
      type.toJS,
      keyCode.toJS,
      ctrlKey.toJS,
      altKey.toJS,
      shiftKey.toJS,
      metaKey.toJS,
    ],
  ) as Event;
}
