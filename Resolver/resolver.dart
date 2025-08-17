
import '../AST/Expr.dart';
import '../AST/Parameter.dart';
import '../AST/Stmt.dart';
import '../AST/ExSymbol.dart';
import '../AST/TypeExpr.dart';
import '../ExError.dart';
import '../Token/Token.dart';
import '../Token/TokenType.dart';
import '../runtime/Interpreter.dart';
import '../value/ExValue.dart';


enum FunctionType{
  NONE,
  FUNCTION
}



class Resolver implements ExprVisitor,StmtVisitor
{
  final Interpreter interpreter;
  final Map<String,ExSymbol> global =Map<String,ExSymbol>();
  final List<Map<String,ExSymbol>> scopes = [];
  bool onMain = false;
  FunctionType currentFunction = FunctionType.NONE;
  TypeExpr? currentType;

  
  Resolver(this.interpreter);

  
  void resolveList(List<Statement> statements)
  {
    for(Statement stmt in statements)
    {
      resolve(stmt);
    }
  }

  void resolve(Statement stmt)
  {
    stmt.accept(this);
  }

  TypeExpr resolveExpr(Expression expr){
    return expr.accept(this);
  }

  void beginScope(){
    scopes.add(Map<String,ExSymbol>());
  }

  void endScope(){
    scopes.removeLast();
  }

  void declare(Token name,TypeExpr type){
    Map<String,ExSymbol> scope = scopes.isEmpty? global : scopes.last;
    if(scope.containsKey(name.lexeme)){
      throw ExError(name.line, name.column, "Already a variable with this name in this scope", 3);
    }

    scope[name.lexeme] = ExSymbol(name.lexeme, false, type);
  }

  void define(Token name){
    Map<String,ExSymbol> scope = scopes.isEmpty? global : scopes.last;

    scope[name.lexeme]!.state = true;
  }

  TypeExpr resolveLocal(Expression expr,Token name){
    for(int i = scopes.length-1; i>= 0; i--){
      if(scopes[i].containsKey(name.lexeme)){
        interpreter.resolve(expr,scopes.length-1-i);
        return scopes[i][name.lexeme]!.type;
      }
    }
    if(!global.containsKey(name.lexeme)) throw ExError(name.line, name.column, "implicit variable declaration", 3);
    return global[name.lexeme]!.type;
  }

  void resolveFuntion(FunDeclaration fun,FunctionType type){
    Map<String,ExSymbol> scope = scopes.isEmpty? global : scopes.last;

    FunctionType enclosingFunction = currentFunction;
    TypeExpr? enclosingType = currentType;
    currentFunction = type;
    currentType =fun.returnType;

    beginScope();
    for(Parameter param in fun.parameters){
      declare(param.name,param.type);
      define(param.name);
    }

    resolve(fun.body);
    endScope();
    currentFunction = enclosingFunction;
    currentType = enclosingType;
  }

  @override   
  visitBlockStatement(BlockStatement stmt) {
    beginScope();
    resolveList(stmt.statements);
    endScope();
  }

  @override
  visitClassStmt(ClassStmt stmt) {
    if(scopes.isNotEmpty) throw ExError(stmt.name.line, stmt.name.column, "can't declare a class in a local scope", 3);
    TypeExpr type = ClassTypeExpr(stmt.name.lexeme, stmt.attributes, stmt.methods);
    declare(stmt.name, type);
    define(stmt.name);

    beginScope();

    for(FunDeclaration method in stmt.methods){
      resolve(method);
    }

    endScope();
  }

  @override  
  visitDoStmt(DoStmt stmt) {
    resolve(stmt.body);
    resolveExpr(stmt.condition);
  }

  @override  
  visitExpressionStmt(ExpressionStmt stmt) {
    resolveExpr(stmt.expr);
  }

  @override  
  visitFunDeclaration(FunDeclaration stmt) {
    TypeExpr type = FunctionTypeExpr(stmt.name.lexeme, stmt.parameters.map((p)=>p.type).toList(), stmt.returnType);
    declare(stmt.name,type);
    define(stmt.name);

    resolveFuntion(stmt,FunctionType.FUNCTION);
  }

  @override  
  visitIfStatement(IfStatement stmt) {
    resolveExpr(stmt.condition);
    resolve(stmt.thenBranch);
    if(stmt.elseBranch != null && stmt.elseBranch != []) resolve(stmt.elseBranch!);
  }

  @override
  visitMainStmt(MainStmt stmt) {
    if(onMain) throw ExError(stmt.start.line, stmt.start.column, "Can't declare another main statement ", 3);
    onMain = true;
    resolveList(stmt.statements);
    onMain = false;
  }

