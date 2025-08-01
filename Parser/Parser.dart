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
    Token act = tokens[current];
    switch(act.type)
    {
      case Tokentype.PRINT: return printStmt();

      default:
        throw ExError(act.line, act.column, 'unknown statement', 2);
    }
  }

  Statement printStmt()
  {
    match([Tokentype.PRINT]);
    Token reference = previous();

    Expression expr = expression();

    consume(Tokentype.SEMICOLON, "Expect ';' after sentence");

    return Print(expr, reference);
  }

  Expression expression()
  {
    return equality();
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

    return primary();
  }

  Expression primary()
  {
    if(match([Tokentype.FALSE])) return Literal(previous(), false, ExType.BOOL);
    if(match([Tokentype.TRUE])) return Literal(previous(), true, ExType.BOOL);

    if(match([Tokentype.INT])) return Literal(previous(), previous().literal!, ExType.INT);
    if(match([Tokentype.DOUBLE])) return Literal(previous(), previous().literal!, ExType.DOUBLE);
    if(match([Tokentype.CHAR])) return Literal(previous(), previous().literal!, ExType.CHAR);
    if(match([Tokentype.STRING])) return Literal(previous(), previous().literal!, ExType.STRING);

    if(match([Tokentype.LEFT_PAREN]))
    {
      Expression expr = expression();
      consume(Tokentype.RIGHT_PAREN, "Expect ')' after expression");
      return Group(expr);
    }

    throw ExError(peek().line, peek().column, 'Expect expression', 2);
  }
}