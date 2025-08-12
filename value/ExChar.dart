import '../AST/TypeExpr.dart';
import '../ExError.dart';
import '../Token/Token.dart';
import 'ExBool.dart';
import 'ExValue.dart';

class ExChar extends ExValue
{
  String? value;

  ExChar(this.value)
  {
    type = ExType.CHAR;
  }

  @override
  String toString()
  {
    return value!;
  }

  @override
  ExValue copy()
  {
    return ExChar(value);
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
    if(!(value is ExChar)) throw ExError(token.line,token.column,"incompatible types in assignment",3);

    this.value = value.getValue();
  }
}