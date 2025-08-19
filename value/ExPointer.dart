
import '../AST/TypeExpr.dart';
import '../Token/Token.dart';
import 'ExBool.dart';
import 'ExValue.dart';

class ExPointer extends ExValue{
  @override  
  ExType type = ExType.POINTER;

  final ExType pointingType;

  late int? dimension;

  late ExValue? value;

  ExPointer(this.pointingType,this.dimension,this.value);

  @override
  ExValue copy() {
    return ExPointer(pointingType,dimension,value);
  }

  @override
  getValue() {
    return this.value;
  }

  @override
  ExBool isEqual(ExValue value) {
    if(value is ExPointer) return ExBool(this.value == value.value);

    return ExBool(false);
  }

  @override
  set(ExValue value, Token token) {
    this.value = value.getValue();
  }

  @override
  String toString() {
    return super.toString();
  }
  
}