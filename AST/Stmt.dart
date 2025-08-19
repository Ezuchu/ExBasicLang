import '../Token/Token.dart';
import 'Expr.dart';
import 'Parameter.dart';
import 'TypeExpr.dart';

abstract class Statement
{
  R accept<R>(StmtVisitor visitor);
}

abstract class StmtVisitor<R>
{
  R visitMainStmt(MainStmt stmt);
  R visitBlockStatement(BlockStatement stmt);
  R visitBreakStmt(BreakStmt stmt);
  R visitClassStmt(ClassStmt stmt);
  R visitDoStmt(DoStmt stmt);
  R visitFunDeclaration(FunDeclaration stmt);
  R visitPrint(Print stmt);
  R visitExpressionStmt(ExpressionStmt stmt);
  R visitIfStatement(IfStatement stmt);
  R visitReturnStmt(ReturnStmt stmt);
  R visitStructStmr(StructStmt stmt);
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

class BreakStmt extends Statement{
  final Token keyword;

  BreakStmt(this.keyword);
  
  @override
  R accept<R>(StmtVisitor visitor) {
    return visitor.visitBreakStmt(this);
  }

  
}

class ClassStmt extends Statement{
  Token name;
  List<Parameter> attributes;
  List<FunDeclaration> methods;
  FunDeclaration? constructor;
  Variable? superClass;

  ClassStmt(this.name,this.attributes,this.methods,this.constructor,this.superClass);
  
  @override
  R accept<R>(StmtVisitor visitor) {
    return visitor.visitClassStmt(this);
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

class FunDeclaration extends Statement
{
  final Token name;
  final List<Parameter> parameters;
  final Statement body;
  final TypeExpr returnType;

  FunDeclaration(this.name,this.parameters,this.body,this.returnType);
  
  @override
  R accept<R>(StmtVisitor visitor) {
    return visitor.visitFunDeclaration(this);
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

class ReturnStmt extends Statement
{
  final Token keyword;
  final Expression? expr;

  ReturnStmt(this.keyword,this.expr);
  
  @override
  R accept<R>(StmtVisitor visitor) {
    return visitor.visitReturnStmt(this);
  }

}

class StructStmt extends Statement{
  final Token name;
  final List<Parameter> params;

  StructStmt(this.name,this.params);
  
  @override
  R accept<R>(StmtVisitor visitor) {
    return visitor.visitStructStmr(this);
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