import 'package:collection/collection.dart';
import 'package:ngcompiler/v1/cli.dart';
import 'package:ngcompiler/v1/src/compiler/template_ast.dart';
import 'package:ngcompiler/v2/context.dart';
import 'package:ngdart/src/meta.dart';

import 'analyzed_class.dart';
import 'expression_parser/ast.dart' as ast;
import 'output/output_ast.dart' as o;
import 'selector.dart' show CssSelector;

final _listsEqual = const ListEquality<Object?>().equals;

abstract class CompileMetadataWithIdentifier {
  CompileIdentifierMetadata? get identifier;
}

abstract class CompileMetadataWithType extends CompileMetadataWithIdentifier {
  CompileTypeMetadata get type;
}

class CompileIdentifierMetadata implements CompileMetadataWithIdentifier {
  final bool emitPrefix;
  final List<o.OutputType> typeArguments;
  final String? prefix;

  final String name;
  final String? moduleUrl;
  final Object? value;

  /// If this identifier refers to a class declaration, this is non-null.
  final AnalyzedClass? analyzedClass;

  CompileIdentifierMetadata({
    required this.name,
    this.moduleUrl,
    this.prefix,
    this.emitPrefix = false,
    this.typeArguments = const [],
    this.value,
    this.analyzedClass,
  });

  @override
  CompileIdentifierMetadata get identifier => this;
}

class CompileDiDependencyMetadata {
  final bool isAttribute;
  final bool isSelf;
  final bool isHost;
  final bool isSkipSelf;
  final bool isOptional;
  final bool isValue;
  final CompileTokenMetadata? token;
  final Object? value;

  CompileDiDependencyMetadata({
    this.isAttribute = false,
    this.isSelf = false,
    this.isHost = false,
    this.isSkipSelf = false,
    this.isOptional = false,
    this.isValue = false,
    this.token,
    this.value,
  });
}

class CompileProviderMetadata {
  final CompileTokenMetadata? token;
  final CompileTypeMetadata? useClass;
  final Object? useValue;
  final CompileTokenMetadata? useExisting;
  final CompileFactoryMetadata? useFactory;
  final List<CompileDiDependencyMetadata?>? deps;

  final bool multi;

  // Ideally refactor to avoid two fields for multi-providers.
  final CompileTypeMetadata? typeArgument;

  /// Restricts where the provider is injectable.
  final Visibility visibility;

  CompileProviderMetadata({
    this.token,
    this.useClass,
    this.useValue,
    this.useExisting,
    this.useFactory,
    this.deps,
    this.visibility = Visibility.all,
    this.multi = false,
    this.typeArgument,
  });

  @override
  // ignore: hash_and_equals
  bool operator ==(other) {
    return other is CompileProviderMetadata &&
        token == other.token &&
        useClass == other.useClass &&
        useValue == other.useValue &&
        useExisting == other.useExisting &&
        useFactory == other.useFactory &&
        _listsEqual(deps, other.deps) &&
        multi == other.multi;
  }

  @override
  String toString() => '{\n'
      'token:$token,\n'
      'useClass:$useClass,\n'
      'useValue:$useValue,\n'
      'useExisting:$useExisting,\n'
      'useFactory:$useFactory,\n'
      'deps:$deps,\n'
      'multi:$multi,\n'
      '}';
}

class CompileFactoryMetadata implements CompileIdentifierMetadata {
  @override
  final String name;

  @override
  final String? prefix;

  @override
  final bool emitPrefix;

  @override
  final String? moduleUrl;

  @override
  List<o.OutputType> get typeArguments => const [];

  final List<CompileDiDependencyMetadata> diDeps;

  CompileFactoryMetadata({
    required this.name,
    this.moduleUrl,
    this.prefix,
    this.emitPrefix = false,
    this.diDeps = const [],
  });

  @override
  CompileIdentifierMetadata get identifier => this;

  @override
  AnalyzedClass? get analyzedClass => null;

  @override
  Object get value => throw UnsupportedError('Functions do not exist here');
}

