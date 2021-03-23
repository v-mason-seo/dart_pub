// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/type_provider.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/src/dart/ast/ast.dart';
import 'package:analyzer/src/dart/ast/token.dart';
import 'package:analyzer/src/dart/element/element.dart';
import 'package:analyzer/src/dart/element/type.dart';
import 'package:analyzer/src/dart/element/type_system.dart';
import 'package:analyzer/src/dart/resolver/flow_analysis_visitor.dart';
import 'package:analyzer/src/dart/resolver/invocation_inference_helper.dart';
import 'package:analyzer/src/dart/resolver/resolution_result.dart';
import 'package:analyzer/src/dart/resolver/type_property_resolver.dart';
import 'package:analyzer/src/error/codes.dart';
import 'package:analyzer/src/error/nullable_dereference_verifier.dart';
import 'package:analyzer/src/generated/migration.dart';
import 'package:analyzer/src/generated/resolver.dart';
import 'package:analyzer/src/task/strong/checker.dart';
import 'package:meta/meta.dart';

/// Helper for resolving [AssignmentExpression]s.
class AssignmentExpressionResolver {
  final ResolverVisitor _resolver;
  final FlowAnalysisHelper _flowAnalysis;
  final TypePropertyResolver _typePropertyResolver;
  final InvocationInferenceHelper _inferenceHelper;
  final AssignmentExpressionShared _assignmentShared;

  AssignmentExpressionResolver({
    @required ResolverVisitor resolver,
    @required FlowAnalysisHelper flowAnalysis,
  })  : _resolver = resolver,
        _flowAnalysis = flowAnalysis,
        _typePropertyResolver = resolver.typePropertyResolver,
        _inferenceHelper = resolver.inferenceHelper,
        _assignmentShared = AssignmentExpressionShared(
          resolver: resolver,
          flowAnalysis: flowAnalysis,
        );

  ErrorReporter get _errorReporter => _resolver.errorReporter;

  bool get _isNonNullableByDefault => _typeSystem.isNonNullableByDefault;

  MigrationResolutionHooks get _migrationResolutionHooks {
    return _resolver.migrationResolutionHooks;
  }

  NullableDereferenceVerifier get _nullableDereferenceVerifier =>
      _resolver.nullableDereferenceVerifier;

  TypeProvider get _typeProvider => _resolver.typeProvider;

  TypeSystemImpl get _typeSystem => _resolver.typeSystem;

  void resolve(AssignmentExpressionImpl node) {
    var left = node.leftHandSide;
    var right = node.rightHandSide;

    // Case `id = e`.
    // Consider an assignment of the form `id = e`, where `id` is an identifier.
    if (left is SimpleIdentifier) {
      _resolve_SimpleIdentifier(node, left);
      return;
    }

    left?.accept(_resolver);
    left = node.leftHandSide;

    var operator = node.operator.type;
    if (operator != TokenType.EQ) {
      if (node.readElement == null || node.readType == null) {
        _resolver.setReadElement(left, null);
      }
    }
    if (node.writeElement == null || node.writeType == null) {
      _resolver.setWriteElement(left, null);
    }

    _resolve1(node);
    _setRhsContext(node, left.staticType);

    _flowAnalysis?.assignmentExpression(node);

    if (operator != TokenType.EQ &&
        operator != TokenType.QUESTION_QUESTION_EQ) {
      _nullableDereferenceVerifier.expression(left);
    }

    right?.accept(_resolver);
    right = node.rightHandSide;

    _resolve2(node);

    _flowAnalysis?.assignmentExpression_afterRight(node);
  }

  /// Set the static type of [node] to be the least upper bound of the static
  /// types of subexpressions [expr1] and [expr2].
  ///
  /// TODO(scheglov) this is duplicate
  void _analyzeLeastUpperBound(
      Expression node, Expression expr1, Expression expr2) {
    DartType staticType1 = getReadType(expr1);
    DartType staticType2 = getReadType(expr2);

    _analyzeLeastUpperBoundTypes(node, staticType1, staticType2);
  }

