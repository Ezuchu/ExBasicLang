
import 'AST/Expr.dart';
import 'Lexer/Lexer.dart';
import 'Parser/Parser.dart';



void main()
{
    Lexer lexer = Lexer('4 * 5 == 6');
    Parser parser = Parser(lexer.scanTokens());
    List<Expression> expressions = parser.parse();

    print(expressions[0]);
}