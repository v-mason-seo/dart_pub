// Copyright (c) 2017, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer_plugin_fork/protocol/protocol_generated.dart';
import 'package:analyzer_plugin_fork/utilities/analyzer_converter.dart';
import 'package:analyzer_plugin_fork/utilities/fixes/fixes.dart';

/**
 * A concrete implementation of [DartFixesRequest].
 */
class DartFixesRequestImpl implements DartFixesRequest {
  @override
  final ResourceProvider resourceProvider;

  @override
  final int offset;

  @override
  final List<AnalysisError> errorsToFix;

  @override
  final ResolvedUnitResult result;

  /**
   * Initialize a newly create request with the given data.
   */
  DartFixesRequestImpl(
      this.resourceProvider, this.offset, this.errorsToFix, this.result);
}

/**
 * A concrete implementation of [FixCollector].
 */
class FixCollectorImpl implements FixCollector {
  /**
   * The list of fixes that have been collected.
   */
  final Map<AnalysisError, List<PrioritizedSourceChange>> fixMap =
      <AnalysisError, List<PrioritizedSourceChange>>{};

  /**
   * Return the fixes that have been collected up to this point.
   */
  List<AnalysisErrorFixes> get fixes {
    List<AnalysisErrorFixes> fixes = <AnalysisErrorFixes>[];
    AnalyzerConverter converter = new AnalyzerConverter();
    for (AnalysisError error in fixMap.keys) {
      fixes.add(new AnalysisErrorFixes(converter.convertAnalysisError(error),
          fixes: fixMap[error]));
    }
    return fixes;
  }

  @override
  void addFix(AnalysisError error, PrioritizedSourceChange change) {
    fixMap.putIfAbsent(error, () => <PrioritizedSourceChange>[]).add(change);
  }
}
