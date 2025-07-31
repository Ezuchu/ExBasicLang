

import '../AST/TypeExpr.dart';

abstract class ExValue<R>
{
  late ExType type;

  ExValue(this.type);

  @override
  String toString();

  ExValue copy();

  R getValue();


}