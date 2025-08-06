
import 'AST/Expr.dart';
import 'ExError.dart';
import 'Lexer/Lexer.dart';
import 'Parser/Parser.dart';
import 'runtime/interpreter.dart';



void main()
{
    try
    {
      Lexer lexer = Lexer('print [1,[3,4],3];');
      Parser parser = Parser(lexer.scanTokens());
      Interpreter interpreter = Interpreter();

      interpreter.interprete(parser.parse());
    }catch(e)
    {
      print(e);
    }
    
    
}