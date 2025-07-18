import 'package:analyzer/dart/ast/ast.dart' hide Directive;
import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/visitor.dart';
import 'package:analyzer/src/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:ngcompiler/v1/angular_compiler.dart';
import 'package:ngcompiler/v1/src/compiler/analyzed_class.dart';
import 'package:ngcompiler/v1/src/compiler/compile_metadata.dart';
import 'package:ngcompiler/v1/src/compiler/expression_parser/ast.dart' as ast;
import 'package:ngcompiler/v1/src/compiler/output/convert.dart';
import 'package:ngcompiler/v1/src/compiler/output/output_ast.dart' as o;
import 'package:ngcompiler/v1/src/compiler/template_compiler.dart';
import 'package:ngcompiler/v1/src/compiler/view_compiler/property_binder.dart'
    show isPrimitiveTypeName;
import 'package:ngcompiler/v1/src/source_gen/common/annotation_matcher.dart';
import 'package:ngcompiler/v1/src/source_gen/common/url_resolver.dart';
import 'package:ngcompiler/v2/analyzer.dart';
import 'package:ngcompiler/v2/context.dart';
import 'package:ngdart/src/meta.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';

import 'annotation_information.dart';
import 'compile_metadata.dart';
import 'component_visitor_exceptions.dart';
import 'dart_object_utils.dart';
import 'lifecycle_hooks.dart';
import 'pipe_visitor.dart';

const String _visibilityProperty = 'visibility';

/// Given the target [library], returns relevant metadata.
AngularArtifacts findComponentsAndDirectives(
  LibraryReader library,
  ComponentVisitorExceptionHandler exceptionHandler,
) {
  final visitor = _NormalizedComponentVisitor(library, exceptionHandler);
  library.element.accept(visitor);
  return AngularArtifacts(
    components: visitor.components,
    directives: visitor.directives,
  );
}

/// Collects components and directives within a library.
class _NormalizedComponentVisitor extends RecursiveElementVisitor<void> {
  final List<NormalizedComponentWithViewDirectives> components = [];
  final List<CompileDirectiveMetadata> directives = [];
  final LibraryReader _library;

  final ComponentVisitorExceptionHandler _exceptionHandler;

  _NormalizedComponentVisitor(this._library, this._exceptionHandler);

  _ComponentVisitor _visitor() =>
      _ComponentVisitor(_library, _exceptionHandler);

  /// For each class, finds and extracts [CompileDirectiveMetadata].
  ///
  /// If there is a match, and that match is a component, the metadata is
  /// "normalized": the referenced components, directives, and pipe identifiers
  /// are also loaded and parsed into metadata so they can be referred to in
  /// later steps of the compile.
  ///
  /// **NOTE**: Only a max-depth of 1 is used to resolve references (i.e. this
  /// is not done recursively), so if component `A` uses `B` and component `B`
  /// uses `C`, normalizing `A` will resolve metadata for `B`, but will not
  /// attempt to resolve metadata for `C`.
  @override
  void visitClassElement(ClassElement element) {
    final directive = element.accept(_visitor());
    if (directive != null) {
      if (directive.isComponent) {
        final directives = _visitDirectives(element);
        final directiveTypes = _visitDirectiveTypes(element);
        final pipes = _visitPipes(element);
        _errorOnUnusedDirectiveTypes(
          element,
          directives,
          directiveTypes,
          _exceptionHandler,
        );
        components.add(NormalizedComponentWithViewDirectives(
          component: directive,
          directives: directives,
          directiveTypes: directiveTypes,
          pipes: pipes,
        ));
      } else {
        directives.add(directive);
      }
    }
  }

  List<CompileDirectiveMetadata> _visitDirectives(ClassElement element) {
    final values = _getResolvedArgumentsOrFail(element, 'directives');
    return visitAll(values, (value) {
      return typeDeclarationOf(value)?.accept(_visitor());
    });
  }

  List<CompileTypedMetadata> _visitDirectiveTypes(ClassElement element) {
    final values = _getResolvedArgumentsOrFail(element, 'directiveTypes');
    final typedReader = TypedReader(element);
    final directiveTypes = <CompileTypedMetadata>[];
    for (final value in values) {
      directiveTypes.add(_typeMetadataFrom(typedReader.parse(value)));
    }
    return directiveTypes;
  }

