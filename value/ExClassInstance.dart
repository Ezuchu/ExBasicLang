
import '../AST/TypeExpr.dart';
import '../Token/Token.dart';
import 'ExBool.dart';
import 'ExClass.dart';
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
    return klass.methods[name.lexeme]!;
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