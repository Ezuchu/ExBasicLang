import '../AST/TypeExpr.dart';
import '../Token/Token.dart';
import '../runtime/Interpreter.dart';
import '../value/ExBool.dart';
import '../value/ExCallable.dart';
import '../value/ExInt.dart';
import '../value/ExValue.dart';

class Clock extends ExCallable{


  
  
  Clock(){
    this.type = ExType.FUNCTION;
  }

  @override
  ExValue call(Interpreter interpreter, List<ExValue> arguments) {
    return ExInt(DateTime.now().millisecondsSinceEpoch);
  }

  @override
  ExValue copy() {
    return this;
  }

  @override
  getValue() {
    return this;
  }

  @override
  ExBool isEqual(ExValue value) {
    if(value is Clock) return ExBool(true);
    return ExBool(false);
  }

  @override
  set(ExValue value, Token token) {
    // TODO: implement set
    throw UnimplementedError();
  }
}