  /// Set the static type of [node] to be the least upper bound of the static
  /// types [staticType1] and [staticType2].
  ///
  /// TODO(scheglov) this is duplicate
  void _analyzeLeastUpperBoundTypes(
      Expression node, DartType staticType1, DartType staticType2) {
    // TODO(brianwilkerson) Determine whether this can still happen.
    staticType1 ??= DynamicTypeImpl.instance;

    // TODO(brianwilkerson) Determine whether this can still happen.
    staticType2 ??= DynamicTypeImpl.instance;

    DartType staticType =
        _typeSystem.getLeastUpperBound(staticType1, staticType2) ??
            DynamicTypeImpl.instance;

    staticType = _resolver.toLegacyTypeIfOptOut(staticType);

    _inferenceHelper.recordStaticType(node, staticType);
  }

  void _checkForInvalidAssignment(
    DartType expectedLeftType,
    Expression right,
    DartType assignedType,
  ) {
    if (expectedLeftType == null) {
      return;
    }

    if (!expectedLeftType.isVoid && _checkForUseOfVoidResult(right)) {
      return;
    }

    if (_typeSystem.isAssignableTo2(assignedType, expectedLeftType)) {
      return;
    }

    _errorReporter.reportErrorForNode(
      CompileTimeErrorCode.INVALID_ASSIGNMENT,
      right,
      [assignedType, expectedLeftType],
    );
  }

  /// Check for situations where the result of a method or function is used,
  /// when it returns 'void'. Or, in rare cases, when other types of expressions
  /// are void, such as identifiers.
  ///
  /// See [StaticWarningCode.USE_OF_VOID_RESULT].
  /// TODO(scheglov) this is duplicate
  bool _checkForUseOfVoidResult(Expression expression) {
    if (expression == null ||
        !identical(expression.staticType, VoidTypeImpl.instance)) {
      return false;
    }

    if (expression is MethodInvocation) {
      SimpleIdentifier methodName = expression.methodName;
      _errorReporter.reportErrorForNode(
          CompileTimeErrorCode.USE_OF_VOID_RESULT, methodName, []);
    } else {
      _errorReporter.reportErrorForNode(
          CompileTimeErrorCode.USE_OF_VOID_RESULT, expression, []);
    }

    return true;
  }

  DartType _getExpectedLeftType(
    SimpleIdentifier leftIdentifier,
    Element leftElement,
  ) {
    if (leftElement is VariableElement) {
      return leftElement.type;
      // return _resolver.localVariableTypeProvider.getType(leftIdentifier);
    } else if (leftElement is PropertyAccessorElement && leftElement.isSetter) {
      if (leftElement.isSynthetic) {
        return leftElement.variable.type;
      } else {
        var parameters = leftElement.parameters;
        if (parameters.isNotEmpty) {
          return parameters[0].type;
        }
      }
    }
    return null;
  }

  /// Gets the definite type of expression, which can be used in cases where
  /// the most precise type is desired, for example computing the least upper
  /// bound.
  ///
  /// See [getExpressionType] for more information. Without strong mode, this is
  /// equivalent to [_getStaticType].
  ///
  /// TODO(scheglov) this is duplicate
  DartType _getExpressionType(Expression expr, {bool read = false}) =>
      getExpressionType(expr, _typeSystem, _typeProvider, read: read);

  DartType _getLeftType(Expression node, Element element) {
    if (element is VariableElement) {
      var identifier = node as Identifier;
      return _resolver.localVariableTypeProvider.getType(identifier);
    } else if (element is PropertyAccessorElement && element.isSetter) {
      if (element.isSynthetic) {
        return element.variable.type;
      } else {
        var parameters = element.parameters;
        if (parameters.isNotEmpty) {
          return parameters[0].type;
        }
      }
    }
    return null;
  }

  /// Return the static type of the given [expression] that is to be used for
  /// type analysis.
  ///
  /// TODO(scheglov) this is duplicate
  DartType _getStaticType1(Expression expression, {bool read = false}) {
    if (expression is NullLiteral) {
      return _typeProvider.nullType;
    }
    DartType type = read ? getReadType(expression) : expression.staticType;
    return _resolveTypeParameter(type);
  }

