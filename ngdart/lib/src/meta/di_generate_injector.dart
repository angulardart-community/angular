import 'package:meta/meta_meta.dart';

import '../di/injector.dart';
import 'di_modules.dart';

/// Annotates a method to generate an [Injector] factory at compile-time.
///
/// Using `@GenerateInjector` is conceptually similar to using `@Component` or
/// `@Directive` with a `providers: [ ... ]` argument, but like a
/// component or directive that injector is generated ahead of time, during
/// compilation:
///
/// ```
/// import 'my_file.template.dart' as ng;
///
/// @GenerateInjector([ClassProvider(A, APrime)])
/// // The generated factory is your method's name, suffixed with `$Injector`.
/// final InjectorFactory example = example$Injector;
/// ```
@Target({TargetKind.topLevelVariable})
class GenerateInjector {
  // Used internally via analysis only.
  // ignore: unused_field
  final List<Object> _providersOrModules;

  const GenerateInjector(this._providersOrModules);

  /// Generate an [Injector] from [Module]s instead of untyped lists.
  const factory GenerateInjector.fromModules(
    List<Module> modules,
  ) = GenerateInjector;
}
