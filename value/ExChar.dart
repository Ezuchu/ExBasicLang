import '../AST/TypeExpr.dart';
import 'ExBool.dart';
import 'ExValue.dart';

class Exchar extends ExValue
{
  String? value;

  Exchar(String? value) : super(ExType.CHAR)
  {
    this.value = value;
  }

  @override
  String toString()
  {
    return value!;
  }

  @override
  ExValue copy()
  {
    return Exchar(value);
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
}