  /// Return the static type of the given [expression].
  ///
  /// TODO(scheglov) this is duplicate
  DartType _getStaticType2(Expression expression, {bool read = false}) {
    DartType type;
    if (read) {
      type = getReadType(expression);
    } else {
      if (expression is SimpleIdentifier && expression.inSetterContext()) {
        var element = expression.staticElement;
        if (element is PromotableElement) {
          // We're writing to the element so ignore promotions.
          type = element.type;
        } else {
          type = expression.staticType;
        }
      } else {
        type = expression.staticType;
      }
    }
    if (type == null) {
      // TODO(brianwilkerson) Determine the conditions for which the static type
      // is null.
      return DynamicTypeImpl.instance;
    }
    return type;
  }

  /// Return the non-nullable variant of the [type] if null safety is enabled,
  /// otherwise return the type itself.
  ///
  // TODO(scheglov) this is duplicate
  DartType _nonNullable(DartType type) {
    if (_isNonNullableByDefault) {
      return _typeSystem.promoteToNonNull(type);
    }
    return type;
  }

  /// Record that the static type of the given node is the given type.
  ///
  /// @param expression the node whose type is to be recorded
  /// @param type the static type of the node
  ///
  /// TODO(scheglov) this is duplication
  void _recordStaticType(Expression expression, DartType type) {
    if (_resolver.migrationResolutionHooks != null) {
      // TODO(scheglov) type cannot be null
      type = _migrationResolutionHooks.modifyExpressionType(
        expression,
        type ?? DynamicTypeImpl.instance,
      );
    }

    // TODO(scheglov) type cannot be null
    if (type == null) {
      expression.staticType = DynamicTypeImpl.instance;
    } else {
      expression.staticType = type;
      if (_typeSystem.isBottom(type)) {
        _flowAnalysis?.flow?.handleExit();
      }
    }
  }

  void _reportNotSetter(
    Expression left,
    Element requested,
    Element recovery,
  ) {
    if (requested != null) {
      if (requested is VariableElement) {
        if (requested.isConst) {
          _errorReporter.reportErrorForNode(
            CompileTimeErrorCode.ASSIGNMENT_TO_CONST,
            left,
          );
        } else if (requested.isFinal) {
          if (_isNonNullableByDefault) {
            // Handled during resolution, with flow analysis.
          } else {
            _errorReporter.reportErrorForNode(
              CompileTimeErrorCode.ASSIGNMENT_TO_FINAL_LOCAL,
              left,
              [requested.name],
            );
          }
        }
      }
      return;
    }

    if (recovery is ClassElement ||
        recovery is DynamicElementImpl ||
        recovery is FunctionTypeAliasElement ||
        recovery is TypeParameterElement) {
      _errorReporter.reportErrorForNode(
        CompileTimeErrorCode.ASSIGNMENT_TO_TYPE,
        left,
      );
    } else if (recovery is FunctionElement) {
      _errorReporter.reportErrorForNode(
        CompileTimeErrorCode.ASSIGNMENT_TO_FUNCTION,
        left,
      );
    } else if (recovery is MethodElement) {
      _errorReporter.reportErrorForNode(
        CompileTimeErrorCode.ASSIGNMENT_TO_METHOD,
        left,
      );
    } else if (recovery is PrefixElement) {
      _errorReporter.reportErrorForNode(
        CompileTimeErrorCode.PREFIX_IDENTIFIER_NOT_FOLLOWED_BY_DOT,
        left,
        [recovery.name],
      );
    } else if (recovery is PropertyAccessorElement && recovery.isGetter) {
      var variable = recovery.variable;
      if (variable.isConst) {
        _errorReporter.reportErrorForNode(
          CompileTimeErrorCode.ASSIGNMENT_TO_CONST,
          left,
        );
      } else if (variable.isFinal && !variable.isLate) {
        if (variable is FieldElement) {
          if (variable.setter == null && variable.isSynthetic) {
            _errorReporter.reportErrorForNode(
              CompileTimeErrorCode.ASSIGNMENT_TO_FINAL_NO_SETTER,
              left,
              [variable.name, variable.enclosingElement.displayName],
            );
          } else {
            _errorReporter.reportErrorForNode(
              CompileTimeErrorCode.ASSIGNMENT_TO_FINAL,
              left,
              [variable.name],
            );
          }
          return;
        }
        _errorReporter.reportErrorForNode(
          CompileTimeErrorCode.ASSIGNMENT_TO_FINAL_LOCAL,
          left,
          [variable.name],
        );
      }
    } else {
      if (left is SimpleIdentifier && !left.isSynthetic) {
        _errorReporter.reportErrorForNode(
          CompileTimeErrorCode.UNDEFINED_IDENTIFIER,
          left,
          [left.name],
        );
      }
    }
  }

