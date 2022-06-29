/// Matches HTML attribute values.
///
/// Note that matching the attribute name is left to the caller. This improves
/// the efficiency of matching an attribute against a collection of
/// [AttributeMatcher]s that share a name.
///
/// https://www.w3.org/TR/selectors4/#attribute-selectors
abstract class AttributeMatcher {
  final String name;
  final String? value;

  const AttributeMatcher(this.name, [this.value]);

  bool matches(String? value);
}

/// Matches a value that is exactly [value].
///
/// https://www.w3.org/TR/selectors4/#attribute-representation
class ExactAttributeMatcher extends AttributeMatcher {
  ExactAttributeMatcher(super.name, super.value);

  @override
  bool matches(String? value) => value == this.value;

  @override
  String toString() => '[$name="$value"]';
}

/// Matches a value that is exactly [value] or prefixed by [value]-.
///
/// https://www.w3.org/TR/selectors4/#attribute-representation
class HyphenAttributeMatcher extends AttributeMatcher {
  final String _prefix;

  HyphenAttributeMatcher(super.name, super.value) : _prefix = '$value-';

  @override
  bool matches(String? value) =>
      value == this.value || value!.startsWith(_prefix);

  @override
  String toString() => '[$name|="$value"]';
}

/// Matches a whitespace-delimited list of words containing [value].
///
/// https://www.w3.org/TR/selectors4/#attribute-representation
class ListAttributeMatcher extends AttributeMatcher {
  static final _whitespaceRe = RegExp(r'\s+');

  ListAttributeMatcher(super.name, super.item);

  @override
  bool matches(String? value) =>
      value!.split(_whitespaceRe).contains(this.value);

  @override
  String toString() => '[$name~="$value"]';
}

/// Matches a value that begins with the prefix [value].
///
/// https://www.w3.org/TR/selectors4/#attribute-substrings
class PrefixAttributeMatcher extends AttributeMatcher {
  PrefixAttributeMatcher(super.name, super.prefix);

  @override
  bool matches(String? value) => value!.startsWith(this.value!);

  @override
  String toString() => '[$name^="$value"]';
}

/// Matches any value.
///
/// https://www.w3.org/TR/selectors4/#attribute-representation
class SetAttributeMatcher extends AttributeMatcher {
  SetAttributeMatcher(super.name);

  @override
  bool matches(String? value) => true;

  @override
  String toString() => '[$name]';
}

/// Matches a value that contains the substring [value].
///
/// https://www.w3.org/TR/selectors4/#attribute-substrings
class SubstringAttributeMatcher extends AttributeMatcher {
  SubstringAttributeMatcher(super.name, super.substring);

  @override
  bool matches(String? value) => value!.contains(this.value!);

  @override
  String toString() => '[$name*="$value"]';
}

/// Matches a value that ends with the suffix [value].
///
/// https://www.w3.org/TR/selectors4/#attribute-substrings
class SuffixAttributeMatcher extends AttributeMatcher {
  SuffixAttributeMatcher(super.name, super.suffix);

  @override
  bool matches(String? value) => value!.endsWith(this.value!);

  @override
  String toString() => '[$name\$="$value"]';
}
