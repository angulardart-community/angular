import 'compile_metadata.dart'
    show CompileIdentifierMetadata, CompileTokenMetadata;

const _angularRootUrl = 'package:ngdart/angular.dart';
const _angularLib = 'asset:ngdart/lib';

const _appViewUtilsModuleUrl =
    '$_angularLib/src/core/linker/app_view_utils.dart';
const _proxiesModuleUrl = '$_angularLib/src/runtime/proxies.dart';
const _cdModuleUrl =
    '$_angularLib/src/core/change_detection/change_detection.dart';
const _ngIfUrl = '$_angularLib/src/common/directives/ng_if.dart';
const _ngForUrl = '$_angularLib/src/common/directives/ng_for.dart';
const _profileRuntimeModuleUrl = '$_angularLib/src/debug/profile_runtime.dart';
const _debugInjectorModuleUrl = '$_angularLib/src/di/errors.dart';

/// Identifiers for generating code that supports developer tooling.
class DevTools {
  static const _moduleUrl = '$_angularLib/src/devtools.dart';

  static final inspector = CompileIdentifierMetadata(
    name: 'Inspector.instance',
    moduleUrl: _moduleUrl,
  );

  static final isDevToolsEnabled = CompileIdentifierMetadata(
    name: 'isDevToolsEnabled',
    moduleUrl: _moduleUrl,
  );
}

class JsInterop {
  const JsInterop._();

  static final functionToJSExportedDartFunction = CompileIdentifierMetadata(
    name: 'FunctionToJSExportedDartFunction',
    moduleUrl: 'dart:js_interop',
  );

  static final jsObject = CompileIdentifierMetadata(
    name: 'JSObject',
    moduleUrl: 'dart:_interceptors',
  );

  static final jsObjectToken = CompileTokenMetadata(
    identifier: jsObject,
  );
}

/// A collection of methods for manipulating the DOM from generated code.
class DomHelpers {
  const DomHelpers._();

  static CompileIdentifierMetadata _of(String name) {
    return CompileIdentifierMetadata(
      name: name,
      moduleUrl: '$_angularLib/src/runtime/dom_helpers.dart',
    );
  }

  static final updateClassBinding = _of('updateClassBinding');
  static final updateClassBindingNonHtml = _of('updateClassBindingNonHtml');

  static final updateAttribute = _of('updateAttribute');
  static final updateAttributeNS = _of('updateAttributeNS');
  static final setAttribute = _of('setAttribute');
  static final setProperty = _of('setProperty');

  static final createText = _of('createText');
  static final appendText = _of('appendText');
  static final createAnchor = _of('createAnchor');
  static final appendAnchor = _of('appendAnchor');
  static final appendDiv = _of('appendDiv');
  static final appendSpan = _of('appendSpan');
  static final appendElement = _of('appendElement');
}

class StyleEncapsulation {
  const StyleEncapsulation._();

  static CompileIdentifierMetadata _of(String name) {
    return CompileIdentifierMetadata(
      name: name,
      moduleUrl: '$_angularLib/src/core/linker/style_encapsulation.dart',
    );
  }

  static final componentStyles = _of('ComponentStyles');
  static final componentStylesScoped = _of('ComponentStyles.scoped');
  static final componentStylesUnscoped = _of('ComponentStyles.unscoped');
}

class Views {
  const Views._();

  static CompileIdentifierMetadata _of(String name, String file) {
    return CompileIdentifierMetadata(
      name: name,
      moduleUrl: '$_angularLib/src/core/linker/views/$file',
    );
  }

  static final componentView = _of('ComponentView', 'component_view.dart');
  static final embeddedView = _of('EmbeddedView', 'embedded_view.dart');
  static final hostView = _of('HostView', 'host_view.dart');
  static final renderView = _of('RenderView', 'render_view.dart');
  static final view = _of('View', 'view.dart');
}

class Interpolation {
  static const _moduleUrl = '$_angularLib/src/runtime/interpolate.dart';

  const Interpolation._();

  static CompileIdentifierMetadata _interpolate(int n) {
    return CompileIdentifierMetadata(
      name: 'interpolate$n',
      moduleUrl: _moduleUrl,
    );
  }

  static CompileIdentifierMetadata _interpolateString(int n) {
    return CompileIdentifierMetadata(
      name: 'interpolateString$n',
      moduleUrl: _moduleUrl,
    );
  }

  static final interpolate = List<CompileIdentifierMetadata>.generate(
    3,
    _interpolate,
  );

  static final interpolateFallback = CompileIdentifierMetadata(
    name: 'interpolateN',
    moduleUrl: _moduleUrl,
  );