  void _resolve1(AssignmentExpressionImpl node) {
    Token operator = node.operator;
    TokenType operatorType = operator.type;
    Expression leftHandSide = node.leftHandSide;

    var leftType = getReadType(leftHandSide);
    leftType = _resolveTypeParameter(leftType);

    if (identical(leftType, NeverTypeImpl.instance)) {
      return;
    }

    _assignmentShared.checkFinalAlreadyAssigned(leftHandSide);

    // For any compound assignments to a void or nullable variable, report it.
    // Example: `y += voidFn()`, not allowed.
    if (operatorType != TokenType.EQ) {
      if (leftType != null && leftType.isVoid) {
        _errorReporter.reportErrorForToken(
          CompileTimeErrorCode.USE_OF_VOID_RESULT,
          operator,
        );
        return;
      }
    }

    if (operatorType != TokenType.AMPERSAND_AMPERSAND_EQ &&
        operatorType != TokenType.BAR_BAR_EQ &&
        operatorType != TokenType.EQ &&
        operatorType != TokenType.QUESTION_QUESTION_EQ) {
      operatorType = operatorFromCompoundAssignment(operatorType);
      if (leftHandSide != null) {
        String methodName = operatorType.lexeme;
        // TODO(brianwilkerson) Change the [methodNameNode] from the left hand
        //  side to the operator.
        var result = _typePropertyResolver.resolve(
          receiver: leftHandSide,
          receiverType: leftType,
          name: methodName,
          receiverErrorNode: leftHandSide,
          nameErrorNode: leftHandSide,
        );
        node.staticElement = result.getter;
        if (_shouldReportInvalidMember(leftType, result)) {
          _errorReporter.reportErrorForToken(
            CompileTimeErrorCode.UNDEFINED_OPERATOR,
            operator,
            [methodName, leftType],
          );
        }
      }
    }
  }

  void _resolve2(AssignmentExpressionImpl node) {
    TokenType operator = node.operator.type;
    if (operator == TokenType.EQ) {
      var rightType = node.rightHandSide.staticType;
      _inferenceHelper.recordStaticType(node, rightType);
    } else if (operator == TokenType.QUESTION_QUESTION_EQ) {
      if (_isNonNullableByDefault) {
        // The static type of a compound assignment using ??= with NNBD is the
        // least upper bound of the static types of the LHS and RHS after
        // promoting the LHS/ to non-null (as we know its value will not be used
        // if null)
        _analyzeLeastUpperBoundTypes(
            node,
            _typeSystem.promoteToNonNull(getReadType(node.leftHandSide)),
            getReadType(node.rightHandSide));
      } else {
        // The static type of a compound assignment using ??= before NNBD is the
        // least upper bound of the static types of the LHS and RHS.
        _analyzeLeastUpperBound(node, node.leftHandSide, node.rightHandSide);
      }
    } else if (operator == TokenType.AMPERSAND_AMPERSAND_EQ ||
        operator == TokenType.BAR_BAR_EQ) {
      _inferenceHelper.recordStaticType(
          node, _nonNullable(_typeProvider.boolType));
    } else {
      var rightType = node.rightHandSide.staticType;

      var leftReadType = getReadType(node.leftHandSide);
      if (identical(leftReadType, NeverTypeImpl.instance)) {
        _inferenceHelper.recordStaticType(node, rightType);
        return;
      }

      var operatorElement = node.staticElement;
      var type = operatorElement?.returnType ?? DynamicTypeImpl.instance;
      type = _typeSystem.refineBinaryExpressionType(
        leftReadType,
        operator,
        rightType,
        type,
        operatorElement,
      );
      _inferenceHelper.recordStaticType(node, type);

      var leftWriteType = _getWriteType(node.leftHandSide);
      if (!_typeSystem.isAssignableTo2(type, leftWriteType)) {
        _resolver.errorReporter.reportErrorForNode(
          CompileTimeErrorCode.INVALID_ASSIGNMENT,
          node.rightHandSide,
          [type, leftWriteType],
        );
      }
    }
    _resolver.nullShortingTermination(node);
  }

