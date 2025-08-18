
import '../AST/Parameter.dart';
import '../AST/Stmt.dart';
import '../AST/TypeExpr.dart';
import '../Token/Token.dart';
import '../runtime/Interpreter.dart';
import '../runtime/enviroment.dart';
import 'ExBool.dart';
import 'ExCallable.dart';
import 'ExClassInstance.dart';
import 'ExFunction.dart';
import 'ExValue.dart';

class ExClass extends ExValue implements ExCallable{
  @override
  ExType type = ExType.CLASS;

  final String name;
  final List<Parameter> fields;
  final Map<String,ExFunction> methods = Map<String,ExFunction>();
  ExFunction? constructor;

  ExClass(this.name,Enviroment closure, this.fields, List<FunDeclaration> methodsDec,FunDeclaration? constructor){
    for(FunDeclaration methodDec in methodsDec){
      methods[methodDec.name.lexeme] = ExFunction(methodDec, closure,false);
    }
    if(constructor != null){
      this.constructor = ExFunction(constructor, closure,true);
    }
  }

  @override
  ExValue call(Interpreter interpreter, List<ExValue> arguments) {
    ExClassInstance instance = ExClassInstance(this);
    for(Parameter param in fields){
      instance.fields[param.name.lexeme] = interpreter.defineValue(param.name, param.type, null);
    }

    if(constructor != null){
      constructor!.bind(instance).call(interpreter, arguments);
    }

    return instance;
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
    return ExBool(this == value);
  }

  @override
  set(ExValue value, Token token) {
    // TODO: implement set
    throw UnimplementedError();
  }
  
}