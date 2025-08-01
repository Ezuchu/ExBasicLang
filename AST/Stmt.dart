import '../Token/Token.dart';
import 'Expr.dart';

abstract class Statement
{
  R accept<R>(StmtVisitor visitor);
}

abstract class StmtVisitor<R>
{
  R visitPrint(Print stmt);
}

class Print extends Statement
{
  Expression expr;
  Token token;

  Print(this.expr,this.token);

  @override  
  R accept<R>(StmtVisitor visitor)
  {
    return visitor.visitPrint(this);
  }
}