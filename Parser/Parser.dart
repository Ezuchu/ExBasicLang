import '../AST/Expr.dart';
import '../AST/Stmt.dart';
import '../AST/TypeExpr.dart';
import '../ExError.dart';
import '../Token/Token.dart';
import '../Token/TokenType.dart';
import 'ParserBase.dart';

class Parser extends ParserBase
{


  Parser(super.tokens);

  

  Statement statement()
  {
    if(match([Tokentype.START])) return mainStmt();
    if(match([Tokentype.PRINT])) return printStmt();
    if(match([Tokentype.IF])) return ifStmt();

    if(match(types))
    {
      if(match([Tokentype.IDENTIFIER,Tokentype.LESS]))
      {
        current--;
        return varDeclarationStmt();
      }else
      {
        current--;
      }
    }

    return expressionStmt();
  }

  Statement mainStmt()
  {
    Token start = previous();
    List<Statement> statements = [];

    while(!match([Tokentype.END]))
    {
      if(isAtEnd()) throw ExError(peek().line, peek().column, "the main statement has not been closed", 2);

      statements.add(statement());
    }

    return MainStmt(start, statements);
  }

  Statement expressionStmt()
  {
    Expression expr = expression();

    consume(Tokentype.SEMICOLON, "Expect ';' after sentence");

    return ExpressionStmt(expr);
  }

  Statement ifStmt()
  {
    Token start = previous();
    consume(Tokentype.LEFT_PAREN, "Expected '(' after if");

    Expression condition = expression();
    consume(Tokentype.RIGHT_PAREN, "Expected ')' after condition");

    List<Statement> thenBranch = [];
    List<Statement> elseBranch = [];
    
    if(match([Tokentype.LEFT_BRACE]))
    {
      
      addStatementsTo(thenBranch);
    }else
    {
      thenBranch.add(statement());
    }

    if(match([Tokentype.ELSE]))
    {
      if(match([Tokentype.LEFT_BRACE]))
      {
        addStatementsTo(elseBranch);
      }else
      {
        elseBranch.add(statement());
      }
    }

    return IfStatement(start, condition, thenBranch, elseBranch);
    
  }

  Statement printStmt()
  {
    Token reference = previous();

    Expression expr = expression();

    consume(Tokentype.SEMICOLON, "Expect ';' after sentence");

    return Print(expr, reference);
  }

  Statement varDeclarationStmt()
  {
    ExType? type = exTypeMap[previous().type];

    TypeExpr variableType = typeExpression(type!);


    Expression? initializer;

    consume(Tokentype.IDENTIFIER, '');

    Token identifier = previous();

    if(match([Tokentype.EQUAL]))
    {
      initializer = expression();
    }

    consume(Tokentype.SEMICOLON,"expected ';' after statement");

    return VarDeclaration(variableType, identifier, initializer);
  }

  Expression expression()
  {
    return assignment();
  }

  Expression assignment()
  {
    Expression expr = or();
    
    
    if(match([Tokentype.EQUAL]))
    {
      Token reference = previous();
      Expression value = or();

      if(expr is Variable || expr is Index)
      {
        return Assignment(expr,value,reference);
      }
      throw ExError(reference.line, reference.column, 'assignment target is not a variable name.', 2);
    }
    return expr;
  }

  Expression or()
  {
    Expression expr = and();

    while(match([Tokentype.OR]))
    {
      Token operator = previous();
      Expression right = and();
      expr = Logical(operator, expr, right);
    }

    return expr;
  }

  Expression and()
  {
    Expression expr = equality();

    while(match([Tokentype.AND]))
    {
      Token operator = previous();
      Expression right = equality();
      expr = Logical(operator, expr, right);
    }

    return expr;
  }

  Expression equality()
  {
    Expression expr = comparison();

    while(match([Tokentype.EQUAL_EQUAL,Tokentype.BANG_EQUAL]))
    {
      Token operator = previous();
      Expression right = comparison();
      expr = Binary(expr, right, operator);
    }
    return expr;
  }