  List<CompilePipeMetadata> _visitPipes(ClassElement element) {
    final values = _getResolvedArgumentsOrFail(element, 'pipes');
    return visitAll(values, (value) {
      return typeDeclarationOf(value)
          ?.accept(PipeVisitor(_library, _exceptionHandler));
    });
  }

  /// Returns the arguments assigned to [field], ensuring they're resolved.
  ///
  /// This will immediately fail compilation and inform the user if any
  /// arguments can't be resolved. Failing here avoids misleading errors that
  /// arise from unresolved arguments later on in compilation.
  ///
  /// This assumes [field] expects a list of arguments.
  List<DartObject> _getResolvedArgumentsOrFail(
    ClassElement element,
    String field,
  ) {
    final annotationInfo =
        annotationWhere(element, safeMatcher(isComponent), _exceptionHandler)!;
    if (annotationInfo.hasErrors) {
      _exceptionHandler.handle(AngularAnalysisError(
          annotationInfo.constantEvaluationErrors, annotationInfo));
      return [];
    }
    final annotation = annotationInfo.annotation;
    final values = coerceList(annotationInfo.constantValue, field);
    if (values.isEmpty) {
      // Two reasons we got to this point:
      // 1. The list argument was empty or omitted.
      // 2. One or more identifiers in the list were not resolved, potentially
      //    due to missing imports or dependencies.
      //
      // The latter is specifically tricky to debug, because it ends up failing
      // template parsing in a similar way to #1, but a user will look at the
      // code and not see a problem potentially.
      final annotationImpl = annotation as ElementAnnotationImpl;
      for (final Expression argument
          in annotationImpl.annotationAst.arguments!.arguments) {
        if (argument is NamedExpression && argument.name.label.name == field) {
          if (argument.expression is! ListLiteral) {
            // Something like
            //   directives: 'Ha Ha!'
            //
            // ... was attempted to be used.
            _exceptionHandler.handle(UnresolvedExpressionError(
              [argument.expression],
              element,
              annotationImpl.compilationUnit,
            ));
            break;
          }
          final values = argument.expression as ListLiteral;
          if (values.elements.isNotEmpty &&
              values.elements.any(_isUnresolvedOrNotAnExpression)) {
            _exceptionHandler.handle(UnresolvedExpressionError(
              values.elements.where(_isUnresolvedOrNotAnExpression),
              element,
              annotationImpl.compilationUnit,
            ));
          }
        }
      }
    }
    return values;
  }

  static bool _isUnresolvedOrNotAnExpression(CollectionElement e) {
    if (e is Expression) {
      return e.staticType?.isDynamic != false;
    } else {
      return true;
    }
  }

  CompileTypedMetadata _typeMetadataFrom(TypedElement typed) {
    final typeLink = typed.typeLink;
    final typeArguments = <o.OutputType>[];
    for (final generic in typeLink.generics) {
      typeArguments.add(fromTypeLink(generic, _library));
    }
    return CompileTypedMetadata(
      typeLink.symbol,
      typeLink.import,
      typeArguments,
      on: typed.on,
    );
  }
}

