import 'package:build/build.dart';
import 'package:moor_generator/src/analyzer/errors.dart';
import 'package:moor_generator/src/analyzer/runner/file_graph.dart';
import 'package:moor_generator/src/analyzer/runner/steps.dart';
import 'package:moor_generator/src/model/specified_table.dart';
import 'package:moor_generator/src/model/sql_query.dart';
import 'package:moor_generator/src/analyzer/sql_queries/query_handler.dart';
import 'package:moor_generator/src/analyzer/sql_queries/type_mapping.dart';
import 'package:sqlparser/sqlparser.dart' hide ResultColumn;

class SqlParser {
  final List<SpecifiedTable> tables;
  final Step step;
  final List<DeclaredQuery> definedQueries;

  final TypeMapper _mapper = TypeMapper();
  SqlEngine _engine;

  final List<SqlQuery> foundQueries = [];

  SqlParser(this.step, this.tables, this.definedQueries);

  void _spawnEngine() {
    _engine = SqlEngine();
    tables.map(_mapper.extractStructure).forEach(_engine.registerTable);
  }

  void parse() {
    _spawnEngine();

    for (var query in definedQueries) {
      final name = query.name;
      var declaredInMoor = false;

      AnalysisContext context;

      if (query is DeclaredDartQuery) {
        final sql = query.sql;

        try {
          context = _engine.analyze(sql);
        } catch (e, s) {
          step.reportError(MoorError(
              severity: Severity.criticalError,
              message: 'Error while trying to parse $name: $e, $s'));
          return;
        }
      } else if (query is DeclaredMoorQuery) {
        context = _engine.analyzeNode(query.query, query.file.parseResult.sql);
        declaredInMoor = true;
      }

      for (var error in context.errors) {
        _report(error,
            msg: () => 'The sql query $name is invalid: $error',
            severity: Severity.error);
      }

      try {
        final query = QueryHandler(name, context, _mapper).handle()
          ..declaredInMoorFile = declaredInMoor;
        foundQueries.add(query);
      } catch (e, s) {
        log.warning('Error while generating APIs for $name', e, s);
      }
    }

    // report lints
    for (var query in foundQueries) {
      for (var lint in query.lints) {
        _report(lint,
            msg: () => 'Lint for ${query.name}: $lint',
            severity: Severity.warning);
      }
    }
  }

  void _report(AnalysisError error,
      {String Function() msg, Severity severity}) {
    if (step.file.type == FileType.moor) {
      step.reportError(
          ErrorInMoorFile.fromSqlParser(error, overrideSeverity: severity));
    } else {
      step.reportError(MoorError(
        severity: severity,
        message: msg(),
      ));
    }
  }
}
