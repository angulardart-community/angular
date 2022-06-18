import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../../ast.dart';

final _listEquals = const ListEquality<dynamic>();

/// A de-sugared form of longer pseudo expression.
class NgMicroAst {
  /// What variable assignments were made.
  final List<LetBindingAst> letBindings;

  /// What properties are bound.
  final List<PropertyAst> properties;

  @literal
  const NgMicroAst({
    required this.letBindings,
    required this.properties,
  });

  @override
  bool operator ==(Object? other) {
    return other is NgMicroAst &&
        _listEquals.equals(letBindings, other.letBindings) &&
        _listEquals.equals(properties, other.properties);
  }

  @override
  int get hashCode {
    return Object.hash(
        _listEquals.hash(letBindings), _listEquals.hash(properties));
  }

  @override
  String toString() => '#$NgMicroAst <$letBindings $properties>';
}
