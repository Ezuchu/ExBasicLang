import '../AST/TypeExpr.dart';
import '../Token/Token.dart';
import 'ExBool.dart';

abstract class ExValue<R>
{
  late ExType type;

  ExValue(this.type);

  @override
  String toString();

  ExValue copy();

  set(ExValue value, Token token);

  ExBool isEqual(ExValue value);

  R getValue();


}