class CompileTokenMetadata implements CompileMetadataWithIdentifier {
  final Object? value;

  @override
  final CompileIdentifierMetadata? identifier;

  final bool identifierIsInstance;

  CompileTokenMetadata({
    this.value,
    this.identifier,
    this.identifierIsInstance = false,
  });

  // Used to determine unique-ness of CompileTokenMetadata.
  //
  // Because this code originated from the shared TypeScript source, a unique
  // String is emitted and compared, and not something more Dart-y like
  // equality. Should be refactored.
  dynamic get assetCacheKey {
    var identifier = this.identifier;
    if (identifier != null) {
      return identifier.moduleUrl != null
          ? ''
              '${identifier.name}|'
              '${identifier.moduleUrl}|'
              '$identifierIsInstance|'
              '$value|'
              '${identifier.typeArguments.map(_typeAssetKey).join(',')}'
          : null;
    } else {
      return value;
    }
  }

  static String _typeAssetKey(o.OutputType? t) {
    if (t is o.ExternalType) {
      final generics = t.value.typeArguments.isNotEmpty
          ? t.value.typeArguments.map(_typeAssetKey).join(',')
          : '[]';
      return 'ExternalType {${t.value.moduleUrl}:${t.value.name}:$generics}';
    }
    return '{notExternalType}';
  }

  bool equalsTo(CompileTokenMetadata token2) {
    var ak = assetCacheKey;
    return ak != null && ak == token2.assetCacheKey;
  }

  String? get name {
    return value != null ? _sanitizeIdentifier(value!) : identifier?.name;
  }

  static String _sanitizeIdentifier(Object name) =>
      name.toString().replaceAll(RegExp(r'\W'), '_');

  @override
  // ignore: hash_and_equals
  bool operator ==(other) {
    if (other is CompileTokenMetadata) {
      return value == other.value &&
          identifier == other.identifier &&
          identifierIsInstance == other.identifierIsInstance;
    }
    return false;
  }

  @override
  String toString() => '{\n'
      'value:$value,\n'
      'identifier:$identifier,\n'
      'identifierIsInstance:$identifierIsInstance,\n'
      '}';
}

class CompileTokenMap<V> {
  final _valueMap = <dynamic, V>{};

  void add(CompileTokenMetadata token, V value) {
    var existing = get(token);
    if (existing != null) {
      final identifier = token.identifier;
      String name;
      if (identifier?.moduleUrl != null && identifier?.name != null) {
        name = '${identifier!.moduleUrl}::${identifier.name}';
      } else {
        name = '${token.name}';
      }
      throw BuildError.withoutContext(
        'Failed to register provider for token "$name": It already was '
        'provided, potentially automatically by the framework. This error is '
        'usually a sign you are trying to provide a token that is not valid '
        'to provide at the component level, such as "Element"; these tokens '
        'are meant to *only* be provided automatically by the framework and '
        'not manually by end-users.\n\n'
        'Please file a bug (${messages.urlFileBugs}) if you think this message '
        'is wrong or misleading.',
      );
    }
    var ak = token.assetCacheKey;
    if (ak != null) {
      _valueMap[ak] = value;
    }
  }

  V? get(CompileTokenMetadata token) {
    var ak = token.assetCacheKey;
    return ak != null ? _valueMap[ak] : null;
  }

  bool containsKey(CompileTokenMetadata token) => get(token) != null;

  List<V> get values => _valueMap.values.toList();

  int get length => _valueMap.length;
}

