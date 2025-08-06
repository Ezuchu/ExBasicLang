import '../Token/Token.dart';
import 'TypeExpr.dart';

abstract class Expression 
{
  R accept<R>(ExprVisitor visitor);
}

abstract class ExprVisitor<R>
{
  R visitArray(Array expr);
  R visitAssignment(Assignment expr);
  R visitBinary(Binary expr);
  R visitGroup(Group expr);
  R visitLiteral(Literal expr);
  R visitVariable(Variable expr);
  R visitUnary(Unary expr);
}

class Array extends Expression
{
  final List<Expression> elements;
  final Token start;

  Array(this.elements,this.start);

  @override
  R accept<R>(ExprVisitor visitor) {
    return visitor.visitArray(this);
  }
}

class Assignment extends Expression
{
  final Expression name;
  final Expression value;
  final Token reference;

  Assignment(this.name,this.value,this.reference);

  @override
  R accept<R>(ExprVisitor visitor) {
    return visitor.visitAssignment(this);
  }
}

class Binary extends Expression
{
  final Expression left;
  final Expression right;
  final Token operand;

  Binary(this.left,this.right,this.operand);

  @override
  R accept<R>(ExprVisitor visitor) {
    return visitor.visitBinary(this);
  }

  @override
  String toString() {
    return "$left ${operand.lexeme} $right";
  }
}

class Group extends Expression
{
  final Expression expr;

  Group(this.expr);

  @override
  R accept<R>(ExprVisitor visitor) {
    return visitor.visitGroup(this);
  }

  @override
  String toString() {
    return "( $expr )";
  }
}

class Literal extends Expression
{
  final Token token;
  final Object value;
  final ExType type;

  Literal(this.token,this.value,this.type);

  @override
  R accept<R>(ExprVisitor visitor) {
    return visitor.visitLiteral(this);
  }

  @override
  String toString() {
    return "$value";
  }
}

class Variable extends Expression
{
  final Token name;

  Variable(this.name);

  R accept<R>(ExprVisitor visitor)
  {
    return visitor.visitVariable(this);
  }
}

class Unary extends Expression
{
  final Token operand;
  final Expression expr;

  Unary(this.operand,this.expr);

  @override
  R accept<R>(ExprVisitor visitor) {
    return visitor.visitUnary(this);
  }

  @override
  String toString() {
    return "${operand.lexeme}$expr";
  }
}