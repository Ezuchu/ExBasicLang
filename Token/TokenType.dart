enum Tokentype 
{
    LEFT_BRACE,
    RIGHT_BRACE,
    LEFT_PAREN,
    RIGHT_PAREN,
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
