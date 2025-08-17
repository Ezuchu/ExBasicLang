
import '../Token/Token.dart';
import '../Token/TokenType.dart';
import 'Expr.dart';
import 'Parameter.dart';
import 'Stmt.dart';

enum ExType
{
  INT,
  DOUBLE,
  CHAR,
  BOOL,
  STRING,

  IDENTIFIER,
  ARRAY,
  FUNCTION,
  ANY,

  STRUCT,
  STRUCT_INSTANCE,

  CLASS,
  CLASS_INSTANCE,

  VOID
}

Map<Tokentype,ExType> exTypeMap = {
  Tokentype.INT_TYPE : ExType.INT,
  Tokentype.DOUBLE_TYPE : ExType.DOUBLE,
  Tokentype.CHAR_TYPE : ExType.CHAR,
  Tokentype.BOOLEAN_TYPE : ExType.BOOL,
  Tokentype.STRING_TYPE : ExType.STRING,
  Tokentype.ARRAY_TYPE : ExType.ARRAY,
  Tokentype.IDENTIFIER : ExType.IDENTIFIER,
  Tokentype.VOID_TYPE : ExType.VOID,
  Tokentype.STRUCT : ExType.STRUCT
};

List<ExType> primitives = [ExType.INT,ExType.CHAR,ExType.DOUBLE,ExType.BOOL,ExType.STRING,ExType.VOID];

class TypeExpr 
{
  ExType type;

  TypeExpr(this.type);

  @override
  bool operator ==(Object other) {
    if(other is TypeExpr) return type == other.type;

    return false;
  }

  @override
  String toString() {
    return "$type";
  }
}

class IdentifierType extends TypeExpr
{
  Token identifier;

  IdentifierType(ExType type,this.identifier):super(type);

  @override
  bool operator ==(Object other) {
    if(other is IdentifierType){
      return identifier.lexeme == identifier.lexeme;
    }
    return false;
  }
}

class ArrayType extends TypeExpr
{
  TypeExpr itemType;
  Expression dimensionExpr;
  int? literalDim;

  ArrayType(this.itemType,this.dimensionExpr,this.literalDim):super(ExType.ARRAY);

  @override
  bool operator ==(Object other) {
    if(!(other is ArrayType)) return  false;
    
    print(itemType);
    print(other.itemType);
    if(itemType != other.itemType) return false;
    

    if(literalDim != null && other.literalDim !=null){
      if(literalDim != other.literalDim) return false;
    }

    return true;
  }

}

class FunctionTypeExpr extends TypeExpr{
  final String name;
  final List<TypeExpr> parameters;
  final TypeExpr returnType;

  FunctionTypeExpr(this.name,this.parameters,this.returnType) : super(ExType.FUNCTION);
}



class StructTypeExpr extends TypeExpr{
  final String name;
  final Map<String,TypeExpr> fields = Map<String,TypeExpr>();

  StructTypeExpr(this.name,List<Parameter> fields):super(ExType.STRUCT)
  {
    for(Parameter field in fields){
      this.fields[field.name.lexeme] = field.type;
    }
  }
}

class StructTypeInstance extends TypeExpr{
  final StructTypeExpr struct;

  StructTypeInstance(this.struct) : super(ExType.STRUCT_INSTANCE);
}

class ClassTypeExpr extends TypeExpr{
  final String name;
  final Map<String,TypeExpr> fields = Map<String,TypeExpr>();
  final Map<String,FunctionTypeExpr> methods = Map<String,FunctionTypeExpr>();

  ClassTypeExpr(this.name,List<Parameter> params, List<FunDeclaration> funDecs) : super(ExType.CLASS)
  {
    for(Parameter param in params){
      fields[param.name.lexeme] = param.type;
    }

    for(FunDeclaration fun in funDecs){
      methods[fun.name.lexeme] = FunctionTypeExpr(fun.name.lexeme, fun.parameters.map((e) => e.type).toList(),fun.returnType);
    }
  }
}

class ClassTypeInstance extends TypeExpr{
  final ClassTypeExpr klass;

  ClassTypeInstance(this.klass) : super(ExType.CLASS_INSTANCE);

  @override
  bool operator ==(Object other) {
    if(other is ClassTypeInstance) return klass == other.klass;

    return false;
  }
}