  static final interpolateString = List<CompileIdentifierMetadata>.generate(
    3,
    _interpolateString,
  );

  static final textBinding = CompileIdentifierMetadata(
    name: 'TextBinding',
    moduleUrl: '$_angularLib/src/runtime/text_binding.dart',
  );
}

class Runtime {
  static const _runtimeUrl = '$_angularLib/src/utilities.dart';
  static const _checkBindingUrl = '$_angularLib/src/runtime/check_binding.dart';

  const Runtime._();

  static final checkBinding = CompileIdentifierMetadata(
    name: 'checkBinding',
    moduleUrl: _checkBindingUrl,
  );

  static final debugThrowIfChanged = CompileIdentifierMetadata(
    name: 'debugThrowIfChanged',
    moduleUrl: _checkBindingUrl,
  );

  static final isDevMode = CompileIdentifierMetadata(
    name: 'isDevMode',
    moduleUrl: _runtimeUrl,
  );

  static final unsafeCast = CompileIdentifierMetadata(
    name: 'unsafeCast',
    moduleUrl: _runtimeUrl,
  );
}

class Queries {
  static const _moduleUrl = '$_angularLib/src/runtime/queries.dart';

  const Queries._();

  static final firstOrNull = CompileIdentifierMetadata(
    name: 'firstOrNull',
    moduleUrl: _moduleUrl,
  );
}

class SafeHtmlAdapters {
  static const _moduleUrl = '$_angularLib/src/security/safe_html_adapter.dart';
  static final sanitizeHtml = CompileIdentifierMetadata(
    name: 'sanitizeHtml',
    moduleUrl: _moduleUrl,
  );
  static final sanitizeStyle = CompileIdentifierMetadata(
    name: 'sanitizeStyle',
    moduleUrl: _moduleUrl,
  );
  static final sanitizeUrl = CompileIdentifierMetadata(
    name: 'sanitizeUrl',
    moduleUrl: _moduleUrl,
  );
  static final sanitizeResourceUrl = CompileIdentifierMetadata(
    name: 'sanitizeResourceUrl',
    moduleUrl: _moduleUrl,
  );
}

class Identifiers {
  static final appViewUtils = CompileIdentifierMetadata(
    name: 'appViewUtils',
    moduleUrl: _appViewUtilsModuleUrl,
  );
  static final viewContainer = CompileIdentifierMetadata(
      name: 'ViewContainer',
      moduleUrl: '$_angularLib/src/core/linker/view_container.dart');
  static final viewContainerToken = identifierToken(viewContainer);
  static final elementRef = CompileIdentifierMetadata(
      name: 'ElementRef',
      moduleUrl: '$_angularLib/src/core/linker/element_ref.dart');
  static final elementRefToken = identifierToken(elementRef);
  static final viewContainerRef = CompileIdentifierMetadata(
      name: 'ViewContainerRef',
      moduleUrl: 'asset:ngdart/lib/src/core/linker/view_container_ref.dart');
  static final viewContainerRefToken =
      identifierToken(Identifiers.viewContainerRef);
  static final componentLoader = CompileIdentifierMetadata(
      name: 'ComponentLoader',
      moduleUrl: 'asset:ngdart/lib/src/core/linker/component_loader.dart');
  static final componentLoaderToken = identifierToken(componentLoader);
  static final changeDetectorRef = CompileIdentifierMetadata(
      name: 'ChangeDetectorRef',
      moduleUrl: 'asset:ngdart/lib/src/core/change_detection/'
          'change_detector_ref.dart');
  static final changeDetectorRefToken =
      identifierToken(Identifiers.changeDetectorRef);
  static final componentFactory = CompileIdentifierMetadata(
      name: 'ComponentFactory', moduleUrl: _angularRootUrl);
  static final directiveChangeDetector = CompileIdentifierMetadata(
      name: 'DirectiveChangeDetector',
      moduleUrl: 'asset:ngdart/lib/src/core/'
          'change_detection/directive_change_detector.dart');
  static final componentRef = CompileIdentifierMetadata(
      name: 'ComponentRef', moduleUrl: _angularRootUrl);
  static final templateRef = CompileIdentifierMetadata(
      name: 'TemplateRef',
      moduleUrl: '$_angularLib/src/core/linker/template_ref.dart');
  static final templateRefToken = identifierToken(Identifiers.templateRef);
  static final injector = CompileIdentifierMetadata(
      name: 'Injector', moduleUrl: '$_angularLib/src/di/injector.dart');
  static final injectorToken = identifierToken(Identifiers.injector);
  static final viewType = CompileIdentifierMetadata(
      name: 'ViewType',
      moduleUrl: '$_angularLib/src/core/linker/view_type.dart');
  static final changeDetectionStrategy = CompileIdentifierMetadata(
      name: 'ChangeDetectionStrategy', moduleUrl: _cdModuleUrl);
  static final changeDetectionCheckedState = CompileIdentifierMetadata(
      name: 'ChangeDetectionCheckedState',
      moduleUrl: '$_angularLib/src/meta/change_detection_constants.dart');
  static final identical = CompileIdentifierMetadata(name: 'identical');
  static final profileSetup = CompileIdentifierMetadata(
      name: 'profileSetup', moduleUrl: _profileRuntimeModuleUrl);
  static final profileMarkStart = CompileIdentifierMetadata(
      name: 'profileMarkStart', moduleUrl: _profileRuntimeModuleUrl);
  static final profileMarkEnd = CompileIdentifierMetadata(
      name: 'profileMarkEnd', moduleUrl: _profileRuntimeModuleUrl);
  static final debugInjectorEnter = CompileIdentifierMetadata(
      name: 'debugInjectorEnter', moduleUrl: _debugInjectorModuleUrl);
  static final debugInjectorLeave = CompileIdentifierMetadata(
      name: 'debugInjectorLeave', moduleUrl: _debugInjectorModuleUrl);
  static final debugInjectorWrap = CompileIdentifierMetadata(
      name: 'debugInjectorWrap', moduleUrl: _debugInjectorModuleUrl);

