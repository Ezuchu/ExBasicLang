
import '../Token/Token.dart';
import '../Token/TokenType.dart';

enum ExType
{
  INT,
  DOUBLE,
  CHAR,
  BOOL,

  STRING, 
  IDENTIFIER
}

Map<Tokentype,ExType> exTypeMap = {
  Tokentype.INT_TYPE : ExType.INT,
  Tokentype.DOUBLE_TYPE : ExType.DOUBLE,
  Tokentype.CHAR_TYPE : ExType.CHAR,
  Tokentype.BOOLEAN_TYPE : ExType.BOOL,
  Tokentype.IDENTIFIER : ExType.IDENTIFIER
};

class TypeExpr 
{
  ExType type;

  TypeExpr(this.type);
}

class IdentifierType extends TypeExpr
{
  Token identifier;

  IdentifierType(ExType type,this.identifier):super(type);
}

