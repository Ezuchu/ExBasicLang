import '../AST/TypeExpr.dart';
import '../ExError.dart';
import '../Token/Token.dart';
import 'ExArrayBase.dart';
import 'ExBool.dart';
import 'ExValue.dart';

class ExArray extends ExArrayBase implements ExValue
{
  @override
  ExType type = ExType.ARRAY;

  ExType? contentType;

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
  set(ExValue value, Token token) {
    
    if(!(value is ExArray) || value.maxLenght != maxLenght || !this.sameType(value)) throw ExError(token.line, token.column, "incompatible types in assignment",3);

    elements = value.elements;
  }

  bool sameType(ExArray value)
  {
    
    if(value.maxLenght != maxLenght) return false;

    if(value.contentType != null)
    {
      if(contentType != value.contentType) return false;
      if(contentType ==ExType.ARRAY) return sameType(value.elements[0] as ExArray);
    }
    else
    {
      for(int i = 0; i< maxLenght!;i++)
      {
        if(elements[i].type != value.elements[i].type) return false;

        if(elements[i].type == ExType.ARRAY)
        {
          if((elements[i] as ExArray).sameType(value.elements[i] as ExArray)== false) return false;
        }
      }
    }
    return true;
  }

  

}