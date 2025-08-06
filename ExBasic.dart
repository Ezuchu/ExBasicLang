
import 'AST/Expr.dart';
import 'ExError.dart';
import 'Lexer/Lexer.dart';
import 'Parser/Parser.dart';
import 'runtime/interpreter.dart';



void main()
{
    try
    {
      Lexer lexer = Lexer('int caja = 2;caja = 3;print caja;');
      Parser parser = Parser(lexer.scanTokens());
      Interpreter interpreter = Interpreter();

      interpreter.interprete(parser.parse());
    }catch(e)
    {
      print(e);
    }
    
    
}