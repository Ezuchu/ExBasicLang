import '../AST/TypeExpr.dart';
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
  getValue()
  {
    return value;
  }
}