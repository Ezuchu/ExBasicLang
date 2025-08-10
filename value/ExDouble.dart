

import '../AST/TypeExpr.dart';
import '../ExError.dart';
import '../Token/Token.dart';
import 'ExBool.dart';
import 'ExInt.dart';
import 'ExValue.dart';

class ExDouble extends ExValue
{
  double? value;
  ExDouble(this.value) : super(ExType.DOUBLE);
  
  @override
  String toString()
  {
    return "$value";
  }
  
  @override
  ExValue copy() {
    return ExDouble(value);
  }

  @override
  ExBool isEqual(ExValue value) {
    return ExBool(this.value == value.getValue());
  }

  @override
  getValue()
  {
    return value;
  }

  @override
  void set(ExValue value,Token token) {
    if(!(value is ExDouble || value is ExInt)) throw ExError(token.line,token.column,"incompatible types in assignment",3);

    this.value = value.getValue();
  }
}