class _ComponentVisitor
    extends RecursiveElementVisitor<CompileDirectiveMetadata> {
  final _fieldInputs = <String, String>{};
  final _setterInputs = <String, String>{};
  final _inputs = <String, String>{};
  final _inputTypes = <String, CompileTypeMetadata>{};
  final _outputs = <String, String>{};
  final _hostBindings = <String, ast.AST>{};
  final _hostListeners = <String, String>{};
  final _queries = <CompileQueryMetadata>[];
  final _viewQueries = <CompileQueryMetadata>[];

  final LibraryReader _library;
  final ComponentVisitorExceptionHandler _exceptionHandler;

  /// Element of the current directive being visited.
  ///
  /// This is used to look up resolved type information.
  ClassElement? _directiveClassElement;

  _ComponentVisitor(this._library, this._exceptionHandler);

  @override
  CompileDirectiveMetadata? visitClassElement(ClassElement element) {
    AnnotationInformation<ClassElement>? directiveInfo;
    AnnotationInformation<ClassElement>? linkInfo;

    for (var index = 0; index < element.metadata.length; index++) {
      final annotation = element.metadata[index];
      final annotationInfo =
          AnnotationInformation(element, annotation, index, _exceptionHandler);
      final constantValue = annotationInfo.constantValue;
      if (constantValue == null) {
        _exceptionHandler.handleWarning(AngularAnalysisError(
          annotationInfo.constantEvaluationErrors,
          annotationInfo,
        ));
      } else if (safeMatcher(isDirective)(annotation)) {
        directiveInfo = annotationInfo;
      } else if ($ChangeDetectionLink.isExactlyType(constantValue.type!)) {
        linkInfo = annotationInfo;
      }
      if (directiveInfo != null && linkInfo != null) {
        break;
      }
    }

    if (directiveInfo == null) return null;
    if (element.isPrivate) {
      log.severe('Components and directives must be public: $element');
      return null;
    }
    return _createCompileDirectiveMetadata(directiveInfo, linkInfo);
  }

  @override
  CompileDirectiveMetadata? visitFieldElement(FieldElement element) {
    super.visitFieldElement(element);
    _visitClassMember(
      element,
      isGetter: element.getter != null,
      isSetter: element.setter != null,
    );
    return null;
  }

  @override
  CompileDirectiveMetadata? visitPropertyAccessorElement(
    PropertyAccessorElement element,
  ) {
    super.visitPropertyAccessorElement(element);
    _visitClassMember(
      element,
      isGetter: element.isGetter,
      isSetter: element.isSetter,
    );
    return null;
  }

  void _visitClassMember(
    Element element, {
    bool isGetter = false,
    bool isSetter = false,
  }) {
    if (_directiveClassElement == null) {
      return;
    }

    for (var annotationIndex = 0;
        annotationIndex < element.metadata.length;
        annotationIndex++) {
      var annotation = element.metadata[annotationIndex];
      final annotationInfo = AnnotationInformation(
          element, annotation, annotationIndex, _exceptionHandler);
      if (annotationInfo.isInputType) {
        if (isSetter && element.isPublic) {
          // TODO(b/198420237): remove this explicit `bool` type when no longer
          // needed to work around
          // https://github.com/dart-lang/language/issues/1785
          final bool isField = // ignore: omit_local_variable_types
              element is FieldElement;
          if (isField) {
            _refuseLateFinalInputs(element);
          }
          final setter = _setterFor(element);
          if (setter == null) {
            return;
          }
          final propertyType = setter.parameters.first.type;
          final dynamicType = setter.library.typeProvider.dynamicType;
          // Resolves unspecified or bounded generic type parameters.
          final resolvedType = propertyType.resolveToBound(dynamicType);
          final typeName = getTypeName(resolvedType);
          _addPropertyBindingTo(
              isField ? _fieldInputs : _setterInputs, annotation, element,
              immutableBindings: _inputs);
          if (typeName != null) {
            if (isPrimitiveTypeName(typeName)) {
              _inputTypes[element.displayName] =
                  CompileTypeMetadata(name: typeName);
            } else {
              // Convert any generic type parameters from the input's type to
              // our internal output AST.
              var typeArguments = resolvedType.alias?.typeArguments;
              if (typeArguments == null) {
                if (resolvedType is InterfaceType) {
                  typeArguments = resolvedType.typeArguments;
                } else {
                  typeArguments = const <DartType>[];
                }
              }
              _inputTypes[element.displayName] = CompileTypeMetadata(
                moduleUrl: moduleUrl(element),
                name: typeName,
                typeArguments: List.from(typeArguments.map(fromDartType)),
              );
            }
          }
        } else {
          log.severe('@Input can only be used on a public setter or non-final '
              'field, but was found on $element.');
        }
      } else if (annotationInfo.isOutputType) {
        if (isGetter && element.isPublic) {
          _addPropertyBindingTo(_outputs, annotation, element);
        } else {
          log.severe('@Output can only be used on a public getter or field, '
              'but was found on $element.');
        }
      } else if (annotationInfo.isContentType) {
        if (isSetter && element.isPublic) {
          final setter = _setterFor(element);
          if (setter == null) {
            return;
          }
          final queryType = setter.parameters.first.type;
          final contentQuery = _getQuery(
            annotationInfo,
            // Avoid emitting the '=' part of the setter.
            element.displayName,
            queryType,
          );
          if (contentQuery.first) {
            _refuseNonNullableSingleChildQueries(element, queryType);
          }
          if (element is FieldElement) {
            _refuseLateQueries(element);
          }
          _queries.add(contentQuery);
        } else {
          log.severe('@ContentChild or @ContentChildren can only be used on a '
              'public setter or non-final field, but was found on $element.');
        }
      } else if (annotationInfo.isViewType) {
        if (isSetter && element.isPublic) {
          final setter = _setterFor(element);
          if (setter == null) {
            return;
          }
          final queryType = setter.parameters.first.type;
          final viewQuery = _getQuery(
            annotationInfo,
            // Avoid emitting the '=' part of the setter.
            element.displayName,
            queryType,
          );
          if (viewQuery.first) {
            _refuseNonNullableSingleChildQueries(element, queryType);
          }
          if (element is FieldElement) {
            _refuseLateQueries(element);
          }
          _viewQueries.add(viewQuery);
        } else {
          log.severe('@ViewChild or @ViewChildren can only be used on a public '
              'setter or non-final field, but was found on $element.');
        }
      }
    }
  }

  void _refuseLateFinalInputs(FieldElement field) {
    if (field.isLate && field.isFinal) {
      CompileContext.current.reportAndRecover(BuildError.forElement(
        field,
        'Inputs cannot be "late final".\n\n'
        'See go/angular-dart-null-safety-faq#inputs.',
      ));
    }
  }

  void _refuseNonNullableSingleChildQueries(Element member, DartType type) {
    if (type.isExplicitlyNonNullable) {
      CompileContext.current.reportAndRecover(BuildError.forElement(
        member,
        'ViewChild and ContentChild queries must be nullable.\n\n'
        'See go/angular-dart-null-safety-faq#viewchild-contentchild.',
      ));
    }
  }

  void _refuseLateQueries(FieldElement field) {
    if (field.isLate) {
      CompileContext.current.reportAndRecover(BuildError.forElement(
        field,
        'View and content queries cannot be "late".\n\n'
        'See go/angular-dart-null-safety-faq.',
      ));
    }
  }

  /// Attempts to return a valid setter for [element].
  ///
  /// May return null if no setter corresponds to [element], or the [element]
  /// itself is invalid (e.g. a setter without parameters or a body).
  PropertyAccessorElement? _setterFor(Element element) {
    final dclass = _directiveClassElement!;
    // Resolves specified generic type parameters.
    final setter =
        dclass.thisType.lookUpSetter2(element.displayName, dclass.library)!;
    if (setter.parameters.isEmpty) {
      CompileContext.current.reportAndRecover(
        BuildError.forElement(
          element,
          'Invalid setter, please check build log for syntax errors.',
        ),
      );
      return null;
    }
    return setter;
  }

  List<CompileTokenMetadata> _getSelectors(
      AnnotationInformation annotationInfo) {
    var value = annotationInfo.constantValue;
    var selector = getField(value, 'selector');
    if (isNull(selector)) {
      _exceptionHandler.handle(ErrorMessageForAnnotation(annotationInfo,
          'Missing selector argument for "@${value!.type!.name}"'));
      return [];
    }
    var selectorString = selector?.toStringValue();
    if (selectorString != null) {
      return selectorString
          .split(',')
          .map((s) => CompileTokenMetadata(value: s))
          .toList();
    }
    var selectorType = selector!.toTypeValue();
    if (selectorType == null) {
      // NOTE(deboer): This code is untested and probably unreachable.
      _exceptionHandler.handle(ErrorMessageForAnnotation(
          annotationInfo,
          'Only a value of `String` or `Type` for "@${value!.type!.name}" is '
          'supported'));
      return [];
    }
    return [
      CompileTokenMetadata(
        identifier: CompileIdentifierMetadata(
          name: selectorType.name!,
          moduleUrl: moduleUrl(selectorType.element!),
        ),
      ),
    ];
  }

  static final _coreIterable = TypeChecker.fromUrl('dart:core#Iterable');
  static final _htmlElement =
      TypeChecker.fromUrl('package:web/src/dom/dom.dart#Element');

  CompileQueryMetadata _getQuery(
    AnnotationInformation annotationInfo,
    String propertyName,
    DartType? propertyType,
  ) {
    final value = annotationInfo.constantValue;
    final readType = getField(value, 'read')?.toTypeValue();
    CompileTokenMetadata? readMetadata;

    if (readType != null) {
      readMetadata = CompileTokenMetadata(
        identifier: CompileIdentifierMetadata(
          name: readType.name!,
          moduleUrl: moduleUrl(readType.element!),
        ),
      );
    }

    return CompileQueryMetadata(
      selectors: _getSelectors(annotationInfo),
      descendants: coerceBool(value, 'descendants', defaultTo: false),
      first: coerceBool(value, 'first', defaultTo: false),
      propertyName: propertyName,
      isElementType: propertyType!.element != null &&
              _htmlElement.isAssignableFromType(propertyType) ||
          // A bit imprecise, but this will cover 'Iterable' and 'List'.
          _coreIterable.isAssignableFromType(propertyType) &&
              propertyType is ParameterizedType &&
              _htmlElement
                  .isAssignableFromType(propertyType.typeArguments.first),
      read: readMetadata,
    );
  }

  void _addHostBinding(Element element, DartObject value) {
    final property = coerceString(
      value,
      'hostPropertyName',
      defaultTo: element.name,
    )!;
    // Allows using static members for @HostBinding. For example:
    //
    // class Foo {
    //   @HostBinding('title')
    //   static const title = 'Hello';
    // }
    var bindTo = ast.PropertyRead(ast.ImplicitReceiver(), element.name!);
    if (element is PropertyAccessorElement && element.isStatic ||
        element is FieldElement && element.isStatic) {
      if (element.enclosingElement != _directiveClassElement) {
        // We do not want to inherit static members.
        // https://github.com/angulardart/angular/issues/1272
        return;
      }
      var classId = CompileIdentifierMetadata(
          name: _directiveClassElement!.name,
          moduleUrl: moduleUrl(_directiveClassElement!.library),
          analyzedClass: AnalyzedClass(_directiveClassElement!));
      bindTo = ast.PropertyRead(ast.StaticRead(classId), element.name!);
    }
    _hostBindings[property] = bindTo;
  }

  void _addHostListener(MethodElement element, DartObject value) {
    var eventName = coerceString(value, 'eventName')!;
    var methodName = element.name;
    var methodArgs = coerceStringList(value, 'args');
    if (methodArgs.isEmpty && element.parameters.length == 1) {
      // Infer $event.
      methodArgs = const [r'$event'];
    }
    _hostListeners[eventName] = '$methodName(${methodArgs.join(', ')})';
  }

  /// Adds a property binding for [element] to [bindings].
  ///
  /// The property binding maps [element]'s display name to a binding name. By
  /// default, [element]'s name is used as the binding name. However, if
  /// [annotation] has a `bindingPropertyName` field, its value is used instead.
  ///
  /// Property bindings are immutable by default, to prevent derived classes
  /// from overriding inherited binding names. The optional [immutableBindings]
  /// may be provided to restrict a different set of property bindings than
  /// [bindings].
  void _addPropertyBindingTo(
    Map<String, String> bindings,
    ElementAnnotation annotation,
    Element element, {
    Map<String, String>? immutableBindings,
  }) {
    final value = annotation.computeConstantValue();
    final propertyName = element.displayName;
    final bindingName =
        coerceString(value, 'bindingPropertyName', defaultTo: propertyName)!;
    _prohibitBindingChange(element.enclosingElement as InterfaceElement?,
        propertyName, bindingName, immutableBindings ?? bindings);
    bindings[propertyName] = bindingName;
  }

  /// Collects inheritable metadata declared on [element].
  void _collectInheritableMetadataOn(InterfaceElement element) {
    // Skip 'Object' since it can't have metadata and we only want to record
    // whether a user type implements 'noSuchMethod'.
    if (element is ClassElement && element.isDartCoreObject) return;

    // Collect metadata from field and property accessor annotations.
    element.visitChildren(this);

    // Merge field and setter inputs, so that a derived field input binding is
    // not overridden by an inherited setter input.
    _inputs
      ..addAll(_fieldInputs)
      ..addAll(_setterInputs);
    _fieldInputs.clear();
    _setterInputs.clear();
  }

  /// Collects inheritable metadata from [element] and its supertypes.
  void _collectInheritableMetadata(ClassElement element) {
    // Reverse supertypes to traverse inheritance hierarchy from top to bottom
    // so that derived bindings overwrite their inherited definition.
    for (var type in element.allSupertypes.reversed) {
      _collectInheritableMetadataOn(type.element);
    }
    _collectInheritableMetadataOn(element);
  }

  CompileDirectiveMetadata? _createCompileDirectiveMetadata(
    AnnotationInformation<ClassElement> directiveInfo,
    AnnotationInformation<ClassElement>? linkInfo,
  ) {
    final element = directiveInfo.element;

    _directiveClassElement = element;
    DirectiveVisitor(
      onHostBinding: _addHostBinding,
      onHostListener: _addHostListener,
    ).visitDirective(element);
    _collectInheritableMetadata(element);
    final isComponent = directiveInfo.isComponent;
    final annotationValue = directiveInfo.constantValue;

    if (directiveInfo.hasErrors) {
      _exceptionHandler.handle(AngularAnalysisError(
          directiveInfo.constantEvaluationErrors, directiveInfo));
      return null;
    }

    // Some directives won't have templates but the template parser is going to
    // assume they have at least defaults.
    var componentType = element.accept(
      CompileTypeMetadataVisitor(_library, directiveInfo, _exceptionHandler),
    )!;

    final template = isComponent
        ? _createTemplateMetadata(directiveInfo, componentType)
        : CompileTemplateMetadata();

    // _createTemplateMetadata failed to create the metadata.
    if (template == null) return null;

    final analyzedClass = AnalyzedClass(element);
    final lifecycleHooks = extractLifecycleHooks(element);
    _validateLifecycleHooks(lifecycleHooks, element, isComponent);

    final selector = coerceString(annotationValue, 'selector');
    if (selector == null || selector.isEmpty) {
      _exceptionHandler.handle(ErrorMessageForAnnotation(
        directiveInfo,
        'Selector is required, got "$selector"',
      ));
    }

    var changeDetection = _changeDetection(element, annotationValue);

    // TODO(b/198420237): remove this explicit `bool` type when no longer needed
    // to work around https://github.com/dart-lang/language/issues/1785
    final bool isChangeDetectionLink = // ignore: omit_local_variable_types
        linkInfo != null;
    if (isChangeDetectionLink &&
        !(isComponent && changeDetection == ChangeDetectionStrategy.onPush)) {
      _exceptionHandler.handle(ErrorMessageForAnnotation(
          linkInfo,
          'Only supported on components that use '
          '"ChangeDetectionStrategy.onPush" change detection'));
    }

    return CompileDirectiveMetadata(
      type: componentType,
      originType: componentType,
      metadataType: isComponent
          ? CompileDirectiveMetadataType.component
          : CompileDirectiveMetadataType.directive,
      selector: coerceString(annotationValue, 'selector'),
      exportAs: coerceString(annotationValue, 'exportAs'),
      changeDetection: changeDetection,
      inputs: _inputs,
      inputTypes: _inputTypes,
      outputs: _outputs,
      hostBindings: _hostBindings,
      hostListeners: _hostListeners,
      analyzedClass: analyzedClass,
      lifecycleHooks: lifecycleHooks,
      providers: _extractProviders(directiveInfo, 'providers'),
      viewProviders: _extractProviders(directiveInfo, 'viewProviders'),
      exports: _extractExports(directiveInfo),
      queries: _queries,
      viewQueries: _viewQueries,
      template: template,
      visibility: coerceEnum(
        annotationValue,
        _visibilityProperty,
        Visibility.values,
        defaultTo: Visibility.local,
      ),
      isChangeDetectionLink: isChangeDetectionLink,
    );
  }

  void _validateLifecycleHooks(
      List<LifecycleHooks> lifecycleHooks, ClassElement element, bool isComp) {
    if (lifecycleHooks.contains(LifecycleHooks.doCheck)) {
      final ngDoCheck = element.getMethod('ngDoCheck') ??
          element.lookUpInheritedMethod('ngDoCheck', element.library);
      if (ngDoCheck != null && ngDoCheck.isAsynchronous) {
        CompileContext.current.reportAndRecover(
          BuildError.forElement(
            ngDoCheck,
            'ngDoCheck should not be "async". The "ngDoCheck" lifecycle event '
            'must be strictly synchronous, and should not invoke any methods '
            '(or getters/setters) that directly run asynchronous code (such as '
            'microtasks, timers).',
          ),
        );
      }
    }
  }

  CompileTemplateMetadata? _createTemplateMetadata(
    AnnotationInformation annotationInfo,
    CompileTypeMetadata? componentType,
  ) {
    final component = annotationInfo.constantValue;
    var template = component;
    var templateContent = coerceString(template, 'template');
    var templateUrl = coerceString(template, 'templateUrl');
    if (templateContent != null && templateUrl != null) {
      _exceptionHandler.handle(ErrorMessageForAnnotation(annotationInfo,
          'Cannot supply both "template" and "templateUrl" for an @Component'));
      return null;
    }
    // Verify that templateUrl can be parsed.
    if (templateUrl != null) {
      try {
        Uri.parse(templateUrl);
      } on FormatException catch (formatException) {
        _exceptionHandler.handle(ErrorMessageForAnnotation(
            annotationInfo,
            '@Component.templateUrl is not a valid URI. '
            'Parsing produced an error: ${formatException.message}'));
        return null;
      }
    }
    final styleUrls = coerceStringList(template, 'styleUrls');
    for (final styleUrl in styleUrls) {
      if (!p.extension(styleUrl).endsWith('.css')) {
        _exceptionHandler.handle(
          ErrorMessageForAnnotation(
            annotationInfo,
            'Unsupported extension in styleUrls: "$styleUrl". Only ".css" is supported',
          ),
        );
      }
    }
    return CompileTemplateMetadata(
      encapsulation: _encapsulation(template),
      template: templateContent,
      templateUrl: templateUrl,
      templateOffset: _templateOffsetForAnnotation(annotationInfo),
      styles: coerceStringList(template, 'styles'),
      styleUrls: coerceStringList(template, 'styleUrls'),
      preserveWhitespace: coerceBool(
        component,
        'preserveWhitespace',
        defaultTo: false,
      ),
    );
  }

  int _templateOffsetForAnnotation(AnnotationInformation annotationInfo) {
    var templateExpression =
        (annotationInfo.annotation as ElementAnnotationImpl)
            .annotationAst
            .arguments
            ?.arguments
            .firstWhereOrNull((Expression argument) =>
                argument is NamedExpression &&
                argument.name.label.name == 'template') as NamedExpression?;
    if (templateExpression != null) {
      if (templateExpression.expression is SingleStringLiteral) {
        return (templateExpression.expression as SingleStringLiteral)
            .contentsOffset;
      }
      if (templateExpression.expression is AdjacentStrings) {
        var offset = (templateExpression.expression as AdjacentStrings).offset;
        return offset;
      }
    }
    return 0;
  }

  ViewEncapsulation _encapsulation(DartObject? value) => coerceEnum(
        value,
        'encapsulation',
        ViewEncapsulation.values,
        defaultTo: ViewEncapsulation.emulated,
      );

  ChangeDetectionStrategy _changeDetection(
      ClassElement clazz, DartObject? value) {
    return coerceEnum(
      value,
      'changeDetection',
      ChangeDetectionStrategy.values,
      defaultTo: ChangeDetectionStrategy.checkAlways,
    );
  }

  List<CompileProviderMetadata> _extractProviders(
    AnnotationInformation annotationInfo,
    String providerField,
  ) =>
      visitAll(
        const ModuleReader().extractProviderObjects(
          getField(annotationInfo.constantValue, providerField),
        ),
        CompileTypeMetadataVisitor(
          _library,
          annotationInfo,
          _exceptionHandler,
        ).createProviderMetadata,
      );

  List<CompileIdentifierMetadata> _extractExports(
    AnnotationInformation<ClassElement> annotationInfo,
  ) {
    final annotation = annotationInfo.annotation as ElementAnnotationImpl;
    final element = annotationInfo.element;
    var exports = <CompileIdentifierMetadata>[];

    // There is an implicit "export" for the directive class itself
    exports.add(CompileIdentifierMetadata(
        name: element.name,
        moduleUrl: moduleUrl(element.library),
        analyzedClass: AnalyzedClass(element)));

    var arguments = annotation.annotationAst.arguments!.arguments;
    var exportsArg = arguments
        .whereType<NamedExpression>()
        .firstWhereOrNull((arg) => arg.name.label.name == 'exports');
    if (exportsArg == null || exportsArg.expression is! ListLiteral) {
      return exports;
    }

    var staticNames = (exportsArg.expression as ListLiteral).elements;
    for (var staticName in staticNames) {
      if (staticName is! Identifier) {
        _exceptionHandler.handle(ErrorMessageForAnnotation(annotationInfo,
            'Item $staticName in the "exports" field must be an identifier'));
        return exports;
      }
    }

    final unresolvedExports = <Identifier>[];
    for (var staticName in staticNames) {
      var id = staticName as Identifier;
      String name;
      String? prefix;
      AnalyzedClass? analyzedClass;
      if (id is PrefixedIdentifier) {
        // We only allow prefixed identifiers to have library prefixes.
        if (id.prefix.staticElement is! PrefixElement) {
          _exceptionHandler.handle(ErrorMessageForAnnotation(
              annotationInfo,
              'Item $id in the "exports" field must be either a simple '
              'identifier or an identifier with a library prefix'));
          return exports;
        }
        name = id.identifier.name;
        prefix = id.prefix.name;
      } else {
        name = id.name;
      }

      final staticElement = id.staticElement;
      if (staticElement is ClassElement) {
        analyzedClass = AnalyzedClass(staticElement);
      } else if (staticElement == null) {
        unresolvedExports.add(id);
        continue;
      }

      // TODO(het): Also store the `DartType` since we know it statically.
      exports.add(CompileIdentifierMetadata(
        name: name,
        prefix: prefix,
        moduleUrl: moduleUrl(staticElement!.library!),
        analyzedClass: analyzedClass,
      ));
    }
    if (unresolvedExports.isNotEmpty) {
      _exceptionHandler.handle(UnresolvedExpressionError(unresolvedExports,
          _directiveClassElement!, annotation.compilationUnit));
    }
    return exports;
  }
}

