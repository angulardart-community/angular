import 'package:code_builder/code_builder.dart';

// Unlike the default [DartEmitter], this has two output buffers, which is used
// transitionally since other parts of the AngularDart compiler write code based
// on the existing "Output AST" format (string-based).
//
// Once/if all code is using code_builder, this can be safely removed.
class SplitDartEmitter extends DartEmitter {
  final StringSink? _writeImports;

  SplitDartEmitter(
    this._writeImports, {
    Allocator allocator = Allocator.none,
    bool emitNullSafeSyntax = false,
  }) : super(
          allocator: allocator,
          orderDirectives: false,
          useNullSafetySyntax: emitNullSafeSyntax,
        );

  @override
  StringSink visitDirective(Directive spec, [_]) {
    // Always write import/export directives to a separate buffer.
    return super.visitDirective(spec, _writeImports);
  }
}