/// Metadata regarding compilation of a type.
class CompileTypeMetadata
    implements CompileIdentifierMetadata, CompileMetadataWithType {
  @override
  String name;

  @override
  String? prefix;

  @override
  final bool emitPrefix = false;

  @override
  String? moduleUrl;

  bool isHost;

  @override
  Type? value;

  List<CompileDiDependencyMetadata> diDeps;

  @override
  final List<o.OutputType> typeArguments;

  /// The type parameters on this type's definition.
  ///
  /// Note the distinction from [typeArguments], which represent the *type
  /// arguments* of an instantiated type.
  final List<o.TypeParameter> typeParameters;

  CompileTypeMetadata({
    required this.name,
    this.moduleUrl,
    this.prefix,
    this.isHost = false,
    this.value,
    this.typeArguments = const [],
    this.typeParameters = const [],
    this.diDeps = const [],
  });

  @override
  CompileIdentifierMetadata get identifier => this;

  @override
  CompileTypeMetadata get type => this;

  @override
  AnalyzedClass? get analyzedClass => null;

  @override
  // ignore: hash_and_equals
  bool operator ==(other) {
    return other is CompileTypeMetadata &&
        name == other.name &&
        prefix == other.prefix &&
        emitPrefix == other.emitPrefix &&
        moduleUrl == other.moduleUrl &&
        isHost == other.isHost &&
        value == other.value &&
        _listsEqual(diDeps, other.diDeps);
  }

  @override
  String toString() => '{\n'
      'name:$name,\n'
      'prefix:$prefix,\n'
      'emitPrefix:$emitPrefix,\n'
      'moduleUrl:$moduleUrl,\n'
      'isHost:$isHost,\n'
      'value:$value,\n'
      'diDeps:$diDeps,\n'
      'typeArguments:$typeArguments\n'
      '}';
}

/// Metadata used to type a generic directive.
class CompileTypedMetadata {
  /// The module URL of the directive this types.
  final String? moduleUrl;

  /// The name of the directive this types.
  final String name;

  /// An optional identifier for matching specific instances of the directive.
  final String? on;

  /// The generic type arguments to be used to instantiate the directive.
  final List<o.OutputType> typeArguments;

  CompileTypedMetadata(
    this.name,
    this.moduleUrl,
    this.typeArguments, {
    this.on,
  });
}

/// Provides metadata for Query, ViewQuery, ViewChildren,
/// ContentChild and ContentChildren decorators.
class CompileQueryMetadata {
  /// List of types or tokens to match.
  final List<CompileTokenMetadata>? selectors;

  /// Whether nested elements should be queried.
  final bool descendants;

  /// Set when querying for first instance that matches selectors.
  final bool first;

  /// Name of class member on the component to update with query result.
  final String? propertyName;

  /// Whether this is typed `package:web/web.dart`'s `Element` (or a sub-type).
  final bool isElementType;

  /// Optional type to read for given match.
  ///
  /// When we match an element in the template, it typically returns the
  /// component. Using read: parameter we can specifically query for
  /// ViewContainer or TemplateRef for the node.
  final CompileTokenMetadata? read;

  const CompileQueryMetadata({
    this.selectors,
    this.descendants = false,
    this.first = false,
    this.propertyName,
    this.isElementType = false,
    this.read,
  });
}

/// Metadata regarding compilation of a template.
class CompileTemplateMetadata {
  final ViewEncapsulation? encapsulation;
  final String? template;
  final String? templateUrl;
  final int templateOffset;
  final bool? preserveWhitespace;
  final List<String> styles;
  final List<String> styleUrls;
  final List<String> ngContentSelectors;
  CompileTemplateMetadata(
      {this.encapsulation = ViewEncapsulation.emulated,
      this.template,
      this.templateUrl,
      this.templateOffset = 0,
      this.preserveWhitespace = false,
      this.styles = const [],
      this.styleUrls = const [],
      this.ngContentSelectors = const []});
}

enum CompileDirectiveMetadataType {
  /// Metadata type for a class annotated with `@Component`.
  component(ProviderAstType.component),

  /// Metadata type for a class annotated with `@Directive`.
  directive(ProviderAstType.directive);

  final ProviderAstType providerAstType;
  const CompileDirectiveMetadataType(this.providerAstType);
}

/// Metadata regarding compilation of a directive.
class CompileDirectiveMetadata implements CompileMetadataWithType {
  @override
  final CompileTypeMetadata type;

  /// User-land class where the component annotation originated.
  final CompileTypeMetadata? originType;

