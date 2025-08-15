import 'TypeExpr.dart';

class ExSymbol {
  final String name;
  late bool state;
  final TypeExpr type;

  ExSymbol(this.name,this.state,this.type);
}