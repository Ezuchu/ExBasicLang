

import '../ExError.dart';
import '../Token/Token.dart';
import 'ExDouble.dart';
import 'ExInt.dart';
import 'ExValue.dart';

class ExArrayBase
{
  List<ExValue> elements = [];

  ExArrayBase(this.elements);

  ExValue getIndex(ExInt index,Token reference)
  {
    if(index.getValue() > elements.length || index.getValue() < 0)
    {
      throw ExError(reference.line, reference.column, "referenced a element outside of array limits", 3);
    }

    return elements[index.getValue()];
  }

  @override
  String toString() {
    return elements.toString();
  }

}