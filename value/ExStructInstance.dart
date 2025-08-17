import '../AST/TypeExpr.dart';
import '../ExError.dart';
import '../Token/Token.dart';
import 'ExBool.dart';
import 'ExStruct.dart';
import 'ExValue.dart';

class ExStructInstance extends ExValue{
  @override
  ExType type = ExType.STRUCT_INSTANCE;

  final ExStruct struct;
  late Map<String,ExValue?> values;


  ExStructInstance(this.struct,this.values);

  @override
  ExValue copy() {
    return ExStructInstance(struct, values);
  }

  @override
  getValue() {
    return values;
  }

  getItem(Token name){
    if(!values.containsKey(name.lexeme)) throw ExError(name.line, name.column, "wrong propertie", 3);

    return values[name.lexeme];
  }

  @override
  ExBool isEqual(ExValue value) {
    return ExBool(this == value);
  }

  @override
  set(ExValue value, Token token) {
    if(value is ExStructInstance && value.struct == this.struct){
      this.values = value.values;
    }
  }

  @override
  String toString() {
    return values.toString();
  }
  
}