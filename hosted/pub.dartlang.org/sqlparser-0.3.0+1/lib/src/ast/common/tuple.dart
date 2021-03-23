part of '../ast.dart';

/// A tuple of values, denotes in brackets. `(<expr>, ..., <expr>)`.
///
/// Notice that this class extends [Expression] because the type inference
/// algorithm works best when tuples are treated as expressions. Syntactically,
/// tuples aren't expressions.
class Tuple extends Expression {
  /// The expressions appearing in this tuple.
  final List<Expression> expressions;

  Tuple({@required this.expressions});

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitTuple(this);

  @override
  Iterable<AstNode> get childNodes => expressions;

  @override
  bool contentEquals(Tuple other) => true;
}
