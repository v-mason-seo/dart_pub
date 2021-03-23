part of '../steps.dart';

/// Analyzes the compiled queries found in a Dart file.
class AnalyzeDartStep extends AnalyzingStep {
  AnalyzeDartStep(Task task, FoundFile file) : super(task, file);

  void analyze() {
    final parseResult = file.currentResult as ParsedDartFile;

    for (var accessor in parseResult.dbAccessors) {
      final transitiveImports = _transitiveImports(accessor.resolvedImports);

      var availableTables = _availableTables(transitiveImports)
          .followedBy(accessor.tables)
          .toList();

      try {
        availableTables = sortTablesTopologically(availableTables);
      } on CircularReferenceException catch (e) {
        final msg = StringBuffer(
            'Found a circular reference in your database. This can cause '
            'exceptions at runtime when opening the database. This is the '
            'cycle that we found: ');

        msg.write(e.affected.map((t) => t.displayName).join(' -> '));
        // the last table in e.affected references the first one. Let's make
        // that clear in the visualization.
        msg.write(' -> ${e.affected.first.displayName}');

        reportError(ErrorInDartCode(
          severity: Severity.warning,
          affectedElement: accessor.fromClass,
          message: msg.toString(),
        ));
      }

      final availableQueries = transitiveImports
          .map((f) => f.currentResult)
          .whereType<ParsedMoorFile>()
          .expand((f) => f.resolvedQueries);

      final parser = SqlParser(this, availableTables, accessor.queries);
      parser.parse();

      accessor.allTables = availableTables;

      accessor.resolvedQueries =
          availableQueries.followedBy(parser.foundQueries).toList();
    }
  }
}
