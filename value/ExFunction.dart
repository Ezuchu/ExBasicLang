
import '../AST/Stmt.dart';
import '../AST/TypeExpr.dart';
import '../Token/Token.dart';
import '../Token/TokenType.dart';
import '../runtime/Interpreter.dart';
import '../runtime/Return.dart';
import '../runtime/enviroment.dart';
import 'ExBool.dart';
import 'ExCallable.dart';
import 'ExClassInstance.dart';
import 'ExValue.dart';
import 'ExVoid.dart';

class ExFunction extends ExValue implements ExCallable
{
  final FunDeclaration declaration;
  final Enviroment closure;
  final bool initializer;
  

  ExFunction(this.declaration,this.closure,this.initializer)
  {
    type = ExType.FUNCTION;
  }

  @override
  ExValue call(Interpreter interpreter, List<ExValue> arguments) {
    Enviroment enviroment = Enviroment(closure);
    declaration.parameters.forEach((p) => enviroment.define(p.name, arguments[declaration.parameters.indexOf(p)]));

    Enviroment aux = interpreter.enviroment;
    interpreter.enviroment = enviroment;

    ExValue returnValue = ExVoid();
    try
    {
      interpreter.execute(declaration.body);
    }catch(error)
    {
      if(error is Return)
      {
        returnValue = error.value;
      }
    }
    interpreter.enviroment = aux;

    if(initializer && returnValue is ExVoid){
      return closure.getAt(0, Token(Tokentype.THIS,"this",null,-1,-1));
    }

    return returnValue;
  }

  ExFunction bind(ExClassInstance instance){
    Enviroment env = Enviroment(this.closure);
    env.values["this"] = instance;
    return ExFunction(this.declaration, env,initializer);
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
    return ExBool(value == this);
  }

  @override
  set(ExValue value, Token token) {
    // TODO: implement set
    throw UnimplementedError();
  }
  
}