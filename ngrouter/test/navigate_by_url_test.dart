import 'package:collection/collection.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ngrouter/ngrouter.dart';
import 'package:ngrouter/src/router/router_impl.dart';
import 'package:ngrouter/testing.dart';
import 'package:ngtest/angular_test.dart';
import 'package:test/test.dart';

@GenerateMocks([Router])
import 'navigate_by_url_test.mocks.dart'; // ignore: uri_does_not_exist

void main() {
  tearDown(disposeAnyRunningTest);

  group('navigateByUrl', () {
    // ignore: undefined_class
    late MockRouter mockRouter;
    late Router router;

    setUp(() {
      // ignore: undefined_function
      mockRouter = MockRouter();
      router = DelegatingRouter(mockRouter);
    });

    tearDown(() {
      reset(mockRouter);
    });

    test('invokes navigate', () {
      when(mockRouter.navigate('/to/path', any))
          .thenAnswer((_) => Future.value(NavigationResult.success));
      router.navigateByUrl('/to/path');
      verify(mockRouter.navigate('/to/path', argThat(navigationParams())));
    });

    test('invokes navigate with query parameters', () {
      when(mockRouter.navigate('/to/path', any))
          .thenAnswer((_) => Future.value(NavigationResult.success));
      router.navigateByUrl('/to/path?q=hello%20world');
      verify(mockRouter.navigate('/to/path',
          argThat(navigationParams(queryParameters: {'q': 'hello world'}))));
    });

    test('invokes navigate with fragment identifier', () {
      when(mockRouter.navigate('/to/path', any))
          .thenAnswer((_) => Future.value(NavigationResult.success));
      router.navigateByUrl('/to/path#with-fragment');
      verify(mockRouter.navigate(
          '/to/path', argThat(navigationParams(fragment: 'with-fragment'))));
    });

    test('invokes navigate with reload', () {
      when(mockRouter.navigate('/to/path', any))
          .thenAnswer((_) => Future.value(NavigationResult.success));
      router.navigateByUrl('/to/path', reload: true);
      verify(mockRouter.navigate(
          '/to/path', argThat(navigationParams(reload: true))));
    });

    test('invokes navigate with replace', () {
      when(mockRouter.navigate('/to/path', any))
          .thenAnswer((_) => Future.value(NavigationResult.success));
      router.navigateByUrl('/to/path', replace: true);
      verify(mockRouter.navigate(
          '/to/path', argThat(navigationParams(replace: true))));
    });
  });
}

class DelegatingRouter extends RouterImpl {
  final Router _delegate;

  DelegatingRouter(this._delegate)
      : super(Location(MockLocationStrategy()), null);

  @override
  Future<NavigationResult> navigate(
    String path, [
    NavigationParams? navigationParams,
  ]) =>
      _delegate.navigate(path, navigationParams);
}

Matcher navigationParams({
  Map<String, String> queryParameters = const {},
  String fragment = '',
  bool reload = false,
  bool replace = false,
}) =>
    NavigationParamsMatcher(NavigationParams(
      queryParameters: queryParameters,
      fragment: fragment,
      reload: reload,
      replace: replace,
    ));

class NavigationParamsMatcher extends Matcher {
  final NavigationParams navigationParams;

  NavigationParamsMatcher(this.navigationParams);

  @override
  bool matches(item, void _) {
    return item is NavigationParams &&
        const MapEquality()
            .equals(item.queryParameters, navigationParams.queryParameters) &&
        item.fragment == navigationParams.fragment &&
        item.reload == navigationParams.reload &&
        item.replace == navigationParams.replace &&
        item.updateUrl == navigationParams.updateUrl;
  }

  @override
  Description describe(Description description) {
    return _describeNavigationParams(
        description.add('NavigationParams with '), navigationParams);
  }

  @override
  Description describeMismatch(
    item,
    Description mismatchDescription,
    Map<Object?, Object?> matchState,
    bool verbose,
  ) {
    if (item is NavigationParams) {
      return _describeNavigationParams(mismatchDescription.add('has '), item);
    }
    return super.describeMismatch(
      item,
      mismatchDescription,
      matchState,
      verbose,
    );
  }

  Description _describeNavigationParams(
    Description description,
    NavigationParams navigationParams,
  ) {
    return description
        .add('{ queryParameters: ')
        .addDescriptionOf(navigationParams.queryParameters)
        .add(', fragment: ')
        .addDescriptionOf(navigationParams.fragment)
        .add(', reload: ')
        .addDescriptionOf(navigationParams.reload)
        .add(', replace: ')
        .addDescriptionOf(navigationParams.replace)
        .add(', updateUrl: ')
        .addDescriptionOf(navigationParams.updateUrl)
        .add('}');
  }
}
