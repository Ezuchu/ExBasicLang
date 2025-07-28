
import 'dart:ffi';

import '../AST/Expr.dart';
import '../ExError.dart';
import '../Token/Token.dart';
import '../Token/TokenType.dart';

abstract class ParserBase 
{
  final List<Token> tokens;
  List<Expression> expressions = [];
  int current = 0;

  ParserBase(this.tokens);

  List<Expression> parse()
  {
    while(!isAtEnd())
    {
      expressions.add(expression());
    }
    return expressions;
  }

  Expression expression();
  Expression equality();
  Expression comparison();

  Token advance()
  {
    if(!isAtEnd())current++;
    return previous();
  }

  bool match(List<Tokentype> types)
  {
    for(Tokentype type in types)
    {
      if(check(type))
      {
        advance();
        return true;
      }
    }
    return false;
  }

  bool check(Tokentype type)
  {
    if(isAtEnd()) return false;
    return peek().type == type;
  }

  bool isAtEnd()
  {
    return peek().type == Tokentype.EOF;
  }

  Token peek()
  {
    return tokens[current];
  }

  Token previous()
  {
    return tokens[current-1];
  }

  Token consume(Tokentype type, String message)
  {
    if(check(type)) return advance();

    throw ExError(peek().line, peek().column, message, 2);
  }
}