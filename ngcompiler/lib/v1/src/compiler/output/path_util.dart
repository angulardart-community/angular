import 'dart:math' as math;

/// Matches `asset:<package-name>/<realm>/<path-to-module>`
final _assetUrlRe = RegExp(r'asset:([^\/]+)\/([^\/]+)\/(.+)');
const _pathSep = '/';
final _pathSepRe = RegExp(r'\/');

/// Returns the absolute or relative path to use to load the source for a
/// given an import url such as templateUrl or cssUrls.
String getImportModulePath(String moduleUrlStr, String importedUrlStr) {
  var absolutePathPrefix = 'package:';
  var moduleUrl = _AssetUrl.parse(moduleUrlStr, false)!;
  var importedUrl = _AssetUrl.parse(importedUrlStr, true);
  if (importedUrl == null) {
    return importedUrlStr;
  }
  // Import self.
  if (moduleUrlStr == importedUrlStr) {
    return importedUrl.modulePath.split(_pathSep).last;
  }
  // Try to create a relative path first
  if (moduleUrl.firstLevelDir == importedUrl.firstLevelDir &&
      moduleUrl.packageName == importedUrl.packageName) {
    return _getRelativePath(moduleUrl.modulePath, importedUrl.modulePath);
  } else if (importedUrl.firstLevelDir == 'lib') {
    return '$absolutePathPrefix${importedUrl.packageName}'
        '/${importedUrl.modulePath}';
  }
  throw StateError("Can't import url $importedUrlStr from $moduleUrlStr");
}

class _AssetUrl {
  final String packageName;
  final String firstLevelDir;
  final String modulePath;

  static _AssetUrl? parse(String url, bool allowNonMatching) {
    var match = _assetUrlRe.firstMatch(url);
    if (match != null) {
      return _AssetUrl(match[1]!, match[2]!, match[3]!);
    }
    if (allowNonMatching) return null;
    throw StateError('Url $url is not a valid asset: url');
  }

  _AssetUrl(this.packageName, this.firstLevelDir, this.modulePath);
}

String _getRelativePath(String modulePath, String importedPath) {
  var moduleParts = modulePath.split(_pathSepRe);
  var importedParts = importedPath.split(_pathSepRe);
  var longestPrefix = _getLongestPathSegmentPrefix(moduleParts, importedParts);
  var resultParts = <Object>[];
  var goParentCount = moduleParts.length - 1 - longestPrefix;
  for (var i = 0; i < goParentCount; i++) {
    resultParts.add('..');
  }
  for (var i = longestPrefix; i < importedParts.length; i++) {
    resultParts.add(importedParts[i]);
  }
  return resultParts.join(_pathSep);
}

int _getLongestPathSegmentPrefix(List<String> arr1, List<String> arr2) {
  var prefixSize = 0;
  var minLen = math.min(arr1.length, arr2.length);
  while (prefixSize < minLen && arr1[prefixSize] == arr2[prefixSize]) {
    prefixSize++;
  }
  return prefixSize;
}
