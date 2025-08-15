
import '../Token/Token.dart';
import '../Token/TokenType.dart';
import 'Expr.dart';
import 'Parameter.dart';

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
  Tokentype.VOID_TYPE : ExType.VOID
};

class TypeExpr 
{
  ExType type;

  TypeExpr(this.type);

  @override
  bool operator ==(Object other) {
    if(other is TypeExpr) return type == other.type;

    return super == other;
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

