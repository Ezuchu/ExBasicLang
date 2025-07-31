

import '../AST/TypeExpr.dart';
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
  getValue()
  {
    return value;
  }
}