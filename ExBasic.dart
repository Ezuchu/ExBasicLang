
import 'AST/Expr.dart';
import 'Lexer/Lexer.dart';
import 'Parser/Parser.dart';
import 'runtime/interpreter.dart';



void main()
{
    Lexer lexer = Lexer('1 / 2.5');
    Parser parser = Parser(lexer.scanTokens());
    List<Expression> expressions = parser.parse();
    Interpreter interpreter = Interpreter();

    print(interpreter.evaluate(expressions[0]));
    
}