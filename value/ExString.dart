

import '../AST/TypeExpr.dart';
import '../ExError.dart';
import '../Token/Token.dart';
import 'ExArrayBase.dart';
import 'ExBool.dart';
import 'ExChar.dart';
import 'ExValue.dart';

class ExString extends ExArrayBase implements ExValue
{
  @override
  ExType type = ExType.STRING;

  ExString({String value = ""}) : super(value.split("").map((c)=> ExChar(c)).toList());

  @override
  ExValue copy() {
    return this;
  }

  @override
  getValue() {
    return this.toString();
  }

  @override
  ExBool isEqual(ExValue value) {
    if(!(value is ExString)) return ExBool(false);

    return ExBool(this.toString() == value.toString());
  }

  @override
  set(ExValue value, Token token) {
    if(!(value is ExString)) throw ExError(token.line, token.column, "incompatible types in assignment",3);

    elements = (value.getValue() as String).split("").map((c) => ExChar(c)).toList();
  }

  @override
  String toString() {
    return elements.map((e) => e.getValue()).join("");
  }
  
}