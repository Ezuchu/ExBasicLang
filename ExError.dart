
bool hadError = false;

List<ExError> errorList = [];

class ExError
{
  final int line;
  final int column;
  final String message;
  final int type;

  ExError(this.line,this.column,this.message,this.type)
  {
    hadError = true;
    errorList.add(this);
  }

  @override
  String toString() {
    switch(type)
    {
      case 1: return("Lexic error at $line:$column: $message");
      case 2: return("Syntactic error at $line:$column: $message");
      case 3: return("Runtime error at $line:$column: $message");
    }
    return"";
  }
}