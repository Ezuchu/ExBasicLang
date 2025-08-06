import '../AST/TypeExpr.dart';
import 'ExArrayBase.dart';
import 'ExBool.dart';
import 'ExValue.dart';

class ExArray extends ExArrayBase implements ExValue
{
  @override
  ExType type = ExType.ARRAY;

  TypeExpr? contentType;

  int? maxLenght;

  ExArray(List<ExValue> elements,this.contentType,this.maxLenght) : super(elements);
  

  @override
  ExValue copy() {
    return ExArray(elements, contentType, maxLenght);
  }

  @override
  getValue() {
    return elements;
  }

  @override
  ExBool isEqual(ExValue value) {
    if(!(value is ExArray)) return ExBool(false);

    if(value.elements.length != this.elements.length) return ExBool(false);

    for(int i = 0; i < this.elements.length;i++)
    {
      ExBool isEqual = this.elements[i].isEqual(value.elements[i]);

      if(isEqual.getValue() == false)
      {
        return isEqual;
      }
    }

    return ExBool(true);
  }

  @override
  set(value) {
    elements = value;
  }

}