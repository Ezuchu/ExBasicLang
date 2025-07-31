import '../AST/TypeExpr.dart';
import 'ExValue.dart';

class ExBool extends ExValue
{
  bool value;

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
  getValue()
  {
    return value;
  }
}