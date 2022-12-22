import 'dart:convert';
import 'dart:io';

import 'package:ngast/ngast.dart';

RecoveringExceptionHandler exceptionHandler = RecoveringExceptionHandler();
Iterable<NgToken> tokenize(String html) {
  exceptionHandler.exceptions.clear();
  return const NgLexer().tokenize(html, exceptionHandler);
}

String untokenize(Iterable<NgToken> tokens) => tokens
    .fold(StringBuffer(), (buffer, token) => buffer..write(token.lexeme))
    .toString();

void main() {
  String input;
  while (true) {
    input = stdin.readLineSync(encoding: utf8)!;
    if (input == 'QUIT') {
      break;
    }
    try {
      var tokens = tokenize(input);
      var fixed = untokenize(tokens);
      if (exceptionHandler.exceptions.isEmpty) {
        print('CORRECT(UNCHANGED): $input');
      } else {
        print('ORGNL: $input');
        print('FIXED: $fixed');
        print('ERRORS:');
        for (var e in exceptionHandler.exceptions) {
          var context = input.substring(e.offset!, e.offset! + e.length!);
          print('${e.errorCode.message} :: $context at ${e.offset}');
        }
      }
    } catch (e) {
      print(e);
    }
  }
}
