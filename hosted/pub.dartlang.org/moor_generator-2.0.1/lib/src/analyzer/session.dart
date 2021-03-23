import 'dart:async';

import 'package:moor_generator/src/analyzer/runner/file_graph.dart';
import 'package:moor_generator/src/analyzer/runner/task.dart';
import 'package:moor_generator/src/backends/backend.dart';
import 'package:path/path.dart' as p;

const _fileEndings = {
  '.moor': FileType.moor,
  '.dart': FileType.dart,
};

/// Will store cached data about files that have already been analyzed.
class MoorSession {
  final FileGraph fileGraph = FileGraph();
  final Backend backend;

  final _completedTasks = StreamController<Task>.broadcast();
  final _changedFiles = StreamController<List<FoundFile>>.broadcast();

  MoorSession(this.backend);

  /// Stream that emits a [Task] that has been completed.
  Stream<Task> get completedTasks => _completedTasks.stream;

  /// Stream that emits a list of [FoundFile] that need to be parsed or
  /// re-analyzed because a file has changed.
  /// This is not supported on all backends (notably, not with `package:build`,
  /// which assumes immutable files during a build run).
  Stream<List<FoundFile>> get changedFiles => _changedFiles.stream;

  FileType _findFileType(String path) {
    final extension = p.extension(path);

    return _fileEndings[extension] ?? FileType.other;
  }

  /// Resolves an import directive in the context of the [source] file. This
  /// can handle both relative imports and `package:` imports.
  FoundFile resolve(FoundFile source, String import) {
    final resolvedUri = backend.resolve(source.uri, import);
    return _uriToFile(resolvedUri);
  }

  /// Registers a file by its absolute uri.
  FoundFile registerFile(Uri file) => _uriToFile(file);

  FoundFile _uriToFile(Uri uri) {
    return fileGraph.registerFile(uri, () {
      return FoundFile(uri, _findFileType(uri.path));
    });
  }

  Task startTask(BackendTask backend) {
    return Task(this, _uriToFile(backend.entrypoint), backend);
  }

  /// Notifies this backend that the content of the given [file] has been
  /// changed.
  void notifyFileChanged(FoundFile file) {
    file.state = FileState.dirty;
    final changed = [file];

    // all files that transitively imported this files are no longer analyzed
    // because they depend on this file. They're still parsed though
    for (var affected in fileGraph.crawl(file, transposed: true)) {
      if (affected.state == FileState.analyzed) {
        affected.state = FileState.parsed;
      }
      changed.add(affected);
    }

    _changedFiles.add(changed);
  }

  void notifyTaskFinished(Task task) {
    _completedTasks.add(task);
  }
}
