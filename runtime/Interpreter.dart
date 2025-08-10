import 'dart:io';

import '../AST/Expr.dart';
import '../AST/Stmt.dart';
import '../AST/TypeExpr.dart';
import '../ExError.dart';
import '../Token/Token.dart';
import '../Token/TokenType.dart';
import '../value/ExArray.dart';
import '../value/ExArrayBase.dart';
import '../value/ExBool.dart';
import '../value/ExChar.dart';
import '../value/ExDouble.dart';
import '../value/ExInt.dart';
import '../value/ExString.dart';
import '../value/ExValue.dart';
import 'enviroment.dart';

class Interpreter implements ExprVisitor,StmtVisitor{

  Enviroment enviroment = Enviroment(null);


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
  visitMainStmt(MainStmt stmt) {
    Enviroment localMain = Enviroment(enviroment);
    enviroment = localMain;
    for(Statement statement in stmt.statements)
    {
      execute(statement);
    }
    enviroment = enviroment.enclosing!;
  }

  @override  
  visitExpressionStmt(ExpressionStmt stmt) {
    evaluate(stmt.expr);
  }

  @override
  visitPrint(Print stmt) {
    ExValue value = evaluate(stmt.expr);

    print(value);
  }

  @override
  visitVarDeclaration(VarDeclaration stmt) {
    Token identifier = stmt.identifier;

    ExValue? value = stmt.initializer == null? null : this.evaluate(stmt.initializer!);
    
    ExValue initial = defineValue(stmt.identifier,stmt.type,value);

    enviroment.define(identifier, initial);
  }

  @override
  ExValue? visitAssignment(Assignment expr) {
    
    Token reference = expr.reference;
    ExValue variable = evaluate(expr.name);
    ExValue newValue = evaluate(expr.value);

    
    variable.set(newValue,reference);
    
    
    return variable;
  }

  @override
  ExValue visitArray(Array expr)
  {
    List<ExValue> elements = [];
    
    for(Expression item in expr.elements)
    {
      elements.add(evaluate(item));
    }
    ExType? contentType = arrayContentType(elements);
    return ExArray(elements, null, elements.length);
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
        return ExString(value: left.toString() + right.toString());

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
  ExValue visitIndex(Index expr)
  {
    ExValue variable = evaluate(expr.root);
    Token token = expr.start;
    

    if(!(variable is ExArray || variable is ExString))
    {
      throw ExError(token.line, token.column, "the root variable is not a array", 3);
    }

    ExValue index = evaluate(expr.index);
    if(!(index is ExInt)){ 
      throw ExError(token.line, token.column, "the reference index is not an interger", 3);
    }

    ExValue value = (variable as ExArrayBase).getIndex(index,token);

    return value;
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

      case ExType.CHAR: return ExChar(expr.value as String);

      case ExType.STRING: return ExString(value: expr.value as String);

      default:
        throw ExError(token.line, token.column, 'Invalid literal value', 3);
    }
  }

  @override
  ExValue visitLogical(Logical expr)
  {
    ExValue left = evaluate(expr.left);

    if(expr.operator.type == Tokentype.OR)
    {
      if(isTruthy(left)) return ExBool(true);
    }else
    {
      if(!isTruthy(left)) return ExBool(false);
    }

    return ExBool(isTruthy(evaluate(expr.right)));
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

  @override
  ExValue visitVariable(Variable expr)
  {
    return enviroment.get(expr.name);
  }

  ExType? arrayContentType(List<ExValue> elements)
  {
    if(elements.isEmpty) return null;

    ExType type = elements[0].type;

    for(ExValue item in elements)
    {
      if(item.type != type) return null;
    }
    return type;
  }

  ExValue defineValue(Token name, TypeExpr type, ExValue? value)
  {
    ExValue initial;
    

    switch(type.type)
    {
      case ExType.INT : initial = ExInt(null);break;
      case ExType.DOUBLE : initial = ExDouble(null);break;
      case ExType.CHAR : initial = ExChar(null);break;
      case ExType.BOOL : initial = ExBool(null);break;
      case ExType.STRING : initial = ExString();break;
      case ExType.ARRAY : initial = decArray(type as ArrayType, name);break;
      default:
        return ExInt(5);
    }

    if(value != null) initial.set(value,name);

    return initial;
    
  }

  ExValue decArray(ArrayType type, Token name)
  {
    ExValue dimension = evaluate(type.dimensionExpr);
    if(!(dimension is ExInt)) throw ExError(name.line, name.column, "array dimension is not a interger", 3);

    List <ExValue> items = List<ExValue>.generate(dimension.getValue(), (int index) => defineValue(name,type.itemType,null));


    return ExArray(items, type.itemType.type, dimension.getValue());
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

  bool isTruthy(ExValue value)
  {
    if(!(value is ExBool))
    {
      return value.getValue() != null;
    }
    return value.getValue();
  }

  void areNumbers(ExValue left, ExValue right,Token reference)
  {
    
    if(!isNumber(left) || !isNumber(right))
    {
      throw ExError(reference.line, reference.column, 'at least one of the operands is not a number', 3);
    }
  }
  
  
}