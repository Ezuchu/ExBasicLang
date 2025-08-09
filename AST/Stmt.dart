import '../Token/Token.dart';
import 'Expr.dart';
import 'TypeExpr.dart';

abstract class Statement
{
  R accept<R>(StmtVisitor visitor);
}

abstract class StmtVisitor<R>
{
  R visitMainStmt(MainStmt stmt);
  R visitPrint(Print stmt);
  R visitExpressionStmt(ExpressionStmt stmt);
  R visitVarDeclaration(VarDeclaration stmt);
}

class ExpressionStmt extends Statement
{
  Expression expr;

  ExpressionStmt(this.expr);

  @override  
  R accept<R>(StmtVisitor visitor) {
    return visitor.visitExpressionStmt(this);
  }
}

class MainStmt extends Statement
{
  final Token start;
  final List<Statement> statements;

  MainStmt(this.start,this.statements);

  @override
  R accept<R>(StmtVisitor visitor) {
    return visitor.visitMainStmt(this);
  }

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

class VarDeclaration extends Statement
{
  TypeExpr type;
  Token identifier;
  Expression? initializer;

  VarDeclaration(this.type,this.identifier,this.initializer);
  
  @override
  R accept<R>(StmtVisitor visitor) {
    return visitor.visitVarDeclaration(this);
  }
}