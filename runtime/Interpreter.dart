
import 'dart:collection';

import '../AST/Expr.dart';
import '../AST/Parameter.dart';
import '../AST/Stmt.dart';
import '../AST/TypeExpr.dart';
import '../ExError.dart';
import '../Natives/Clock.dart';
import '../Token/Token.dart';
import '../Token/TokenType.dart';
import '../value/ExArray.dart';
import '../value/ExArrayBase.dart';
import '../value/ExBool.dart';
import '../value/ExCallable.dart';
import '../value/ExChar.dart';
import '../value/ExClass.dart';
import '../value/ExClassInstance.dart';
import '../value/ExDouble.dart';
import '../value/ExFunction.dart';
import '../value/ExInt.dart';
import '../value/ExString.dart';
import '../value/ExStruct.dart';
import '../value/ExStructInstance.dart';
import '../value/ExValue.dart';
import '../value/ExVoid.dart';
import 'Break.dart';
import 'Return.dart';
import 'enviroment.dart';

class Interpreter implements ExprVisitor,StmtVisitor{

  Enviroment global = Enviroment(null);
  late Enviroment enviroment;

  final HashMap<Expression,int> locals = HashMap<Expression,int>();

  Interpreter()
  {
    this.enviroment = global;
    global.values["clock"] = Clock();
  }


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

  void executeBlock(List<Statement> statements)
  {
    Enviroment local = Enviroment(enviroment);
    enviroment = local;

    for(Statement statement in statements)
    {
      execute(statement);
    }
    enviroment = enviroment.enclosing!;
  }

  ExValue evaluate(Expression expr)
  {
    return expr.accept(this);
  }

