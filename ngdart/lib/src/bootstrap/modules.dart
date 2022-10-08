import 'dart:math';

import 'package:ngdart/src/core/application_tokens.dart';
import 'package:ngdart/src/core/exception_handler.dart';
import 'package:ngdart/src/core/linker/component_loader.dart';
import 'package:ngdart/src/di/injector.dart';

/// Returns a simple application [Injector] that is hand-authored.
///
/// Some of the services provided below ([ExceptionHandler], [APP_ID]) may be
/// overriden by the user-supplied injector - the returned [Injector] is
/// used as the "base" application injector.
Injector minimalApp() {
  return Injector.map({
    APP_ID: _createRandomAppId(),
    ExceptionHandler: const ExceptionHandler(),
    ComponentLoader: const ComponentLoader(),
  });
}

/// Creates a random [APP_ID] for use in CSS encapsulation.
String _createRandomAppId() {
  final random = Random();
  String char() => String.fromCharCode(97 + random.nextInt(26));
  return '${char()}${char()}${char()}';
}
