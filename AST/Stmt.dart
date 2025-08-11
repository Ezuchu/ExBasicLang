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
  R visitBlockStatement(BlockStatement stmt);
  R visitDoStmt(DoStmt stmt);
  R visitPrint(Print stmt);
  R visitExpressionStmt(ExpressionStmt stmt);
  R visitIfStatement(IfStatement stmt);
  R visitVarDeclaration(VarDeclaration stmt);
  R visitWhileStatement(WhileStatement stmt);
}

class BlockStatement extends Statement
{
  List<Statement> statements;

  BlockStatement(this.statements);
  
  @override
  R accept<R>(StmtVisitor visitor) {
    return visitor.visitBlockStatement(this);
  }

}

class DoStmt extends Statement
{
  final Statement body;
  final Expression condition;

  DoStmt(this.body,this.condition);
  
  @override
  R accept<R>(StmtVisitor visitor) {
    return visitor.visitDoStmt(this);
  }

  
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

class IfStatement extends Statement
{
  final Token start;
  final Expression condition;
  final Statement thenBranch;
  final Statement? elseBranch;

  IfStatement(this.start,this.condition,this.thenBranch,this.elseBranch);
  
  @override
  R accept<R>(StmtVisitor visitor) {
    return visitor.visitIfStatement(this);
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

class WhileStatement extends Statement
{
  final Token start;
  final Expression condition;
  final Statement body;

  WhileStatement(this.start,this.condition,this.body);
  
  @override
  R accept<R>(StmtVisitor visitor) {
    return visitor.visitWhileStatement(this);
  }

  
}