  void resolve(Expression expr, int depth){
    locals[expr]=depth;
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
  void visitBlockStatement(BlockStatement stmt) {
    executeBlock(stmt.statements);
  }

  @override
  visitBreakStmt(BreakStmt stmt) {
    throw Break();
  }

  @override
  visitCall(Call expr) {
    ExValue callee = evaluate(expr.calee);
    List<ExValue> arguments = expr.arguments.map((arg)=> evaluate(arg)).toList();

    if(!(callee is ExCallable)) throw ExError(expr.paren.line, expr.paren.column, "The expression is not a valid callable", 3);

    ExCallable function = callee as ExCallable;

    return function.call(this, arguments);
  }

  @override
  visitClassStmt(ClassStmt stmt) {
    ExClass? superClass;
    if(stmt.superClass != null){
      superClass = visitVariable(stmt.superClass!) as ExClass;
    }

    enviroment.define(stmt.name, ExVoid());
    ExClass klass = ExClass(stmt.name.lexeme, enviroment, stmt.attributes, stmt.methods,stmt.constructor,superClass);
    enviroment.values[stmt.name.lexeme] = klass;
  }

  @override  
  visitExpressionStmt(ExpressionStmt stmt) {
    evaluate(stmt.expr);
  }

  @override  
  visitDoStmt(DoStmt stmt) {
    bool pass = true;
    while(pass)
    {
      try {
        execute(stmt.body);
      } catch (e) {
        if(e is Break){
          break;
        }else{
          throw e;
        }
      }
      pass = !isTruthy(evaluate(stmt.condition));
    }
  }

  @override
  visitFunDeclaration(FunDeclaration stmt) {
    ExFunction function = ExFunction(stmt,enviroment,false);
    enviroment.define(stmt.name, function);
  }

  @override  
  visitIfStatement(IfStatement stmt) {
    if(isTruthy(evaluate(stmt.condition)))
    {
      execute(stmt.thenBranch);
    }else if(stmt.elseBranch != null)
    {
      execute(stmt.elseBranch!);
    } 
  }

  @override
  visitPrint(Print stmt) {
    ExValue value = evaluate(stmt.expr);

    print(value);
  }

  @override
  visitReturnStmt(ReturnStmt stmt) {
    ExValue value = stmt.expr!=null? evaluate(stmt.expr!) : ExVoid(); 
    throw Return(value);
  }

  @override  
  visitStructStmr(StructStmt stmt) {
    ExStruct struct = ExStruct(stmt.name.lexeme, stmt.params);
    enviroment.define(stmt.name, struct);
  }

  @override
  visitSwitchStmt(SwitchStmt stmt) {
    ExValue object = evaluate(stmt.object);
    bool exec = false;
    for((Literal? a ,BlockStatement b) kase in stmt.cases){
      if(!exec){
        if(kase.$1 == null){
        exec = true;
        }else{
          ExValue value = evaluate(kase.$1!);
          if(isTruthy(object.isEqual(value))) exec = true;
        }
      }
      if(exec){
        try {
          visitBlockStatement(kase.$2);
        } catch (e) {
          if(e is Break){
            break;
          }else{
            throw e;
          }
        }
      }
    }
  }

  @override
  visitVarDeclaration(VarDeclaration stmt) {
    Token identifier = stmt.identifier;

    ExValue? value = stmt.initializer == null? null : this.evaluate(stmt.initializer!);
    
    
    ExValue initial = defineValue(stmt.identifier,stmt.type,value);

    enviroment.define(identifier, initial);
  }

  @override  
  visitWhileStatement(WhileStatement stmt) {
    while(isTruthy(evaluate(stmt.condition))) {
      try {
        execute(stmt.body);
      } catch (e) {
        if(e is Break){
          break;
        }else{
          throw e;
        }
      }
    } 
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
    return ExArray(elements, contentType, elements.length);
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
  ExValue visitGetExpr(GetExpr expr){
    ExValue root = evaluate(expr.object);
    if(root is ExStructInstance){
      return root.getItem(expr.name);
    }
    if(root is ExClassInstance){
      return root.getItem(expr.name);
    }
    throw ExError(expr.name.line, expr.name.column, "The variable is not a instance", 3);
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
  ExValue visitPostFix(PostFix expr)
  {
    ExValue initial = evaluate(expr.operand);

    ExValue copy = initial.copy();

    if(expr.operator.type == Tokentype.PLUS_PLUS)
    {
      initial.set(ExInt(initial.getValue()+1),expr.operator);
    }else
    {
      initial.set(ExInt(initial.getValue()-1),expr.operator);
    }

    return copy;
  }

  @override  
  ExValue visitThisExpr(ThisExpr expr){
    return lookUpVariable(expr.keyword, expr);
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
    return lookUpVariable(expr.name, expr);
  }

  ExValue lookUpVariable(Token name, Expression expr){
    if(locals.containsKey(expr)){
      int distance = locals[expr]!;
      return enviroment.getAt(distance,name);
    }else{
      return global.get(name);
    }
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
      case ExType.IDENTIFIER : initial = decInstance(type as IdentifierType,name);break;
      default:
        return ExInt(5);
    }

    if(value != null){ 
      initial.set(value,name);
    };
    
    return initial;
    
  }

  ExValue decArray(ArrayType type, Token name)
  {
    ExValue dimension = evaluate(type.dimensionExpr);
    if(!(dimension is ExInt)) throw ExError(name.line, name.column, "array dimension is not a interger", 3);

    List <ExValue> items = List<ExValue>.generate(dimension.getValue(), (int index) => defineValue(name,type.itemType,null));


    return ExArray(items, type.itemType.type, dimension.getValue());
  }

  ExValue decInstance(IdentifierType type, Token name){
    ExValue structure = global.get(type.identifier);
    if(structure is ExStruct){
      return decStructInstance(structure,name);
    }
    if(structure is ExClass){
      return decClassInstance(structure,name);
    }
    throw ExError(name.line, name.column, "The variable doesn't have a valid type", 3);
  }

  ExValue decStructInstance(ExStruct dec, Token name){
    Map<String,ExValue> fields = Map<String,ExValue>();
    for(Parameter param in dec.fieldsName){
      fields[param.name.lexeme] = defineValue(name, param.type, null);
    }
    return ExStructInstance(dec, fields);
  }

  ExValue decClassInstance(ExClass dec, Token name){
    Map<String,ExValue> fields = Map<String,ExValue>();
    for(Parameter param in dec.fields){
      fields[param.name.lexeme] = defineValue(param.name, param.type, null);
    }
    ExClass? superKlass = dec.superClass;
    while(superKlass != null)
    {
      for(Parameter param in superKlass.fields){
        fields[param.name.lexeme] = defineValue(param.name, param.type, null);
      }
      superKlass = superKlass.superClass;
    }
    return ExClassInstance(dec);
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