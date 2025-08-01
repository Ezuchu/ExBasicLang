
import 'AST/Expr.dart';
import 'Lexer/Lexer.dart';
import 'Parser/Parser.dart';
import 'runtime/interpreter.dart';



void main()
{
    Lexer lexer = Lexer('print 4+6;');
    Parser parser = Parser(lexer.scanTokens());
    Interpreter interpreter = Interpreter();

    interpreter.interprete(parser.parse());
    
}