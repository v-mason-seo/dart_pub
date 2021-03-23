import 'package:meta/meta.dart';
import 'package:moor/moor.dart';
import 'package:moor/src/runtime/components/component.dart';
import 'package:moor/src/types/sql_types.dart';

/// Any sql expression that evaluates to some generic value. This does not
/// include queries (which might evaluate to multiple values) but individual
/// columns, functions and operators.
abstract class Expression<D, T extends SqlType<D>> implements Component {
  /// Constant constructor so that subclasses can be constant.
  const Expression();

  /// Whether this expression is a literal. Some use-sites need to put
  /// parentheses around non-literals.
  bool get isLiteral => false;

  /// Whether this expression is equal to the given expression.
  Expression<bool, BoolType> equalsExp(Expression<D, T> compare) =>
      Comparison.equal(this, compare);

  /// Whether this column is equal to the given value, which must have a fitting
  /// type. The [compare] value will be written
  /// as a variable using prepared statements, so there is no risk of
  /// an SQL-injection.
  Expression<bool, BoolType> equals(D compare) =>
      Comparison.equal(this, Variable<D, T>(compare));
}

/// An expression that looks like "$a operator $b", where $a and $b itself
/// are expressions and the operator is any string.
abstract class InfixOperator<D, T extends SqlType<D>> extends Expression<D, T> {
  /// The left-hand side of this expression
  Expression get left;

  /// The right-hand side of this expresion
  Expression get right;

  /// The sql operator to write
  String get operator;

  /// Whether we should put parentheses around the [left] and [right]
  /// expressions.
  @visibleForOverriding
  bool get placeBrackets => true;

  @override
  void writeInto(GenerationContext context) {
    _placeBracketIfNeeded(context, true);

    left.writeInto(context);

    _placeBracketIfNeeded(context, false);
    context.writeWhitespace();
    context.buffer.write(operator);
    context.writeWhitespace();
    _placeBracketIfNeeded(context, true);

    right.writeInto(context);

    _placeBracketIfNeeded(context, false);
  }

  void _placeBracketIfNeeded(GenerationContext context, bool open) {
    if (placeBrackets) context.buffer.write(open ? '(' : ')');
  }
}

/// Defines the possible comparison operators that can appear in a [Comparison].
enum ComparisonOperator {
  /// '<' in sql
  less,

  /// '<=' in sql
  lessOrEqual,

  /// '=' in sql
  equal,

  /// '>=' in sql
  moreOrEqual,

  /// '>' in sql
  more
}

/// An expression that compares two child expressions.
class Comparison extends InfixOperator<bool, BoolType> {
  static const Map<ComparisonOperator, String> _operatorNames = {
    ComparisonOperator.less: '<',
    ComparisonOperator.lessOrEqual: '<=',
    ComparisonOperator.equal: '=',
    ComparisonOperator.moreOrEqual: '>=',
    ComparisonOperator.more: '>'
  };

  @override
  final Expression left;
  @override
  final Expression right;

  /// The operator to use for this comparison
  final ComparisonOperator op;

  @override
  final bool placeBrackets = false;

  @override
  String get operator => _operatorNames[op];

  /// Constructs a comparison from the [left] and [right] expressions to compare
  /// and the [ComparisonOperator] [op].
  Comparison(this.left, this.op, this.right);

  /// Like [Comparison(left, op, right)], but uses [ComparisonOperator.equal].
  Comparison.equal(this.left, this.right) : op = ComparisonOperator.equal;
}
