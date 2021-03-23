import 'package:moor_generator/src/analyzer/runner/steps.dart';
import 'package:test/test.dart';

void main() {
  final content = '''
import 'package:my_package/some_file.dart';
import 'relative_file.moor';
  
CREATE TABLE users(
  id INT NOT NULL PRIMARY KEY AUTOINCREMENT,
  name VARCHAR NOT NULL CHECK(LENGTH(name) BETWEEN 5 AND 30),
  field BOOLEAN,
  another DATETIME
);

usersWithLongName: SELECT * FROM users WHERE LENGTH(name) > 25
  ''';

  test('parses standalone .moor files', () async {
    final parseStep = ParseMoorStep(null, null, content);
    final result = await parseStep.parseFile();

    expect(parseStep.errors.errors, isEmpty);

    final table = result.declaredTables.single;
    expect(table.sqlName, 'users');
    expect(table.columns.map((c) => c.name.name),
        ['id', 'name', 'field', 'another']);
    expect(table.columns.map((c) => c.dartTypeName),
        ['int', 'String', 'bool', 'DateTime']);
  });
}
