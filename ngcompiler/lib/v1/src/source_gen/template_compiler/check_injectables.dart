import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:ngcompiler/v2/context.dart';
import 'package:path/path.dart' as p;
import 'package:ngcompiler/v1/angular_compiler.dart';
import 'package:ngcompiler/v1/cli.dart';

const DependencyReader dependencyReader = DependencyReader();

// TODO: try to inline
// Temporary replace for `resolveReflectables` which is also
// checks elements with `@Injectable()` annotation.
void checkInjectables(LibraryElement library) {
  for (var unit in allUnits(library)) {
    for (var type in unit.classes) {
      checkClass(type);
      checkFunctions(type.methods);
    }

    checkFunctions(unit.functions);
  }
}

Iterable<CompilationUnitElement> allUnits(LibraryElement library) sync* {
  yield library.definingCompilationUnit;
  yield* library.parts;
}

void checkClass(ClassElement element) {
  if ($Injectable.hasAnnotationOfExact(element)) {
    if (element.isPrivate) {
      throw BuildError.forElement(
        element,
        'Private classes can not be @Injectable',
      );
    }

    dependencyReader.parseDependencies(element);
  }
}

void checkFunction(ExecutableElement element) {
  if ($Injectable.firstAnnotationOfExact(element) == null) {
    return;
  }

  if (!element.isStatic) {
    throw BuildError.forElement(
      element,
      'Non-static functions can not be @Injectable',
    );
  }

  if (element.isPrivate) {
    throw BuildError.forElement(
      element,
      'Private functions can not be @Injectable',
    );
  }

  dependencyReader.parseDependencies(element);
}

void checkFunctions(Iterable<ExecutableElement> elements) {
  for (var element in elements) {
    checkFunction(element);
  }
}
