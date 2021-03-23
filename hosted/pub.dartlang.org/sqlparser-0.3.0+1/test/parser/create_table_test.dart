import 'package:sqlparser/sqlparser.dart';
import 'package:sqlparser/src/ast/ast.dart';
import 'package:sqlparser/src/utils/ast_equality.dart';
import 'package:test/test.dart';

import '../common_data.dart';
import 'utils.dart';

void main() {
  test('parsers simple create table statements', () {
    testStatement(
      'CREATE TABLE my_tbl (a INT, b TEXT)',
      CreateTableStatement(tableName: 'my_tbl', columns: [
        ColumnDefinition(columnName: 'a', typeName: 'INT'),
        ColumnDefinition(columnName: 'b', typeName: 'TEXT'),
      ]),
    );
  });

  test('parses complex CREATE TABLE statements', () {
    testStatement(
      createTableStmt,
      CreateTableStatement(
        tableName: 'users',
        ifNotExists: true,
        withoutRowId: false,
        columns: [
          ColumnDefinition(
            columnName: 'id',
            typeName: 'INT',
            constraints: [
              NotNull(null),
              PrimaryKeyColumn(
                null,
                autoIncrement: true,
                onConflict: ConflictClause.rollback,
                mode: OrderingMode.descending,
              ),
            ],
          ),
          ColumnDefinition(
            columnName: 'email',
            typeName: 'VARCHAR',
            constraints: [
              NotNull(null),
              UniqueColumn(null, ConflictClause.abort),
            ],
          ),
          ColumnDefinition(
            columnName: 'score',
            typeName: 'INT',
            constraints: [
              NotNull('score set'),
              Default(
                  null, NumericLiteral(420, token(TokenType.numberLiteral))),
              CheckColumn(
                null,
                BinaryExpression(
                  Reference(columnName: 'score'),
                  token(TokenType.more),
                  NumericLiteral(
                    0,
                    token(TokenType.numberLiteral),
                  ),
                ),
              ),
            ],
          ),
          ColumnDefinition(
            columnName: 'display_name',
            typeName: 'VARCHAR',
            constraints: [
              CollateConstraint(
                null,
                'BINARY',
              ),
              ForeignKeyColumnConstraint(
                null,
                ForeignKeyClause(
                  foreignTable: TableReference('some', null),
                  columnNames: [Reference(columnName: 'thing')],
                  onUpdate: ReferenceAction.cascade,
                  onDelete: ReferenceAction.setNull,
                ),
              ),
            ],
          )
        ],
        tableConstraints: [
          KeyClause(
            null,
            isPrimaryKey: false,
            indexedColumns: [
              Reference(columnName: 'score'),
              Reference(columnName: 'display_name'),
            ],
            onConflict: ConflictClause.abort,
          ),
          ForeignKeyTableConstraint(
            null,
            columns: [
              Reference(columnName: 'id'),
              Reference(columnName: 'email'),
            ],
            clause: ForeignKeyClause(
              foreignTable: TableReference('another', null),
              columnNames: [
                Reference(columnName: 'a'),
                Reference(columnName: 'b'),
              ],
              onDelete: ReferenceAction.noAction,
              onUpdate: ReferenceAction.restrict,
            ),
          )
        ],
      ),
    );
  });

  test('parses MAPPED BY expressions when in moor mode', () {
    const stmt = 'CREATE TABLE a (b NOT NULL MAPPED BY `Mapper()` PRIMARY KEY)';
    final parsed = SqlEngine(useMoorExtensions: true).parse(stmt).rootNode;

    enforceEqual(
      parsed,
      CreateTableStatement(tableName: 'a', columns: [
        ColumnDefinition(
          columnName: 'b',
          typeName: null,
          constraints: [
            NotNull(null),
            MappedBy(null, inlineDart('Mapper()')),
            PrimaryKeyColumn(null),
          ],
        ),
      ]),
    );
  });
}
