

import '../AST/Parameter.dart';
import '../AST/TypeExpr.dart';
import '../Token/Token.dart';
import 'ExBool.dart';
import 'ExValue.dart';

class ExStruct extends ExValue{
  @override
  ExType type = ExType.STRUCT;

  final String name;
  final List<Parameter> fieldsName;

  ExStruct(this.name,this.fieldsName);

  @override
  ExValue copy() {
    return ExStruct(name, fieldsName);
  }

  @override
  getValue() {
    return fieldsName;
  }

  @override
  ExBool isEqual(ExValue value) {
    return ExBool(this == value);
  }

  @override
  set(ExValue value, Token token) {
    // TODO: implement set
    throw UnimplementedError();
  }
  
}