  @override  
  visitPrint(Print stmt) {
    resolveExpr(stmt.expr);
  }

  @override  
  visitReturnStmt(ReturnStmt stmt) {
    if(currentFunction == FunctionType.NONE){
      throw ExError(stmt.keyword.line, stmt.keyword.column, "can't return from high level code", 3);
    }
    TypeExpr type;

    if(stmt.expr!= null){ 
      type = resolveExpr(stmt.expr!);
    }else{
      type = TypeExpr(ExType.VOID);
    }

    if(type != currentType) throw ExError(stmt.keyword.line, stmt.keyword.column, "expression incompatible with return type", 3);

  }

  @override  
  visitStructStmr(StructStmt stmt) {
    if(scopes.isNotEmpty) throw ExError(stmt.name.line, stmt.name.column, "can't declare a struct in a local scope", 3);
    
    TypeExpr type = StructTypeExpr(stmt.name.lexeme, stmt.params);
    declare(stmt.name, type);
    define(stmt.name);

  }

  @override  
  visitVarDeclaration(VarDeclaration stmt) {
    TypeExpr type = resolveType(stmt.type);

    declare(stmt.identifier,type);
    if(stmt.initializer !=null){
      TypeExpr initType = resolveExpr(stmt.initializer!);
      if(type != initType){
        if(!(isDouble(stmt.type) && isInt(initType))){
          throw ExError(stmt.identifier.line, stmt.identifier.column, "Incompatible type for initializer", 3);
        }
      }
    }
    define(stmt.identifier);
  }

  @override  
  visitWhileStatement(WhileStatement stmt) {
    resolveExpr(stmt.condition);
    resolve(stmt.body);
  }


  @override
  TypeExpr visitArray(Array expr) {
    TypeExpr contentType = TypeExpr(ExType.VOID);
    int dimension = 0;
    for(Expression item in expr.elements){
      TypeExpr itemType = resolveExpr(item);
      if(contentType.type == ExType.VOID){
        contentType = itemType;
      }else{
        if(contentType != itemType) contentType.type = ExType.ANY;
      }
      dimension++;
    }

    return ArrayType(contentType, 
      Literal(Token(Tokentype.INT, "", dimension, -1, -1),dimension,ExType.INT), 
      dimension);
  }

  @override  
  TypeExpr visitAssignment(Assignment expr) {
    TypeExpr value = resolveExpr(expr.value);
    TypeExpr root = resolveExpr(expr.name);

    if(value != root){
      if(value.type == ExType.DOUBLE && value.type == ExType.INT){
        return value;
      }
      throw ExError(expr.reference.line, expr.reference.column, "Incompatible types on assignment", 3);
    }
    return value;
  }

  @override  
  TypeExpr visitBinary(Binary expr) {
    TypeExpr left = resolveExpr(expr.left);
    TypeExpr right = resolveExpr(expr.right);

    switch(expr.operand.type){
      case Tokentype.PLUS: if(isNumber(left) && isNumber(right)){
          if(isInt(left)&&isInt(right)){
            return TypeExpr(ExType.INT);
          }
          return TypeExpr(ExType.DOUBLE);
        }
        return TypeExpr(ExType.STRING);

      case Tokentype.MINUS:
      case Tokentype.STAR:
        if(!isNumber(left)||isNumber(right))
        {
          throw ExError(expr.operand.line, expr.operand.column, "at least one of the operands is not a number", 3);
        }
        if(isInt(left) && isInt(right)) return TypeExpr(ExType.INT);
        return TypeExpr(ExType.DOUBLE);

      case Tokentype.SLASH: if(!isNumber(left)||isNumber(right))
        {
          throw ExError(expr.operand.line, expr.operand.column, "at least one of the operands is not a number", 3);
        }
        return TypeExpr(ExType.DOUBLE);

      case Tokentype.EQUAL_EQUAL:
      case Tokentype.BANG_EQUAL: return TypeExpr(ExType.BOOL);

      case Tokentype.GREATER:
      case Tokentype.GREATER_EQUAL:
      case Tokentype.LESS:
      case Tokentype.LESS_EQUAL: if(!isNumber(left) && !isNumber(right)){
        throw ExError(expr.operand.line, expr.operand.column, "at least one of the operands is not a number", 3);
        }
        return TypeExpr(ExType.BOOL);
      
      default:          
    }
    return TypeExpr(ExType.VOID);
  }

