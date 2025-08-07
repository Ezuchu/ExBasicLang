enum Tokentype 
{
    LEFT_BRACE,
    RIGHT_BRACE,
    LEFT_PAREN,
    RIGHT_PAREN,
    LEFT_BRACKET,
    RIGHT_BRACKET,
    COMMA,
    SEMICOLON,
    DOT,



    PLUS,
    MINUS,
    STAR,
    SLASH,

    BANG,
    EQUAL,
    LESS,
    GREATER,

    PLUS_EQUAL,
    MINUS_EQUAL,
    STAR_EQUAL,
    BANG_EQUAL,
    EQUAL_EQUAL,
    LESS_EQUAL,
    GREATER_EQUAL,


    TRUE,
    FALSE,

    STRING,
    CHAR,
    INT,
    DOUBLE,
    IDENTIFIER,

    STRING_TYPE,
    CHAR_TYPE,
    INT_TYPE,
    DOUBLE_TYPE,
    BOOLEAN_TYPE,

    PRINT,
    

    EOF,


}

List<Tokentype> types = [
  Tokentype.INT_TYPE,
  Tokentype.DOUBLE_TYPE,
  Tokentype.BOOLEAN_TYPE,
  Tokentype.CHAR_TYPE,
  Tokentype.STRING_TYPE,
  Tokentype.IDENTIFIER];

Map<String, Tokentype> typeMap={

  "TRUE": Tokentype.TRUE,
  "FALSE": Tokentype.FALSE,

  "string":Tokentype.STRING_TYPE,
  "char":Tokentype.CHAR_TYPE,
  "int":Tokentype.INT_TYPE,
  "double":Tokentype.DOUBLE_TYPE,
  "bool":Tokentype.BOOLEAN_TYPE,

  "print":Tokentype.PRINT
};
