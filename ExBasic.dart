import 'dart:io';

import 'AST/Stmt.dart';
import 'Lexer/Lexer.dart';
import 'Parser/Parser.dart';
import 'Resolver/resolver.dart';
import 'runtime/Interpreter.dart';



void main()
{
    try
    {
      String source = File("Example/example.exb").readAsStringSync();
      Lexer lexer = Lexer(source);
      Parser parser = Parser(lexer.scanTokens());
      
      List<Statement> statements = parser.parse();

      Interpreter interpreter = Interpreter();
      Resolver resolver = Resolver(interpreter);
      resolver.resolveList(statements);
      interpreter.interprete(statements);

      
    }catch(e)
    {
      print(e);
    }
    
    
}