  void _resolve_SimpleIdentifier(
    AssignmentExpressionImpl node,
    SimpleIdentifier left,
  ) {
    var operator = node.operator.type;

    // left.staticElement = leftElement;
    // if (operator != TokenType.EQ) {
    //   _resolver.setReadElement(left, leftElement);
    // }
    // _resolver.setWriteElement(left, leftElement);

    var leftType = _resolver.localVariableTypeProvider.getType(left);
    // TODO(scheglov) Set the type only when `operator != TokenType.EQ`.
    _recordStaticType(left, leftType);

    // TODO(scheglov) But where do we set the element?
    // Especially when `left` is not just a simple identifier.
    // Here it is, but what about a general case?
    if (operator != TokenType.EQ) {
      var readLookup = _resolver.lexicalLookup(node: left, setter: false);
      _setLeftReadType(left, readLookup.requested);
    }

    var leftLookup = _resolver.lexicalLookup(node: left, setter: true);
    _reportNotSetter(left, leftLookup.requested, leftLookup.recovery);

    var leftElement = leftLookup.requested;
    left.staticElement = leftElement ?? leftLookup.recovery;

    // if (operator == TokenType.EQ ||
    //     operator == TokenType.QUESTION_QUESTION_EQ) {
    //   var expectedLeftType = _getExpectedLeftType0(left, leftElement);
    //   InferenceContext.setType(right, expectedLeftType);
    // }

    var expectedLeftType = _getExpectedLeftType(left, leftElement);

    _resolve1(node);
    _setRhsContext(node, _getLeftType(left, leftElement));

    // // When the lexical lookup yields a local variable `v`.
    // if (leftElement is VariableElement) {
    //   _resolve_SimpleIdentifier_LocalVariable(node, left, leftElement);
    //   var right = node.rightHandSide;
    //   if (operator == TokenType.EQ ||
    //       operator == TokenType.QUESTION_QUESTION_EQ) {
    //     _checkForInvalidAssignment(expectedLeftType, right, right.staticType);
    //   } else {
    //     _checkForInvalidAssignment(expectedLeftType, right, node.staticType);
    //   }
    //   return;
    // }

    // TODO(scheglov)
    if (operator != TokenType.EQ) {
      _resolver.checkReadOfNotAssignedLocalVariable(left);
    }

    var flow = _flowAnalysis?.flow;
    if (flow != null && operator == TokenType.QUESTION_QUESTION_EQ) {
      flow.ifNullExpression_rightBegin(left);
    }

    node.rightHandSide.accept(_resolver);
    var right = node.rightHandSide;

    _resolve2(node);

    // /// TODO(scheglov) Remove after inlining these checks into here.
    // left.setProperty(CodeChecker.assignmentReadTypeKey, expectedLeftType);

    if (operator == TokenType.EQ ||
        operator == TokenType.QUESTION_QUESTION_EQ) {
      _checkForInvalidAssignment(expectedLeftType, right, right.staticType);
    } else {
      _checkForInvalidAssignment(expectedLeftType, right, node.staticType);
    }

    if (flow != null) {
      if (leftElement is VariableElement) {
        flow.write(leftElement, node.staticType);
      }
      if (node.operator.type == TokenType.QUESTION_QUESTION_EQ) {
        flow.ifNullExpression_end();
      }
    }
  }

