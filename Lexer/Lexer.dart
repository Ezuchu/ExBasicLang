
import '../ExError.dart';
import '../Token/TokenType.dart';
import 'LexerBase.dart';

class Lexer extends LexerBase
{
    Lexer(super.source);
    
    void scanToken()
    {
        actualChar = source[start];
        switch(actualChar)
        {
            case ' ':
            case '\t':
            case '\r':
              advance();break;

            case '\n':
              nextLine();break;


            case '(': advance();addToken(Tokentype.LEFT_PAREN);break;
            case ')': advance();addToken(Tokentype.RIGHT_PAREN);break;
            case '}': advance();addToken(Tokentype.RIGHT_BRACE);break;
            case '{': advance();addToken(Tokentype.LEFT_BRACE);break;
            case '[': advance();addToken(Tokentype.LEFT_BRACKET);break;
            case ']': advance();addToken(Tokentype.RIGHT_BRACKET);break;

            case '.': advance();addToken(Tokentype.DOT);break;
            case ',': advance();addToken(Tokentype.COMMA);break;
            case ';': advance();addToken(Tokentype.SEMICOLON);break;

            case '+':advance();addToken(match('+')? Tokentype.PLUS_PLUS : Tokentype.PLUS);break;
              
            case '-':advance();addToken(match('-')?Tokentype.MINUS_MINUS : Tokentype.MINUS);break;
            
            case '*':advance();addToken(Tokentype.STAR);break;

            case '&':advance();
              if(!match('&')) throw ExError(line, column, 'incompleted symbol', 1);
              addToken(Tokentype.AND);break;

            case '|':advance();
              if(!match('|')) throw ExError(line, column, 'incompleted symbol', 1);
              addToken(Tokentype.OR);break;


            case '\'': advance();scanChar();break;
            case '\"': advance();scanString();break;

            case '/':advance();
              if(match('/'))
              {
                  advanceUntilReach('\n');
              }else
              {
                addToken(Tokentype.SLASH);
              }
              break;

            case '!':advance();addToken(match('=')? Tokentype.BANG_EQUAL : Tokentype.BANG);break;
            case '=':advance();addToken(match('=')? Tokentype.EQUAL_EQUAL : Tokentype.EQUAL);break;
            case '<':advance();addToken(match('=')? Tokentype.LESS_EQUAL : Tokentype.LESS);break;
            case '>':advance();addToken(match('=')? Tokentype.GREATER_EQUAL : Tokentype.GREATER);break;

            default:
              if(int.tryParse(actualChar)!= null)
              {
                scanNumber();
              }else if(RegExp(r'[a-zñA-ZÑ_]').hasMatch(actualChar))
              {
                scanIdentifier();
              }
        }
    }

    void scanChar()
    {
      String value = '';
      if(peek()!='\''&&!isAtEnd())
      {
        value += source[current];
        advance();
      }

      if(peek()!='\'' && isAtEnd())
      {
        new ExError(line, column, 'Undeterminated Char', 1);
      }

      advance();

      addLiteralToken(Tokentype.CHAR, value);
    }

    void scanString()
    {
        String value = "";
        while (peek() != '\"' && !isAtEnd()) {
          if (peek() == '\n') line++;
          value += source[current];
          advance();
        }

        if(isAtEnd())
        {
          new ExError(line, column, 'Undeterminated string', 1);
          return;
        }

        advance();

        
        addLiteralToken(Tokentype.STRING, value);

    }

    void scanNumber()
    {
      String value= sumNumber();
      
      if(peek() == '.')
      {
        value += '.';
        advance();
        if(int.tryParse(peek())== null || isAtEnd())
        {
          new ExError(line,column,'undeterminated float number', 1);
          return;
        }
        value += sumNumber();

        double doubleValue = double.parse(value);
        addLiteralToken(Tokentype.DOUBLE, doubleValue);
      }else
      {
        int intValue = int.parse(value);
        addLiteralToken(Tokentype.INT, intValue);
      }

      

    }

    String sumNumber()
    {
      String value = "";
      while(int.tryParse(peek()) != null && !isAtEnd())
      {
        value += source[current];
        advance();
      }
      return value;
    }

    void scanIdentifier()
    {
      String name = "";
      while(RegExp(r'[a-zñA-ZÑ_0-9]').hasMatch(peek()) && !isAtEnd())
      {
        name += source[current];
        advance();
      }

      if(typeMap.containsKey(name))
      {
        addToken(typeMap[name]!);
      }else
      {
        addLiteralToken(Tokentype.IDENTIFIER, name);
      }
    }

}