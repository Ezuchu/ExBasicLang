import 'dart:io';

import 'Lexer/Lexer.dart';
import 'Parser/Parser.dart';
import 'runtime/interpreter.dart';



void main()
{
    try
    {
      String source = File("Example/example.exb").readAsStringSync();
      Lexer lexer = Lexer(source);
      Parser parser = Parser(lexer.scanTokens());
      
      Interpreter interpreter = Interpreter();
      
      interpreter.interprete(parser.parse());
    }catch(e)
    {
      print(e);
    }
    
    
}