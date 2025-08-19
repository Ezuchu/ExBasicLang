
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
  ExClass? superClass;

  ExClass(this.name,Enviroment closure, this.fields, List<FunDeclaration> methodsDec,FunDeclaration? constructor,this.superClass){
    for(FunDeclaration methodDec in methodsDec){
      methods[methodDec.name.lexeme] = ExFunction(methodDec, closure,false);
    }
    if(constructor != null){
      this.constructor = ExFunction(constructor, closure,true);
    }
  }

  ExFunction? findMethod(String name){
    if(methods.containsKey(name)){
      return methods[name];
    }

    if(superClass != null){
      return superClass!.findMethod(name);
    }
    return null;
  } 

  @override
  ExValue call(Interpreter interpreter, List<ExValue> arguments) {
    ExClassInstance instance = ExClassInstance(this);
    for(Parameter param in fields){
      instance.fields[param.name.lexeme] = interpreter.defineValue(param.name, param.type, null);
    }

    ExClass? superklass = superClass;
    while(superklass != null){
      for(Parameter param in superklass.fields){
        instance.fields[param.name.lexeme] = interpreter.defineValue(param.name, param.type, null);
      }
      superklass = superklass.superClass;
    }


    if(constructor != null){
      constructor!.bind(instance).call(interpreter, arguments);
    }else{
      ExClass? superklass = superClass;
      while(superklass != null){
        if(superklass.constructor != null){
          superklass.constructor!.bind(instance).call(interpreter, arguments);
          break;
        }
        superklass = superklass.superClass;
      }
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