/// Ensures that all entries in [directiveTypes] match an entry in [directives].
void _errorOnUnusedDirectiveTypes(
    ClassElement element,
    List<CompileDirectiveMetadata?> directives,
    List<CompileTypedMetadata> directiveTypes,
    ComponentVisitorExceptionHandler exceptionHandler) {
  if (directiveTypes.isEmpty) return;

  // Creates a unique key given a module URL and symbol name.
  String key(String? moduleUrl, String name) => '$moduleUrl#$name';

  // The set of directives declared for use.
  var used = directives.map((d) => key(d!.type.moduleUrl, d.type.name)).toSet();

  // Throw if the user attempts to type any directives that aren't used.
  for (var directiveType in directiveTypes) {
    var typed = key(directiveType.moduleUrl, directiveType.name);
    if (!used.contains(typed)) {
      exceptionHandler.handle(UnusedDirectiveTypeError(element, directiveType));
    }
  }
}

void _prohibitBindingChange(
  InterfaceElement? element,
  String propertyName,
  String? bindingName,
  Map<String, String?> bindings,
) {
  if (bindings.containsKey(propertyName) &&
      bindings[propertyName] != bindingName) {
    log.severe(
        "'${element!.displayName}' overwrites the binding name of property "
        "'$propertyName' from '${bindings[propertyName]}' to '$bindingName'.");
  }
}
