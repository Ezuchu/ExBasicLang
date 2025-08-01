import '../AST/Expr.dart';
import '../AST/Stmt.dart';
import '../AST/TypeExpr.dart';
import '../ExError.dart';
import '../Token/Token.dart';
import '../Token/TokenType.dart';
import '../value/ExBool.dart';
import '../value/ExChar.dart';
import '../value/ExDouble.dart';
import '../value/ExInt.dart';
import '../value/ExValue.dart';

class Interpreter implements ExprVisitor,StmtVisitor{


  void interprete(List<Statement> statements)
  {
    for(Statement stmt in statements)
    {
      execute(stmt);
    }
  }

  void execute(Statement stmt)
  {
    stmt.accept(this);
  }

  ExValue evaluate(Expression expr)
  {
    return expr.accept(this);
  }

  @override
  visitPrint(Print stmt) {
    ExValue value = evaluate(stmt.expr);

    print(value);
  }

  @override
  visitBinary(Binary expr) {
    ExValue left = evaluate(expr.left);
    ExValue right = evaluate(expr.right);

    Token operator = expr.operand;

    switch(operator.type)
    {
      case Tokentype.PLUS: 
        if(isNumber(left) && isNumber(right))
        {
          if(left is ExDouble || right is ExDouble)
          {
            return ExDouble(left.getValue() + right.getValue());
          }else
          {
            return ExInt(left.getValue() + right.getValue());
          }
        }
        throw ExError(operator.line, operator.column, 'operand types are not compatible for addition', 3);

      case Tokentype.MINUS:
        if(isNumber(left) && isNumber(right))
        {
          if(left is ExDouble || right is ExDouble)
          {
            return ExDouble(left.getValue() - right.getValue());
          }else
          {
            return ExInt(left.getValue() - right.getValue());
          }
        }
        throw ExError(operator.line, operator.column, 'operand types are not compatible for substraction', 3);

      case Tokentype.STAR:
        if(isNumber(left) && isNumber(right))
        {
          if(left is ExDouble || right is ExDouble)
          {
            return ExDouble(left.getValue() * right.getValue());
          }else
          {
            return ExInt(left.getValue() * right.getValue());
          }
        }
        throw ExError(operator.line, operator.column, 'operand types are not compatible for multiplication', 3);

      case Tokentype.SLASH:
        if(isNumber(left) && isNumber(right))
        {
          return ExDouble(left.getValue()/right.getValue());
        }
        throw ExError(operator.line, operator.column, 'operand types are not compatible for division', 3);


      case Tokentype.EQUAL_EQUAL:
        return left.isEqual(right);

      case Tokentype.BANG_EQUAL:
        return ExBool(!left.isEqual(right).getValue());

      case Tokentype.LESS:
        areNumbers(left,right,operator);
        return ExBool(left.getValue() < right.getValue());
      
      case Tokentype.LESS_EQUAL:
        areNumbers(left,right,operator);
        return ExBool(left.getValue() <= right.getValue());

      case Tokentype.GREATER:
        areNumbers(left,right,operator);
        return ExBool(left.getValue() > right.getValue());

      case Tokentype.GREATER_EQUAL:
        areNumbers(left,right,operator);
        return ExBool(left.getValue() >= right.getValue());

      default:
        throw ExError(operator.line, operator.column, '${operator.lexeme} is not a valid binary operator', 3);
    }
  }

  @override
  ExValue visitGroup(Group expr) {
    return evaluate(expr.expr);
  }

  @override
  ExValue visitLiteral(Literal expr) {
    ExType type = expr.type;
    Token token = expr.token;

    switch(type)
    {
      case ExType.INT: return ExInt(expr.value as int);

      case ExType.DOUBLE: return ExDouble(expr.value as double);

      case ExType.BOOL: return ExBool(expr.value as bool);

      case ExType.CHAR: return Exchar(expr.value as String);

      default:
        throw ExError(token.line, token.column, 'Invalid literal value', 3);
    }
  }

  @override
  ExValue visitUnary(Unary expr) {
    ExValue right = evaluate(expr.expr);
    Token operator = expr.operand;

    switch(expr.operand.type)
    {
      case Tokentype.BANG: return ExBool(!right.getValue());

      case Tokentype.MINUS: if(right is ExInt || right is ExBool)
        {
          return createNumber(-right.getValue());
        }else
        {
          throw ExError(operator.line, operator.column, 'The negative value is not a number', 3);
        }
      default:
        throw ExError(operator.line, operator.column, '${operator.lexeme} is not a valid unary operator', 3);
    }
  }

  ExValue createNumber(num value)
  {
    if(value is int)
    {
      return ExInt(value);
    }
    return ExDouble(value as double);
  }

  bool isNumber(ExValue value)
  {
    if(value is ExInt || value is ExDouble)
    {
      return true;
    }
    return false;
  }

  void areNumbers(ExValue left, ExValue right,Token reference)
  {
    
    if(!isNumber(left) || !isNumber(right))
    {
      throw ExError(reference.line, reference.column, 'at least one of the operands is not a number', 3);
    }
  }
  
  
}