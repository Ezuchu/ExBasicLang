
import '../ExError.dart';
import '../Token/Token.dart';
import '../Token/TokenType.dart';

abstract class LexerBase 
{
    final List<Token> tokens = [];
    final String source;
    int start = 0;
    int line = 1;
    int column = 1;
    int current = 0;
    String actualChar = "";

    LexerBase(this.source);

    List<Token> scanTokens()
    {
        while(!isAtEnd())
        {
            start = current;
            scanToken();
        }
        tokens.add(Token(Tokentype.EOF, "", null, line, column));
        if(hadError)
        {
          print(errorList);
        }
        return tokens;
    }

    void scanToken();

    void scanChar();

    void scanString();

    void scanNumber();

    void scanIdentifier();

    bool match(String expected)
    {
        if(isAtEnd())return false;
        if(source[current] != expected)return false;

        advance();
        return true;

    }

    void addToken(Tokentype type)
    {
        addLiteralToken(type,null);
    }

    void addLiteralToken(Tokentype type,Object? literal)
    {
        String lexeme = source.substring(start,current);
        tokens.add(Token(type,lexeme,literal,line,column));
    }

    void advance()
    {
        current++;
        column++;
    }

    void nextLine()
    {
        current++;
        line++;
        column = 1;
    }

    void advanceUntilReach(String char)
    {
        while(peek() != char && !isAtEnd()) advance;
    }

    String peek()
    {
        return isAtEnd()? '\0': source[current];
    }

    bool isAtEnd()
    {
        return current >= source.length;
    }



}