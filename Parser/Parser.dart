import '../AST/Expr.dart';
import '../AST/Parameter.dart';
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
    if(match([Tokentype.LEFT_BRACE])) return blockStatement();
    if(match([Tokentype.IF])) return ifStmt();
    if(match([Tokentype.WHILE])) return whileStmt();
    if(match([Tokentype.FOR])) return forStmt();
    if(match([Tokentype.DO])) return doStmt();
    if(match([Tokentype.PRINT])) return printStmt();
    if(match([Tokentype.RETURN])) return returnStmt();
    if(match([Tokentype.STRUCT])) return structStmt();
    if(match([Tokentype.CLASS])) return classStmt();

    

    if(match(types))
    {
      if(match([Tokentype.IDENTIFIER,Tokentype.LESS]))
      {
        current--;
        return declarationStmt();
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

  Statement blockStatement()
  {
    List<Statement> statements = [];

    addStatementsTo(statements);

    return BlockStatement(statements);
  }

  Statement classStmt(){
    Token name = consume(Tokentype.IDENTIFIER, "Expected class name");
    consume(Tokentype.LEFT_BRACE, "Expected '{' after class name");
    List<FunDeclaration> methods = [];
    List<Parameter> attributes = [];

    while(match(types)){
      Statement property =declarationStmt();
      if(property is FunDeclaration){
        methods.add(property);
      }else if(property is VarDeclaration)
      {
        attributes.add(Parameter(property.identifier, property.type));
      }
    }
    consume(Tokentype.RIGHT_BRACE, "Expected '}' to close class declaration");

    return ClassStmt(name, attributes,methods);
  }

  Statement doStmt()
  {

    Statement body = statement();

    consume(Tokentype.UNTIL, "Expected the condition to end the repeat loop");
    consume(Tokentype.LEFT_PAREN, "Expected '(' after until");
    Expression condition = expression();
    consume(Tokentype.RIGHT_PAREN, "Expected ')' after condition");
    consume(Tokentype.SEMICOLON, "Expected ';' after statement");

    return DoStmt(body, condition);
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

    Statement thenBranch = statement();;
    Statement? elseBranch;
    
    if(match([Tokentype.ELSE])) elseBranch = statement();

    return IfStatement(start, condition, thenBranch, elseBranch);    
  }

  Statement forStmt()
  {
    Token start = previous();
    consume(Tokentype.LEFT_PAREN, "Expected '(' after for");

    Statement? initializer;
    if(match([Tokentype.SEMICOLON]))
    {
      initializer = null;
    }else
    {
      initializer = statement();
      if(!(initializer is VarDeclaration || initializer is ExpressionStmt))
      {
        throw ExError(previous().line, previous().column, "the initializer is not a valid declaration", 2);
      }
    }
    Expression? condition;

    if(!check(Tokentype.SEMICOLON)) condition = expression();
    consume(Tokentype.SEMICOLON, "Expect ';' after loop condition");

    Expression? increment;
    if(!check(Tokentype.RIGHT_PAREN)) increment = expression();
    consume(Tokentype.RIGHT_PAREN, "Expect ')' after expression");

    
    Statement body = statement();
    if(increment != null) body = BlockStatement([body,ExpressionStmt(increment)]);

    if(condition == null) condition = Literal(previous(), true, ExType.BOOL);
    body = WhileStatement(start, condition, body);

    if(initializer != null) body = BlockStatement([initializer,body]);

    return body;
  }

  Statement printStmt()
  {
    Token reference = previous();

    Expression expr = expression();

    consume(Tokentype.SEMICOLON, "Expect ';' after sentence");

    return Print(expr, reference);
  }

  Statement declarationStmt()
  {
    ExType? type = exTypeMap[previous().type];

    TypeExpr variableType = typeExpression(type!);

    Expression? initializer;

    consume(Tokentype.IDENTIFIER, '');

    Token identifier = previous();

    if(match([Tokentype.LEFT_PAREN]))
    {
      return funDeclaration(variableType,identifier);
    }

    if(match([Tokentype.EQUAL]))
    {
      initializer = expression();
    }

    consume(Tokentype.SEMICOLON,"expected ';' after statement");

    return VarDeclaration(variableType, identifier, initializer);
  }

  Statement funDeclaration(TypeExpr returnType, Token identifier)
  {
    List<Parameter> parameters = getParameters(Tokentype.RIGHT_PAREN);

    consume(Tokentype.LEFT_BRACE, "Expected '{' after parameters");
    Statement body = blockStatement();

    return FunDeclaration(identifier, parameters, body, returnType);
  }

  Statement returnStmt()
  {
    Token token = previous();

    Expression? value = null;
    if(!check(Tokentype.SEMICOLON)) value = expression();

    consume(Tokentype.SEMICOLON, "Expect ';' after return value");

    return ReturnStmt(token, value);
  }

  Statement structStmt(){
    Token name = consume(Tokentype.IDENTIFIER, "Expected a struct type identifier");
    consume(Tokentype.LEFT_BRACE, "expected '{' after identifier");
    List<Parameter> params = getParameters(Tokentype.RIGHT_BRACE);

    return StructStmt(name, params);
  }

  Statement whileStmt()
  {
    Token start = previous();

    consume(Tokentype.LEFT_PAREN, "Expected '(' after if");

    Expression condition = expression();
    consume(Tokentype.RIGHT_PAREN, "Expected ')' after condition");

    Statement body = statement();

    return WhileStatement(start, condition, body);
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

      if(expr is Variable || expr is Index || expr is GetExpr)
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

    return postFix();
  }

  Expression postFix()
  {
    Expression expr = index();

    if(match([Tokentype.PLUS_PLUS,Tokentype.MINUS_MINUS]))
    {
      Token operator = previous();
      return PostFix(operator, expr);
    }

    return expr;
  }

  Expression index()
  {
    Expression expr = call();

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

  Expression call()
  {
    Expression expr = primary();

    while(true)
    {
      if(match([Tokentype.LEFT_PAREN]))
      {
        expr = finishCall(expr);
      }else if(match([Tokentype.DOT]))
      {
        Token name = consume(Tokentype.IDENTIFIER, "Expect property name after '.'.");
        expr = GetExpr(expr, name);
      }else
      {
        break;
      }
    }
    return expr;
  }

  Expression finishCall(Expression calee)
  {
    List<Expression> arguments = [];
    if(!check(Tokentype.RIGHT_PAREN))
    {
      do
      {
        arguments.add(expression());
      } while(match([Tokentype.COMMA]));
    }

    Token paren = consume(Tokentype.RIGHT_PAREN, "Expect ')' after arguments");

    return Call(calee, paren, arguments);
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

  List<Parameter> getParameters(Tokentype terminator)
  {
    List<Parameter> parameters = [];

    if(!check(terminator))
    {
      do
      {
        if(!match(types)) throw ExError(peek().line, peek().column, "Expected a parameter type", 2);
        TypeExpr type = typeExpression(exTypeMap[previous().type]!);
        Token name = consume(Tokentype.IDENTIFIER, "Expected a paramater name");
        parameters.add(Parameter(name, type));
      }while(match([Tokentype.COMMA]));
    }
    consume(terminator, "Expected the closure after parameters");

    return parameters;
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
      case ExType.IDENTIFIER : return IdentifierType(type, previous());
      default:
        return TypeExpr(type);
    }
  }

  TypeExpr arrayTypeExpression()
  {
    int? literal;
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
    if(dimension is Literal){
      if(dimension.type == ExType.INT) literal = dimension.value as int;
    }
    return ArrayType(itemTypeExpr,dimension,literal);
  }
}