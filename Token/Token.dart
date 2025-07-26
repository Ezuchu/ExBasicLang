import 'TokenType.dart';


class Token 
{
    final Tokentype type;
    final String lexeme;
    final Object? literal;
    final int line;
    final int column;

    Token(this.type,this.lexeme,this.literal,this.line,this.column);

    @override
    String toString() {
      return "$line $column $type $lexeme $literal";
    }
}

