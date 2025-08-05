 import 'dart:collection';

import '../ExError.dart';
import '../Token/Token.dart';
import '../value/ExValue.dart';

class Enviroment 
 {
    Map<String,ExValue> values = HashMap<String,ExValue>();

    ExValue get(Token name)
    {
      if(!values.containsKey(name.lexeme))
      {
        throw ExError(name.line, name.column, 'Undefined variable', 3);
      }

      return values[name.lexeme]!;
    }

    void define(Token identifier, ExValue value)
    {
      values[identifier.lexeme] = value;
    }
 }