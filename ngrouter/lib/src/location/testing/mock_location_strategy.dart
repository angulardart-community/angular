import 'dart:async';

import 'package:ngdart/angular.dart' show Injectable;
import 'package:ngrouter/src/location/location_strategy.dart'
    show LocationStrategy;
import 'package:web/web.dart' hide Location;

/// A mock implementation of [LocationStrategy] that allows tests to fire
/// simulated location events.
@Injectable()
class MockLocationStrategy extends LocationStrategy {
  String internalBaseHref = '/';
  String internalPath = '/';
  String internalTitle = '';
  String internalHash = '';
  List<String> urlChanges = [];

  final _subject = StreamController<PopStateEvent>();

  void simulatePopState(String url) {
    internalPath = url;
    _subject.add(PopStateEvent('popstate'));
  }

  @override
  String hash() => internalHash;

  @override
  String path() => internalPath;

  @override
  String prepareExternalUrl(String internal) {
    if (internal.startsWith('/') && internalBaseHref.endsWith('/')) {
      return internalBaseHref + internal.substring(1);
    }
    return internalBaseHref + internal;
  }

  @override
  void pushState(Object? state, String title, String url, String queryParams) {
    internalTitle = title;
    var internalUrl = url + (queryParams.isNotEmpty ? '?$queryParams' : '');
    internalPath = internalUrl;
    var externalUrl = prepareExternalUrl(internalUrl);
    urlChanges.add(externalUrl);
  }

  @override
  void replaceState(
      Object? state, String title, String url, String queryParams) {
    internalTitle = title;
    var fullUrl = url + (queryParams.isNotEmpty ? '?$queryParams' : '');
    internalPath = fullUrl;
    var externalUrl = prepareExternalUrl(fullUrl);
    urlChanges.add('replace: $externalUrl');
  }

  @override
  void onPopState(void Function(Event event) fn) {
    _subject.stream.listen(fn);
  }

  @override
  String getBaseHref() => internalBaseHref;

  @override
  void back() {
    while (urlChanges.isNotEmpty && urlChanges.last.startsWith('replace: ')) {
      urlChanges.removeLast();
    }
    if (urlChanges.isNotEmpty) {
      urlChanges.removeLast();
      var nextUrl = urlChanges.isNotEmpty ? urlChanges.last : '';
      if (nextUrl.startsWith('replace: ')) {
        nextUrl = nextUrl.substring('replace: '.length);
      }
      simulatePopState(nextUrl);
    }
  }

  @override
  void forward() {
    throw UnimplementedError('not implemented');
  }
}
