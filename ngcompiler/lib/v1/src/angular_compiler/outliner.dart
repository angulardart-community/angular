import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:path/path.dart' as p;

import 'analyzer.dart';
import 'outliner/collect_type_parameters.dart';

const _angularImports = '''
import 'package:ngdart/angular.dart' as _ng;
import 'package:ngdart/src/core/change_detection/directive_change_detector.dart' as _ng;
import 'package:ngdart/src/core/linker/views/component_view.dart' as _ng;
import 'package:ngdart/src/core/linker/views/render_view.dart' as _ng;
import 'package:ngdart/src/core/linker/views/view.dart' as _ng;
import 'package:web/web.dart' as _html;
''';

const _analyzerIgnores =
    '// ignore_for_file: library_prefixes,unused_import,strict_raw_type,'
    'undefined_hidden_name';

String _typeArgumentsFor(ClassElement element) {
  if (element.typeParameters.isEmpty) {
    return '';
  }
  final buffer = StringBuffer('<')
    ..writeAll(element.typeParameters.map((t) => t.name), ', ')
    ..write('>');
  return buffer.toString();
}

/// Generates an _outline_ of the public API of a `.template.dart` file.
///
/// Used as part of some compile processes in order to speed up incremental
/// builds by taking the full compile (actual generation of `.template.dart`
/// off the critical path).
class TemplateOutliner implements Builder {
  final String _extension;

  final bool exportUserCodeFromTemplate;

  TemplateOutliner({
    required String extension,
    required this.exportUserCodeFromTemplate,
  })  : _extension = extension,
        buildExtensions = {
          '.dart': [extension],
        };

  @override
  Future<void> build(BuildStep buildStep) async {
    if (!await buildStep.resolver.isLibrary(buildStep.inputId)) {
      return;
    }
    final library = await buildStep.inputLibrary;
    final components = <ClassElement>[];
    final directives = <ClassElement>[];
    final injectors = <String>[];
    var types = library.children.whereType<ClassElement>().toList();
    var fields = library.children.whereType<TopLevelVariableElement>().toList();
    for (final clazz in types) {
      final component = $Component.firstAnnotationOfExact(
        clazz,
        throwOnUnresolved: false,
      );
      if (component != null) {
        components.add(clazz);
      } else {
        final directive = $Directive.firstAnnotationOfExact(
          clazz,
          throwOnUnresolved: false,
        );
        if (directive != null) {
          directives.add(clazz);
        }
      }
    }
    for (final field in fields) {
      if ($GenerateInjector.hasAnnotationOfExact(
        field,
        throwOnUnresolved: false,
      )) {
        injectors.add('${field.name}\$Injector');
      }
    }
    // Unlike the main compiler, we do not do an allow-list check here; this is
    // both to speed up the outliner (reducing duplicate checks) and because we
    // do not have a configured CompileContext when the outliner is run.
    final emitNullSafeCode = library.isNonNullableByDefault;
    final languageVersion = emitNullSafeCode ? '' : '// @dart=2.9\n\n';
    final output = StringBuffer('$languageVersion$_analyzerIgnores\n');
    if (exportUserCodeFromTemplate) {
      output
        ..writeln('// The .template.dart files also export the user code.')
        ..writeln("export '${p.basename(buildStep.inputId.path)}';")
        ..writeln();
    }
    if (components.isNotEmpty ||
        directives.isNotEmpty ||
        injectors.isNotEmpty) {
      output
        ..writeln('// Required for referencing runtime code.')
        ..writeln(_angularImports);
      final userLandCode = p.basename(buildStep.inputId.path);
      output
        ..writeln('// Required for specifically referencing user code.')
        ..writeln("import '$userLandCode';")
        ..writeln();
    }

    output.writeln('// Required for "type inference" (scoping).');
    for (final l in library.libraryImports) {
      if (l.prefix is! DeferredImportElementPrefix) {
        var directive = "import '${l.uri}'";
        if (l.prefix != null) {
          directive += ' as ${l.prefix!.element.name}';
        }
        if (l.combinators.isNotEmpty) {
          final isShow = l.combinators.first is ShowElementCombinator;
          directive += isShow ? ' show ' : ' hide ';
          directive += l.combinators
              .map((c) {
                if (c is ShowElementCombinator) {
                  return c.shownNames;
                }
                if (c is HideElementCombinator) {
                  return c.hiddenNames;
                }
                return const <Object>[];
              })
              .expand((i) => i)
              .join(', ');
        }
        output.writeln('$directive;');
      }
    }
    output.writeln();
    final directiveTypeParameters = await collectTypeParameters(
        components.followedBy(directives), buildStep);
    if (components.isNotEmpty) {
      for (final component in components) {
        final componentName = component.name;
        final typeArguments = _typeArgumentsFor(component);
        final typeParameters = directiveTypeParameters[component.name];
        final componentType = '$componentName$typeArguments';
        final viewName = 'View${componentName}0';
        output.write('''
// For @Component class $componentName.
external List<dynamic> get styles\$$componentName;
external _ng.ComponentFactory<$componentName> get ${componentName}NgFactory;
external _ng.ComponentFactory<$componentType> create${componentName}Factory$typeParameters();
class $viewName$typeParameters extends _ng.ComponentView<$componentType> {
  external $viewName(_ng.View parentView, int parentIndex);
  external String get debugComponentTypeName;
}
''');
      }
    }
    if (directives.isNotEmpty) {
      for (final directive in directives) {
        final directiveName = directive.name;
        final changeDetectorName = '${directiveName}NgCd';
        final typeArguments = _typeArgumentsFor(directive);
        final typeParameters = directiveTypeParameters[directive.name];
        final directiveType = '$directiveName$typeArguments';
        output.write('''
// For @Directive class $directiveName.
class $changeDetectorName$typeParameters extends _ng.DirectiveChangeDetector {
  external $directiveType get instance;
  external void deliverChanges();
  external $changeDetectorName($directiveType instance);
  external void detectHostChanges(_ng.RenderView view, _html.Element hostElement);
}
''');
      }
    }
    if (injectors.isNotEmpty) {
      for (final injector in injectors) {
        output.writeln('external _ng.Injector $injector(_ng.Injector parent);');
      }
    }
    await buildStep.writeAsString(
      buildStep.inputId.changeExtension(_extension),
      output.toString(),
    );
  }

  @override
  final Map<String, List<String>> buildExtensions;
}