  /// If the given [type] is a type parameter, resolve it to the type that
  /// should be used when looking up members. Otherwise, return the original
  /// type.
  // TODO(scheglov) this is duplicate
  DartType _resolveTypeParameter(DartType type) =>
      type?.resolveToBound(_typeProvider.objectType);

  void _setLeftReadType(Expression left, Element element) {
    if (element is VariableElement) {
      var type = _resolver.localVariableTypeProvider.getType(left);
      _recordStaticType(left, type);
    } else if (element is PropertyAccessorElement && element.isGetter) {
      var type = element.returnType;
      _recordStaticType(left, type);
    } else {
      var type = DynamicTypeImpl.instance;
      _recordStaticType(left, type);
    }
  }

  void _setRhsContext(AssignmentExpressionImpl node, DartType leftType) {
    switch (node.operator.type) {
      case TokenType.EQ:
      case TokenType.QUESTION_QUESTION_EQ:
        InferenceContext.setType(node.rightHandSide, leftType);
        break;
      case TokenType.AMPERSAND_AMPERSAND_EQ:
      case TokenType.BAR_BAR_EQ:
        InferenceContext.setType(node.rightHandSide, _typeProvider.boolType);
        break;
      default:
        var method = node.staticElement;
        if (method != null) {
          var parameters = method.parameters;
          if (parameters.isNotEmpty) {
            InferenceContext.setType(
                node.rightHandSide,
                _typeSystem.refineNumericInvocationContext(
                    leftType, method, leftType, parameters[0].type));
          }
        }
        break;
    }
  }

  /// Return `true` if we should report an error for the lookup [result] on
  /// the [type].
  // TODO(scheglov) this is duplicate
  bool _shouldReportInvalidMember(DartType type, ResolutionResult result) {
    if (result.isNone && type != null && !type.isDynamic) {
      if (_typeSystem.isNonNullableByDefault &&
          _typeSystem.isPotentiallyNullable(type)) {
        return false;
      }
      return true;
    }
    return false;
  }

  /// The type of the RHS assigned to [left] must be subtype of the return.
  static DartType _getWriteType(Expression left) {
    // We are writing, so ignore promotions.
    if (left is SimpleIdentifier) {
      var element = left.staticElement;
      if (element is PromotableElement) {
        return element.type;
      }
    }

    return left.staticType;
  }
}

class AssignmentExpressionShared {
  final ResolverVisitor _resolver;
  final FlowAnalysisHelper _flowAnalysis;

  AssignmentExpressionShared({
    @required ResolverVisitor resolver,
    @required FlowAnalysisHelper flowAnalysis,
  })  : _resolver = resolver,
        _flowAnalysis = flowAnalysis;

  ErrorReporter get _errorReporter => _resolver.errorReporter;

  void checkFinalAlreadyAssigned(Expression left) {
    var flow = _flowAnalysis?.flow;
    if (flow != null && left is SimpleIdentifier) {
      var element = left.staticElement;
      if (element is VariableElement) {
        var assigned = _flowAnalysis.isDefinitelyAssigned(left, element);
        var unassigned = _flowAnalysis.isDefinitelyUnassigned(left, element);

        if (element.isFinal) {
          if (element.isLate) {
            if (assigned) {
              _errorReporter.reportErrorForNode(
                CompileTimeErrorCode.LATE_FINAL_LOCAL_ALREADY_ASSIGNED,
                left,
              );
            }
          } else {
            if (!unassigned) {
              _errorReporter.reportErrorForNode(
                CompileTimeErrorCode.ASSIGNMENT_TO_FINAL_LOCAL,
                left,
                [element.name],
              );
            }
          }
        }
      }
    }
  }
}
