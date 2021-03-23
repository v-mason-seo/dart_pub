// ignore_for_file: implementation_imports
import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/src/dart/analysis/file_state.dart';
import 'package:analyzer/src/dart/analysis/driver.dart';
import 'package:logging/logging.dart';
import 'package:moor_generator/src/analyzer/runner/file_graph.dart';
import 'package:moor_generator/src/analyzer/session.dart';
import 'package:moor_generator/src/backends/plugin/backend/driver_synchronizer.dart';
import 'package:moor_generator/src/backends/plugin/backend/file_tracker.dart';
import 'package:moor_generator/src/backends/plugin/backend/plugin_backend.dart';

class MoorDriver implements AnalysisDriverGeneric {
  final FileTracker _tracker;

  final AnalysisDriverScheduler _scheduler;
  final AnalysisDriver dartDriver;

  /// The content overlay exists so that we can perform up-to-date analysis on
  /// unsaved files.
  final FileContentOverlay contentOverlay;
  final ResourceProvider _resourceProvider;
  final DriverSynchronizer _synchronizer = DriverSynchronizer();

  /* late final */ MoorSession session;
  StreamSubscription _fileChangeSubscription;

  MoorDriver(this._tracker, this._scheduler, this.dartDriver,
      this.contentOverlay, this._resourceProvider) {
    _scheduler.add(this);
    final backend = PluginBackend(this);
    session = backend.session;

    _fileChangeSubscription =
        session.changedFiles.listen(_tracker.notifyFilesChanged);
  }

  bool _ownsFile(String path) => path.endsWith('.moor');

  FoundFile pathToFoundFile(String path) {
    return session.registerFile(Uri.parse('file://$path'));
  }

  @override
  void addFile(String path) {
    if (_ownsFile(path)) {
      pathToFoundFile(path); // will be registered if it doesn't exists
    }
  }

  @override
  void dispose() {
    _fileChangeSubscription?.cancel();
    _scheduler.remove(this);
    dartDriver.dispose();
    _tracker.dispose();
  }

  void handleFileChanged(String path) {
    if (_ownsFile(path)) {
      session.notifyFileChanged(pathToFoundFile(path));
      _scheduler.notify(this);
    }
  }

  @override
  bool get hasFilesToAnalyze => _tracker.hasWork;

  @override
  Future<void> performWork() async {
    if (_synchronizer.hasPausedWork) {
      await _synchronizer.resumePaused();
    } else {
      final mostImportantFile = _tracker.fileWithHighestPriority;
      if (mostImportantFile.file?.isAnalyzed ?? false) {
        Logger.root.fine('Blocked attempt to work on fully analyzed file');
        return;
      }
      final backendTask = _createTask(mostImportantFile.file.uri);

      try {
        final task = session.startTask(backendTask);
        await _synchronizer.safeRunTask(task);
        _tracker.handleTaskCompleted(task);
      } catch (e, s) {
        Logger.root.warning(
            'Error while working on ${mostImportantFile.file.uri}', e, s);
        _tracker.removePending(mostImportantFile);
      }
    }
  }

  String readFile(String path) {
    final overlay = contentOverlay[path];
    if (overlay != null) {
      return overlay;
    }

    final file = _resourceProvider.getFile(path);
    return file.exists ? file.readAsStringSync() : '';
  }

  Future<LibraryElement> resolveDart(String path) async {
    final result = await _synchronizer.useDartDriver(() {
      return dartDriver.currentSession.getUnitElement(path);
    });

    return result.element.enclosingElement;
  }

  bool doesFileExist(String path) {
    return contentOverlay[path] != null ||
        _resourceProvider.getFile(path).exists;
  }

  /// Finds the absolute path of a [reference] url, optionally assuming that the
  /// [reference] appears in [base]. This supports both "package:"-based uris
  /// and relative imports.
  String absolutePath(Uri reference, {Uri base}) {
    final factory = dartDriver.sourceFactory;
    final baseSource = base == null ? null : factory.forUri2(base);

    final source =
        dartDriver.sourceFactory.resolveUri(baseSource, reference.toString());
    return source.fullName;
  }

  PluginTask _createTask(Uri uri) {
    return PluginTask(uri, this);
  }

  @override
  set priorityFiles(List<String> priorityPaths) {
    final found = priorityPaths.where(_ownsFile).map(pathToFoundFile);
    _tracker.setPriorityFiles(found);
  }

  @override
  AnalysisDriverPriority get workPriority {
    final overridden = _synchronizer.overriddenPriority;
    if (overridden != null) return overridden;

    if (_tracker.hasWork) {
      final mostImportant = _tracker.fileWithHighestPriority;
      return mostImportant.currentPriority;
    } else {
      return AnalysisDriverPriority.nothing;
    }
  }

  Stream<FoundFile> completedFiles() {
    return session.completedTasks.expand((task) => task.analyzedFiles);
  }

  /// Waits for the file at [path] to be parsed.
  Future<FoundFile> waitFileParsed(String path) {
    final found = pathToFoundFile(path);

    if (found.isParsed) {
      return Future.value(found);
    } else {
      _scheduler.notify(this);
      final found = pathToFoundFile(path);

      return completedFiles()
          .firstWhere((file) => file == found && file.isParsed);
    }
  }
}
