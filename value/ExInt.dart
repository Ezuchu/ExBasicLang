

import '../AST/TypeExpr.dart';
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
  getValue()
  {
    return value;
  }
}