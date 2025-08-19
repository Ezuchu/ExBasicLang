
import '../AST/TypeExpr.dart';
import '../ExError.dart';
import '../Token/Token.dart';
import 'ExBool.dart';
import 'ExClass.dart';
import 'ExFunction.dart';
import 'ExValue.dart';

class ExClassInstance extends ExValue{
    @override
    ExType type = ExType.CLASS_INSTANCE;

    final ExClass klass;
    Map<String,ExValue> fields = Map<String,ExValue>();

    ExClassInstance(this.klass);

  ExValue getItem(Token name){
    if(fields.containsKey(name.lexeme)){
      return fields[name.lexeme]!;
    }
    ExFunction? func = klass.findMethod(name.lexeme);
    if(func != null){
      return func.bind(this);
    }
    throw ExError(name.line, name.column, "bad", 3);
  }

  @override
  ExValue copy() {
    ExClassInstance clone = ExClassInstance(klass);
    clone.fields =fields;

    return clone;
  }

  @override
  getValue() {
    return this;
  }

  @override
  ExBool isEqual(ExValue value) {
    if(!(value is ExClassInstance)) return ExBool(false);

    return ExBool(fields == value.fields);
  }

  @override
  set(ExValue value, Token token) {
    if(value is ExClassInstance){
      if(value.klass == klass){
        this.fields = value.fields;
      }
    }
  }
}