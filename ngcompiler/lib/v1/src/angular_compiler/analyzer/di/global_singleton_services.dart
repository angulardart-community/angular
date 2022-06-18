import '../link.dart';

const _globalSingletonServices = [
  TypeLink(
    'ApplicationRef',
    'asset:ngdart/lib/src/core/application_ref.dart',
  ),
  TypeLink(
    'AppViewUtils',
    'asset:ngdart/lib/src/core/linker/app_view_utils.dart',
  ),
  TypeLink(
    'NgZone',
    'asset:ngdart/lib/src/core/zone/ng_zone.dart',
  ),
  TypeLink(
    'Testability',
    'asset:ngdart/lib/src/testability/implementation.dart',
  ),
];

bool isGlobalSingletonService(TypeLink service) =>
    _globalSingletonServices.contains(service);
