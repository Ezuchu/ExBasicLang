enum Tokentype 
{
    START,
    END,

    IF,
    ELSE,
    WHILE,
    FOR,
    DO,
    UNTIL,

    RETURN,


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

    PLUS_PLUS,
    MINUS_MINUS,

    AND,
    OR,

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
    ARRAY_TYPE,
    VOID_TYPE,

    THIS,
    EXTENDS,

    STRUCT,
    CLASS,

    PRINT,
    

    EOF,

}

List<Tokentype> types = [
  Tokentype.INT_TYPE,
  Tokentype.DOUBLE_TYPE,
  Tokentype.BOOLEAN_TYPE,
  Tokentype.CHAR_TYPE,
  Tokentype.STRING_TYPE,
  Tokentype.ARRAY_TYPE,
  Tokentype.IDENTIFIER,
  Tokentype.VOID_TYPE];

Map<String, Tokentype> typeMap={

  "START": Tokentype.START,
  "END" : Tokentype.END,

  "if" : Tokentype.IF,
  "else" : Tokentype.ELSE,
  "while" : Tokentype.WHILE,
  "for" :Tokentype.FOR,
  "do" : Tokentype.DO,
  "until" : Tokentype.UNTIL,

  "return" : Tokentype.RETURN,

  "TRUE": Tokentype.TRUE,
  "FALSE": Tokentype.FALSE,

  "string":Tokentype.STRING_TYPE,
  "char":Tokentype.CHAR_TYPE,
  "int":Tokentype.INT_TYPE,
  "double":Tokentype.DOUBLE_TYPE,
  "bool":Tokentype.BOOLEAN_TYPE,
  "Array":Tokentype.ARRAY_TYPE,
  "void": Tokentype.VOID_TYPE,

  "this": Tokentype.THIS,
  "extends": Tokentype.EXTENDS,

  "struct" : Tokentype.STRUCT,
  "class" : Tokentype.CLASS,

  "print":Tokentype.PRINT
};
