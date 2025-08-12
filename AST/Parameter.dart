import '../Token/Token.dart';
import 'TypeExpr.dart';

class Parameter {
  final Token name;
  final TypeExpr type;
  
  Parameter(this.name,this.type);
}