  Expression comparison()
  {
    Expression expr = term();

    while(match([Tokentype.LESS,Tokentype.LESS_EQUAL,Tokentype.GREATER,Tokentype.GREATER_EQUAL]))
    {
      Token operator = previous();
      Expression right = term();
      expr = Binary(expr, right, operator);
    }

    return expr;
  }

  Expression term()
  {
    Expression expr = factor();

    while(match([Tokentype.PLUS,Tokentype.MINUS]))
    {
      Token operator = previous();
      Expression right = factor();
      expr = Binary(expr, right, operator);
    }

    return expr;
  }

  Expression factor()
  {
    Expression expr = unary();

    while(match([Tokentype.STAR,Tokentype.SLASH]))
    {
      Token operator = previous();
      Expression right = unary();
      expr = Binary(expr, right, operator);
    }

    return expr;
  }

  Expression unary()
  {
    if(match([Tokentype.BANG,Tokentype.MINUS]))
    {
      Token operator = previous();
      Expression right = unary();
      return Unary(operator, right);
    }

    return index();
  }

  Expression index()
  {
    Expression expr = primary();

    if(expr is Variable)
    {
      while(match([Tokentype.LEFT_BRACKET]))
      {
        Token reference = previous();
        Expression index = equality();
        consume(Tokentype.RIGHT_BRACKET, "Expected a ']'");
        expr = Index(expr, reference, index);
      }
    }
    return expr;
  }

  Expression primary()
  {
    if(match([Tokentype.FALSE])) return Literal(previous(), false, ExType.BOOL);
    if(match([Tokentype.TRUE])) return Literal(previous(), true, ExType.BOOL);

    if(match([Tokentype.INT])) return Literal(previous(), previous().literal!, ExType.INT);
    if(match([Tokentype.DOUBLE])) return Literal(previous(), previous().literal!, ExType.DOUBLE);
    if(match([Tokentype.CHAR])) return Literal(previous(), previous().literal!, ExType.CHAR);
    if(match([Tokentype.STRING])) return Literal(previous(), previous().literal!, ExType.STRING);

    if(match([Tokentype.LEFT_BRACKET]))
    {
      return array();
    }

    if(match([Tokentype.LEFT_PAREN]))
    {
      Expression expr = expression();
      consume(Tokentype.RIGHT_PAREN, "Expect ')' after expression");
      return Group(expr);
    }

    if(match([Tokentype.IDENTIFIER]))
    {
      return Variable(previous());
    }

    throw ExError(peek().line, peek().column, 'Expect expression', 2);
  }

  Expression array()
  {
    Token start = previous();
    List<Expression> elements = [];
    while(!match([Tokentype.RIGHT_BRACKET]))
    {
      if(isAtEnd())
      {
        throw ExError(peek().line, peek().column, "Expected a ']'", 2);
      }
      if(elements.length > 0)
      {
        consume(Tokentype.COMMA, 'Expected a comma after expression');
      }
      Expression expr = or();
      elements.add(expr);
    }
    return Array(elements, start);
  }

  void addStatementsTo(List<Statement> group)
  {
    while(!match([Tokentype.RIGHT_BRACE]))
    {
      if(isAtEnd())throw ExError(peek().line, peek().line, "a conditional statement has not been closed", 2);

      group.add(statement());
    }
  }

  TypeExpr typeExpression(ExType type)
  {
    switch(type)
    {
      case ExType.ARRAY:return arrayTypeExpression();
      default:
        return TypeExpr(type);
    }
  }

  TypeExpr arrayTypeExpression()
  {
    consume(Tokentype.LESS, "Expected '<'");
    if(!match(types))
    {
      throw ExError(peek().line, peek().column, "expected a valid type expression", 2);
    }
    ExType? itemType = exTypeMap[previous().type];
    TypeExpr itemTypeExpr = typeExpression(itemType!);
    consume(Tokentype.LEFT_BRACKET, "Expected '['");
    Expression dimension = or();
    consume(Tokentype.RIGHT_BRACKET, "Expected ']'");
    consume(Tokentype.GREATER, "Expected '>'");
    return ArrayType(itemTypeExpr,dimension);
  }
}