  final CompileDirectiveMetadataType metadataType;
  final String? selector;
  final String? exportAs;
  final ChangeDetectionStrategy? changeDetection;
  final Map<String, String> inputs;
  final Map<String, CompileTypeMetadata> inputTypes;
  final Map<String, String> outputs;
  final Map<String, ast.AST> hostBindings;
  final Map<String, String> hostListeners;
  final List<LifecycleHooks> lifecycleHooks;
  final List<CompileProviderMetadata> providers;
  final List<CompileProviderMetadata> viewProviders;
  final List<CompileIdentifierMetadata> exports;
  final List<CompileQueryMetadata> queries;
  final List<CompileQueryMetadata> viewQueries;
  final CompileTemplateMetadata? template;
  final AnalyzedClass? analyzedClass;

  /// Restricts where the directive is injectable.
  final Visibility visibility;

  /// Whether this is an `OnPush` component that also works in a `Default` app.
  final bool isChangeDetectionLink;

  CompileDirectiveMetadata({
    required this.type,
    this.originType,
    required this.metadataType,
    this.selector,
    this.exportAs,
    this.changeDetection,
    this.inputs = const {},
    this.inputTypes = const {},
    this.outputs = const {},
    this.hostBindings = const {},
    this.hostListeners = const {},
    this.analyzedClass,
    this.template,
    this.visibility = Visibility.all,
    this.lifecycleHooks = const [],
    this.providers = const [],
    this.viewProviders = const [],
    this.exports = const [],
    this.queries = const [],
    this.viewQueries = const [],
    this.isChangeDetectionLink = false,
  });

  CompileDirectiveMetadata.from(CompileDirectiveMetadata other,
      {AnalyzedClass? analyzedClass, CompileTemplateMetadata? template})
      : type = other.type,
        originType = other.originType,
        metadataType = other.metadataType,
        selector = other.selector,
        exportAs = other.exportAs,
        changeDetection = other.changeDetection,
        inputs = other.inputs,
        inputTypes = other.inputTypes,
        outputs = other.outputs,
        hostBindings = other.hostBindings,
        hostListeners = other.hostListeners,
        analyzedClass = analyzedClass ?? other.analyzedClass,
        template = template ?? other.template,
        visibility = other.visibility,
        lifecycleHooks = other.lifecycleHooks,
        providers = other.providers,
        viewProviders = other.viewProviders,
        exports = other.exports,
        queries = other.queries,
        viewQueries = other.viewQueries,
        isChangeDetectionLink = other.isChangeDetectionLink;

  @override
  CompileIdentifierMetadata? get identifier => type;

  String toPrettyString() {
    var name = type.name;
    if (name.endsWith('Host')) {
      name = name.substring(0, name.length - 4);
    }
    return '$name in ${type.moduleUrl} '
        '(changeDetection: ${changeDetection!.name})';
  }

  bool get isComponent =>
      metadataType == CompileDirectiveMetadataType.component;

  bool get isOnPush => changeDetection == ChangeDetectionStrategy.onPush;

  /// Whether the directive requires a change detector class to be generated.
  ///
  /// [DirectiveChangeDetector] classes should only be generated if they
  /// reduce the amount of duplicate code. Therefore we check for the presence
  /// of host bindings to move from each call site to a single method.
  bool get requiresDirectiveChangeDetector =>
      metadataType == CompileDirectiveMetadataType.directive &&
      hostProperties.isNotEmpty;

  Map<String, ast.AST>? _cachedHostAttributes;
  Map<String, ast.AST>? _cachedHostProperties;

  /// The subset of `hostBindings` that are immutable bindings.
  ///
  /// It's useful to separate these out because we can set them at
  /// build time and avoid change detecting them.
  Map<String, ast.AST> get hostAttributes {
    if (_cachedHostAttributes == null) {
      _computeHostBindingImmutability();
    }
    return _cachedHostAttributes!;
  }

  Map<String, ast.AST> get hostProperties {
    if (_cachedHostProperties == null) {
      _computeHostBindingImmutability();
    }
    return _cachedHostProperties!;
  }

