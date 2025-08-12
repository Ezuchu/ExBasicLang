

import '../value/ExValue.dart';

class Return extends Error
{
  final ExValue value;

  Return(this.value) : super();
}