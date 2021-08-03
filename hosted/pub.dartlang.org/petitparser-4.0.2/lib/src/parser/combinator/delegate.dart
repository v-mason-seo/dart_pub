import '../../core/parser.dart';

/// An abstract parser that delegates to another one.
abstract class DelegateParser<T> extends Parser<T> {
  Parser delegate;

  DelegateParser(this.delegate);

  @override
  List<Parser> get children => [delegate];

  @override
  void replace(Parser source, Parser target) {
    super.replace(source, target);
    if (delegate == source) {
      delegate = target;
    }
  }
}
