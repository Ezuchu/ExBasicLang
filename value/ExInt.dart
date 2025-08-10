

import '../AST/TypeExpr.dart';
import '../ExError.dart';
import '../Token/Token.dart';
import 'ExBool.dart';
import 'ExValue.dart';

class ExInt extends ExValue
{
  int? value;
  ExInt(this.value) : super(ExType.INT);
  
  @override
  String toString()
  {
    return "$value";
  }
  
  @override
  ExValue copy() {
    return ExInt(value);
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
    if(!(value is ExInt)) throw ExError(token.line,token.column,"incompatible types in assignment",3);

    this.value = value.getValue();
  }


}