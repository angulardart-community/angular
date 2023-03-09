import 'package:ngdart/src/meta.dart';

/// A dependency injection token representing a unique ID for the application.
///
/// The identifier is used internally to apply CSS scoping behavior.
///
/// To avoid a randomly generated value, a custom value can be provided:
/// ```dart
///   bootstrapStatic(
///     YourAppComponent,
///     const [
///       const Provider(appId, useValue: 'my-unique-id'),
///     ],
///   )
/// ```
const appId = OpaqueToken<String>('appId');
