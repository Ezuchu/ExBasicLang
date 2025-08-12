import '../AST/TypeExpr.dart';
import '../Token/Token.dart';
import 'ExBool.dart';
import 'ExValue.dart';

class ExVoid extends ExValue{

  ExVoid(){type = ExType.VOID;}

  @override
  ExValue copy() {
    return ExVoid();
  }

  @override
  getValue() {
    return null;
  }

  @override
  ExBool isEqual(ExValue value) {
    if(value is ExVoid) return ExBool(true);

    return ExBool(value.getValue() == null);
  }

  @override
  set(ExValue value, Token token) {
    // TODO: implement set
    throw UnimplementedError();
  }
}