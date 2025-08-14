
import '../AST/Expr.dart';
import '../AST/Parameter.dart';
import '../AST/Stmt.dart';
import '../ExError.dart';
import '../Token/Token.dart';
import '../runtime/Interpreter.dart';


enum FunctionType{
  NONE,
  FUNCTION
}


class Resolver implements ExprVisitor,StmtVisitor
{
  final Interpreter interpreter;
  final List<Map<String,bool>> scopes = [];
  bool onMain = false;
  FunctionType currentFunction = FunctionType.NONE;

  
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

  void resolveExpr(Expression expr){
    expr.accept(this);
  }

  void beginScope(){
    scopes.add(Map<String,bool>());
  }

  void endScope(){
    scopes.removeLast();
  }

  void declare(Token name){
    if(scopes.isEmpty)return;
    Map<String,bool> scope = scopes.last;
    if(scope.containsKey(name.lexeme)){
      throw ExError(name.line, name.column, "Already a variable with this name in this scope", 3);
    }

    scope[name.lexeme] = false;
  }

  void define(Token name){
    if(scopes.isEmpty)return;

    scopes.last[name.lexeme] = true;
  }

  void resolveLocal(Expression expr,Token name){
    for(int i = scopes.length-1; i>= 0; i--){
      if(scopes[i].containsKey(name.lexeme)){
        interpreter.resolve(expr,scopes.length-1-i);
        return;
      }
    }
  }

  void resolveFuntion(FunDeclaration fun,FunctionType type){
    FunctionType enclosingFunction = currentFunction;
    currentFunction = type;

    beginScope();
    for(Parameter param in fun.parameters){
      declare(param.name);
      define(param.name);
    }

    resolve(fun.body);
    endScope();
    currentFunction = enclosingFunction;
  }

  @override   
  visitBlockStatement(BlockStatement stmt) {
    beginScope();
    resolveList(stmt.statements);
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
    declare(stmt.name);
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

    if(stmt.expr!= null) resolveExpr(stmt.expr!);
  }

  @override  
  visitVarDeclaration(VarDeclaration stmt) {
    declare(stmt.identifier);
    if(stmt.initializer !=null){
      resolveExpr(stmt.initializer!);
    }
  }

  @override  
  visitWhileStatement(WhileStatement stmt) {
    resolveExpr(stmt.condition);
    resolve(stmt.body);
  }


  @override
  visitArray(Array expr) {
    for(Expression item in expr.elements){
      resolveExpr(item);
    }
  }

  @override  
  visitAssignment(Assignment expr) {
    resolveExpr(expr.value);
    resolveExpr(expr.name);
  }

  @override  
  visitBinary(Binary expr) {
    resolveExpr(expr.left);
    resolveExpr(expr.right);
  }

  @override  
  visitCall(Call expr) {
    resolveExpr(expr.calee);
    for(Expression arg in expr.arguments){
      resolveExpr(arg);
    }
  }

  @override
  visitGroup(Group expr) {
    resolveExpr(expr.expr);
  }

  @override  
  visitIndex(Index expr) {
    resolveExpr(expr.root);
    resolveExpr(expr.index);
  }

  @override  
  visitLiteral(Literal expr){}

  @override  
  visitLogical(Logical expr) {
    resolveExpr(expr.left);
    resolveExpr(expr.right);
  }

  @override
  visitPostFix(PostFix expr) {
    resolveExpr(expr.operand);
  }

  @override  
  visitUnary(Unary expr){
    resolveExpr(expr.expr);
  }

  @override  
  visitVariable(Variable expr) {
    if(!scopes.isEmpty && scopes.last[expr.name] == false){
      throw ExError(expr.name.line, expr.name.column, "Can't read local variable in its own initializer", 3);
    }

    resolveLocal(expr,expr.name);
  }

}