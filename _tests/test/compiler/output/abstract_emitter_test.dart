// @dart=2.9

import 'package:test/test.dart';
import 'package:ngcompiler/v1/src/compiler/output/abstract_emitter.dart'
    show escapeSingleQuoteString;

void main() {
  group('AbstractEmitter', () {
    group('escapeSingleQuoteString', () {
      test('should escape single quotes', () {
        expect(escapeSingleQuoteString("'", false), r"'\''");
      });
      test('should escape backslash', () {
        expect(escapeSingleQuoteString('\\', false), r"'\\'");
      });
      test('should escape newlines', () {
        expect(escapeSingleQuoteString('\n', false), r"'\n'");
      });
      test('should escape carriage returns', () {
        expect(escapeSingleQuoteString('\r', false), r"'\r'");
      });
      test('should escape \$', () {
        expect(escapeSingleQuoteString('\$', true),  "'\\\$'");
      });
      test('should not escape \$', () {
        expect(escapeSingleQuoteString('\$', false), "'\$'");
      });
    });
  });
}
