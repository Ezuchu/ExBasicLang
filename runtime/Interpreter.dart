

import '../AST/Expr.dart';

class Interpreter implements ExprVisitor{


  Object evaluate(Expression expr)
  {
    return expr.accept(this);
  }

  @override
  visitBinary(Binary expr) {
    // TODO: implement visitBinary
    throw UnimplementedError();
  }

  @override
  visitGroup(Group expr) {
    // TODO: implement visitGroup
    throw UnimplementedError();
  }

  @override
  visitLiteral(Literal expr) {
    // TODO: implement visitLiteral
    throw UnimplementedError();
  }

  @override
  visitUnary(Unary expr) {
    // TODO: implement visitUnary
    throw UnimplementedError();
  }
}