
import '../Token/Token.dart';
import '../Token/TokenType.dart';
import 'Expr.dart';

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

  ArrayType(this.itemType,this.dimensionExpr):super(ExType.ARRAY);

  
}

