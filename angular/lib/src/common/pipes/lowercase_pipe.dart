import 'package:ngdart/src/meta.dart';

/// Transforms text to lowercase.
@Pipe('lowercase')
class LowerCasePipe {
  String? transform(String? value) => value?.toLowerCase();

  const LowerCasePipe();
}