  @override  
  TypeExpr visitCall(Call expr) {
    TypeExpr calleType = resolveExpr(expr.calee);
    if(!isCallable(calleType)) throw ExError(expr.paren.line, expr.paren.column, "the callee is not a valid function", 3);
    int index = 0;
    if(calleType is FunctionTypeExpr){
      for(Expression arg in expr.arguments){
        TypeExpr argType = resolveExpr(arg);
        if(calleType.parameters[index] != argType){
          if(calleType.parameters[index].type != ExType.DOUBLE || argType.type != ExType.INT){
            throw ExError(expr.paren.line, expr.paren.column, "a parameter is incompatible with the function parameter", 3); 
          }
        }
      }
      return calleType.returnType;
    }
    
    return ClassTypeInstance(calleType as ClassTypeExpr);
    
  }

  @override
  visitGetExpr(GetExpr expr) {
    TypeExpr root = resolveExpr(expr.object);
    if(!isInstance(root)){
      throw ExError(expr.name.line, expr.name.column, "Only instances have properties", 3);
    }

    TypeExpr type = TypeExpr(ExType.VOID);

    if(root is StructTypeInstance){
      type = resolveStructGet(expr.name,root.struct);
    }
    if(root is ClassTypeInstance){
      type = resolveClassGet(expr.name,root.klass);
    }

    return type;
  }

  @override
  TypeExpr visitGroup(Group expr) {
    return resolveExpr(expr.expr);
  }

  @override  
  TypeExpr visitIndex(Index expr) {
    TypeExpr root = resolveExpr(expr.root);
    TypeExpr index = resolveExpr(expr.index);

    if(!(root is ArrayType))throw ExError(expr.start.line, expr.start.column, "referenced value is not a array", 3);

    if(!isInt(index))throw ExError(expr.start.line, expr.start.column, "index value is not a interger", 3);

    return root.itemType;
  }

  @override  
  TypeExpr visitLiteral(Literal expr)
  {
    return TypeExpr(expr.type);
  }

  @override  
  TypeExpr visitLogical(Logical expr) {
    resolveExpr(expr.left);
    resolveExpr(expr.right);

    return TypeExpr(ExType.BOOL);
  }

  @override
  visitPostFix(PostFix expr) {
    resolveExpr(expr.operand);
  }

  @override  
  TypeExpr visitUnary(Unary expr){
    TypeExpr type = resolveExpr(expr.expr);

    switch(expr.operand.type){
      case Tokentype.MINUS: if(!isNumber(type)){ 
          throw ExError(expr.operand.line,expr.operand.column,"operand is not a number value",3);
        };break;
      case Tokentype.BANG: return TypeExpr(ExType.BOOL);
      default:
    }

    return type;
  }

  @override  
  TypeExpr visitVariable(Variable expr) {
    if(!scopes.isEmpty && scopes.last.containsKey(expr.name.lexeme) && scopes.last[expr.name.lexeme]!.state == false){
      throw ExError(expr.name.line, expr.name.column, "Can't read local variable in its own initializer", 3);
    }
    

    return resolveLocal(expr,expr.name);

  }

  TypeExpr resolveType(TypeExpr originType){
    if(primitives.contains(originType.type)) return originType;
    if(originType is ArrayType){
      return ArrayType(resolveType(originType.itemType), originType.dimensionExpr, originType.literalDim);
    }
    TypeExpr type = visitVariable(Variable((originType as  IdentifierType).identifier));
    if(type is StructTypeExpr){
      return StructTypeInstance(type);
    }
    if(type is ClassTypeExpr){
      return ClassTypeInstance(type);
    }
    return originType;
  }

  TypeExpr resolveStructGet(Token name, StructTypeExpr struct){
    if(!struct.fields.containsKey(name.lexeme)){
      throw ExError(name.line, name.column, "The struct type doesn't have that field", 3);
    }
    return struct.fields[name.lexeme]!;
  }

  TypeExpr resolveClassGet(Token name, ClassTypeExpr klass){
    if(!klass.fields.containsKey(name.lexeme)){
      if(!klass.methods.containsKey(name.lexeme)){
        throw ExError(name.line, name.column, "The class type doesn't have that field", 3);
      }
      return klass.methods[name.lexeme]!;
    }
    return klass.fields[name.lexeme]!;
  }

  bool isNumber(TypeExpr type){
    return (type.type == ExType.INT || type.type == ExType.DOUBLE);
  }

  bool isDouble(TypeExpr type){
    return type.type == ExType.DOUBLE;
  }

  bool isInt(TypeExpr type){
    return type.type == ExType.INT;
  }

  bool isStruct(TypeExpr type){
    return type.type == ExType.STRUCT;
  }

  bool isInstance(TypeExpr type){
    return (type is StructTypeInstance || type is ClassTypeInstance);
  }

  bool isCallable(TypeExpr type){
    return (type is FunctionTypeExpr || type is ClassTypeExpr);
  }

}