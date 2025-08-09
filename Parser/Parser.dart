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

    if(match(types))
    {
      if(match([Tokentype.IDENTIFIER]))
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

    TypeExpr vatiableType;

    Expression? initializer;

    if(type == ExType.IDENTIFIER)
    {
      vatiableType = IdentifierType(type!, previous());
    }else
    {
      vatiableType = TypeExpr(type!);
    }

    consume(Tokentype.IDENTIFIER, '');

    Token identifier = previous();

    if(match([Tokentype.EQUAL]))
    {
      initializer = expression();
    }

    consume(Tokentype.SEMICOLON,"expected ';' after statement");

    return VarDeclaration(vatiableType, identifier, initializer);
  }

  Expression expression()
  {
    return assignment();
  }

  Expression assignment()
  {
    Expression expr = equality();

    if(match([Tokentype.EQUAL]))
    {
      Token reference = previous();
      Expression value = equality();

      if(expr is Variable)
      {
        return Assignment(expr,value,reference);
      }
      throw ExError(reference.line, reference.column, 'assignment target is not a variable name.', 2);
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
      Expression expr = equality();
      elements.add(expr);
    }
    return Array(elements, start);
  }
}