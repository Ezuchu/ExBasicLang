
import 'Lexer/Lexer.dart';



void main()
{
    Lexer lexer = Lexer('taladro \'x\' \n "saco" 12 24.5');
    print(lexer.scanTokens());
}