  void _computeHostBindingImmutability() {
    assert(_cachedHostAttributes == null);
    assert(_cachedHostProperties == null);
    _cachedHostAttributes = <String, ast.AST>{};
    _cachedHostProperties = <String, ast.AST>{};

    // Host bindings are either literal strings or a property access. We have
    // to filter out non-static property accesses because the directive instance
    // is not available at build time.
    bool isStatic(ast.AST value) {
      if (value is ast.LiteralPrimitive) return true;
      if (value is ast.PropertyRead) {
        return value.receiver is ast.StaticRead;
      }
      // Unrecognized binding type, just assume it's not static.
      return false;
    }

    hostBindings.forEach((name, value) {
      // TODO(het): We should also inline style and class bindings
      var isStyleOrClassBinding =
          name.startsWith('style.') || name.startsWith('class.');
      if (isImmutable(value, analyzedClass) &&
          isStatic(value) &&
          !isStyleOrClassBinding) {
        if (name.startsWith('attr.')) {
          name = name.substring('attr.'.length);
        }
        _cachedHostAttributes![name] = value;
      } else {
        _cachedHostProperties![name] = value;
      }
    });
  }
}

/// Construct [CompileDirectiveMetadata] from [ComponentTypeMetadata] and a
/// selector.
CompileDirectiveMetadata createHostComponentMeta(
    CompileTypeMetadata componentType,
    String componentSelector,
    AnalyzedClass? analyzedClass,
    bool? preserveWhitespace) {
  var template =
      CssSelector.parse(componentSelector)[0].getMatchingElementTemplate();
  return CompileDirectiveMetadata(
    originType: componentType,
    type: CompileTypeMetadata(
        name: '${componentType.name}Host',
        moduleUrl: componentType.moduleUrl,
        isHost: true),
    template: CompileTemplateMetadata(
        template: template,
        templateUrl: '${componentType.moduleUrl}/host/$componentSelector',
        preserveWhitespace: preserveWhitespace,
        styles: const [],
        styleUrls: const [],
        ngContentSelectors: const []),
    changeDetection: ChangeDetectionStrategy.checkAlways,
    analyzedClass: analyzedClass,
    inputs: const {},
    inputTypes: const {},
    outputs: const {},
    hostBindings: const {},
    hostListeners: const {},
    metadataType: CompileDirectiveMetadataType.component,
    selector: '*',
  );
}

/// Creates metadata necessary to flow types from a host view to its component.
List<CompileTypedMetadata> createHostDirectiveTypes(
    CompileTypeMetadata componentType) {
  // If the component doesn't have any generic type parameters, there's no need
  // to specify generic type arguments.
  if (componentType.typeParameters.isEmpty) {
    return [];
  }
  // Otherwise, the returned metadata flows each type parameter of the host view
  // as a type argument to the component (and its associated views).
  return [
    CompileTypedMetadata(
      componentType.name,
      componentType.moduleUrl,
      componentType.typeParameters.map((t) => t.toType()).toList(),
    )
  ];
}

class CompilePipeMetadata implements CompileMetadataWithType {
  @override
  final CompileTypeMetadata type;
  final o.FunctionType? transformType;
  final String? name;
  final bool? pure;
  final List<LifecycleHooks> lifecycleHooks;

  CompilePipeMetadata({
    required this.type,
    this.transformType,
    this.name,
    this.pure = true,
    this.lifecycleHooks = const [],
  });

  @override
  CompileIdentifierMetadata? get identifier => type;
}

/// Lifecycle hooks are guaranteed to be called in the following order:
/// - `afterChanges` (if any bindings have been changed by the Angular framework),
/// - `onInit` (after the first check only),
/// - `doCheck`,
/// - `afterContentInit`,
/// - `afterContentChecked`,
/// - `afterViewInit`,
/// - `afterViewChecked`,
/// - `onDestroy` (at the very end before destruction)
enum LifecycleHooks {
  onInit,
  onDestroy,
  doCheck,
  afterChanges,
  afterContentInit,
  afterContentChecked,
  afterViewInit,
  afterViewChecked
}
