import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:ngcompiler/v1/angular_compiler.dart';
import 'package:ngcompiler/v1/cli.dart';
import 'package:ngcompiler/v1/src/compiler/module/ng_compiler_module.dart';

import 'check_injectables.dart';
import 'template_compiler_outputs.dart';

/// Given an input [library] `a.dart`, returns output for `a.template.dart`.
///
/// "Output" here is defined in terms of [TemplateCompilerOutput], or an
/// abstract collection of elements that need to be emitted into the
/// corresponding `.template.dart` file. See [TemplateCompilerOutput].
Future<TemplateCompilerOutputs> processTemplates(
  LibraryElement library,
  BuildStep buildStep,
  CompilerFlags flags,
) async {
  // Temporary replace for `resolveReflectables` which is also
  // checks elements with `@Injectable()` annotation.
  checkInjectables(library);

  // Collect the elements to implement `@GeneratedInjector`(s).
  final injectors = InjectorReader.findInjectors(library);

  // Collect the elements to implement views for `@Component`(s).
  final compiler = createTemplateCompiler(buildStep, flags);
  final sourceModule = await compiler.compile(library);

  // Return them to be emitted to disk as generated code in the future.
  return TemplateCompilerOutputs(sourceModule, injectors);
}
