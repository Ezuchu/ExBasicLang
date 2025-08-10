import '../AST/TypeExpr.dart';
import '../ExError.dart';
import '../Token/Token.dart';
import 'ExValue.dart';

class ExBool extends ExValue
{
  bool? value;

  ExBool(this.value):super(ExType.BOOL);

  @override
  String toString()
  {
    return "$value";
  }

  @override
  ExValue copy() {
    return ExBool(value);
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
    if(!(value is ExBool)) throw ExError(token.line,token.column,"incompatible types in assignment",3);

    this.value = value.getValue();
  }

}