  static final createTrustedHtml = CompileIdentifierMetadata(
      name: 'createTrustedHtml', moduleUrl: _appViewUtilsModuleUrl);
  static final pureProxies = [
    null,
    CompileIdentifierMetadata(name: 'pureProxy1', moduleUrl: _proxiesModuleUrl),
    CompileIdentifierMetadata(name: 'pureProxy2', moduleUrl: _proxiesModuleUrl),
    CompileIdentifierMetadata(name: 'pureProxy3', moduleUrl: _proxiesModuleUrl),
    CompileIdentifierMetadata(name: 'pureProxy4', moduleUrl: _proxiesModuleUrl),
    CompileIdentifierMetadata(name: 'pureProxy5', moduleUrl: _proxiesModuleUrl),
    CompileIdentifierMetadata(name: 'pureProxy6', moduleUrl: _proxiesModuleUrl),
    CompileIdentifierMetadata(name: 'pureProxy7', moduleUrl: _proxiesModuleUrl),
    CompileIdentifierMetadata(name: 'pureProxy8', moduleUrl: _proxiesModuleUrl),
    CompileIdentifierMetadata(name: 'pureProxy9', moduleUrl: _proxiesModuleUrl),
    CompileIdentifierMetadata(name: 'pureProxy10', moduleUrl: _proxiesModuleUrl)
  ];

  static final ngIfDirective =
      CompileIdentifierMetadata(name: 'NgIf', moduleUrl: _ngIfUrl);
  static final ngForDirective =
      CompileIdentifierMetadata(name: 'NgFor', moduleUrl: _ngForUrl);

