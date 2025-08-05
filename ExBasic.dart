
import 'AST/Expr.dart';
import 'Lexer/Lexer.dart';
import 'Parser/Parser.dart';
import 'runtime/interpreter.dart';



void main()
{
    Lexer lexer = Lexer('int caja = 2; print caja;');
    Parser parser = Parser(lexer.scanTokens());
    Interpreter interpreter = Interpreter();

    interpreter.interprete(parser.parse());
    
}