import '../runtime/Interpreter.dart';
import 'ExValue.dart';

abstract class ExCallable extends ExValue
 {
    ExValue call(Interpreter interpreter,List<ExValue> arguments);
 }