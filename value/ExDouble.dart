

import '../AST/TypeExpr.dart';
import 'ExBool.dart';
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
  void set(value) {
    this.value = value;
  }
}