  // Runtime is initialized by output interpreter. Compiler executes in VM and
  // can't import `package:web/web.dart` to initialize here.
  static var event = CompileIdentifierMetadata(
      name: 'Event', moduleUrl: 'asset:web/lib/src/dom/dom.dart');
  static var commentNode = CompileIdentifierMetadata(
      name: 'Comment', moduleUrl: 'asset:web/lib/src/dom/dom.dart');
  static var textNode = CompileIdentifierMetadata(
      name: 'Text', moduleUrl: 'asset:web/lib/src/dom/dom.dart');
  static var document = CompileIdentifierMetadata(
      name: 'document', moduleUrl: 'asset:web/lib/src/dom/dom.dart');
  static final documentFragment = CompileIdentifierMetadata(
      name: 'DocumentFragment', moduleUrl: 'asset:web/lib/src/dom/dom.dart');
  static final element = CompileIdentifierMetadata(
      name: 'Element', moduleUrl: 'asset:web/lib/src/dom/dom.dart');
  static final elementToken = identifierToken(element);
  static final htmlElement = CompileIdentifierMetadata(
      name: 'HTMLElement', moduleUrl: 'asset:web/lib/src/dom/html.dart');
  static final htmlElementToken = identifierToken(htmlElement);
  static final svgSvgElement = CompileIdentifierMetadata(
      name: 'SVGSVGElement', moduleUrl: 'asset:web/lib/src/dom/svg.dart');
  static final svgElement = CompileIdentifierMetadata(
      name: 'SVGElement', moduleUrl: 'asset:web/lib/src/dom/svg.dart');
  static final anchorElement = CompileIdentifierMetadata(
      name: 'HTMLAnchorElement', moduleUrl: 'asset:web/lib/src/dom/html.dart');
  static final divElement = CompileIdentifierMetadata(
      name: 'HTMLDivElement', moduleUrl: 'asset:web/lib/src/dom/html.dart');
  static final areaElement = CompileIdentifierMetadata(
      name: 'HTMLAreaElement', moduleUrl: 'asset:web/lib/src/dom/html.dart');
  static final audioElement = CompileIdentifierMetadata(
      name: 'HTMLAudioElement', moduleUrl: 'asset:web/lib/src/dom/html.dart');
  static final buttonElement = CompileIdentifierMetadata(
      name: 'HTMLButtonElement', moduleUrl: 'asset:web/lib/src/dom/html.dart');
  static final canvasElement = CompileIdentifierMetadata(
      name: 'HTMLCanvasElement', moduleUrl: 'asset:web/lib/src/dom/html.dart');
  static final formElement = CompileIdentifierMetadata(
      name: 'HTMLFormElement', moduleUrl: 'asset:web/lib/src/dom/html.dart');
  static final iframeElement = CompileIdentifierMetadata(
      name: 'HTMLIFrameElement', moduleUrl: 'asset:web/lib/src/dom/html.dart');
  static final imageElement = CompileIdentifierMetadata(
      name: 'HTMLImageElement', moduleUrl: 'asset:web/lib/src/dom/html.dart');
  static final inputElement = CompileIdentifierMetadata(
      name: 'HTMLInputElement', moduleUrl: 'asset:web/lib/src/dom/html.dart');
  static final textareaElement = CompileIdentifierMetadata(
      name: 'HTMLTextAreaElement',
      moduleUrl: 'asset:web/lib/src/dom/html.dart');
  static final mediaElement = CompileIdentifierMetadata(
      name: 'HTMLMediaElement', moduleUrl: 'asset:web/lib/src/dom/html.dart');
  static final menuElement = CompileIdentifierMetadata(
      name: 'HTMLMenuElement', moduleUrl: 'asset:web/lib/src/dom/html.dart');
  static final optionElement = CompileIdentifierMetadata(
      name: 'HTMLOptionElement', moduleUrl: 'asset:web/lib/src/dom/html.dart');
  static final oListElement = CompileIdentifierMetadata(
      name: 'HTMLOListElement', moduleUrl: 'asset:web/lib/src/dom/html.dart');
  static final selectElement = CompileIdentifierMetadata(
      name: 'HTMLSelectElement', moduleUrl: 'asset:web/lib/src/dom/html.dart');
  static final tableElement = CompileIdentifierMetadata(
      name: 'HTMLTableElement', moduleUrl: 'asset:web/lib/src/dom/html.dart');
  static final tableRowElement = CompileIdentifierMetadata(
      name: 'HTMLTableRowElement',
      moduleUrl: 'asset:web/lib/src/dom/html.dart');
  static final tableColElement = CompileIdentifierMetadata(
      name: 'HTMLTableColElement',
      moduleUrl: 'asset:web/lib/src/dom/html.dart');
  static final uListElement = CompileIdentifierMetadata(
      name: 'HTMLUListElement', moduleUrl: 'asset:web/lib/src/dom/html.dart');
  static final node = CompileIdentifierMetadata(
      name: 'Node', moduleUrl: 'asset:web/lib/src/dom/dom.dart');

  /// A class used for message internationalization.
  static final intl = CompileIdentifierMetadata(
    name: 'Intl',
    moduleUrl: 'package:intl/intl.dart',
  );

  static final dart2JsNoInline = CompileIdentifierMetadata(
    name: 'noInline',
    moduleUrl: 'package:meta/dart2js.dart',
  );

  static final dartCoreOverride = CompileIdentifierMetadata(
    name: 'override',
  );

  static final dartCoreDeprecated = CompileIdentifierMetadata(
    name: 'Deprecated',
  );

  static final ngContentRef = CompileIdentifierMetadata(
    name: 'NgContentRef',
    moduleUrl: '$_angularLib/src/core/linker/ng_content_ref.dart',
  );
  static final ngContentRefToken = identifierToken(Identifiers.ngContentRef);
}

CompileTokenMetadata identifierToken(CompileIdentifierMetadata? identifier) {
  return CompileTokenMetadata(identifier: identifier);
}
