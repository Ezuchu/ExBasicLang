import '../AST/TypeExpr.dart';
import 'ExBool.dart';

abstract class ExValue<R>
{
  late ExType type;

  ExValue(this.type);

  @override
  String toString();

  ExValue copy();

  set(R value);

  ExBool isEqual(ExValue value);

  R getValue();


}