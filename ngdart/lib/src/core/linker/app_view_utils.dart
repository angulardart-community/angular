import 'dart:js_interop';

import 'package:ngdart/src/core/application_tokens.dart' as tokens show appId;
import 'package:ngdart/src/runtime/dom_events.dart' show EventManager;
import 'package:web/web.dart';

/// Application wide view utilities.
late AppViewUtils appViewUtils;

/// Utilities to create unique RenderComponentType instances for AppViews and
/// provide access to root dom renderer.
class AppViewUtils {
  final String appId;
  final EventManager eventManager;

  AppViewUtils(
    @tokens.appId this.appId,
    this.eventManager,
  );
}

/// Creates a document fragment from [trustedHtml].
DocumentFragment createTrustedHtml(String trustedHtml) {
  final template = HTMLTemplateElement();
  template.innerHTML = trustedHtml.toJS;
  return template.content;
}
