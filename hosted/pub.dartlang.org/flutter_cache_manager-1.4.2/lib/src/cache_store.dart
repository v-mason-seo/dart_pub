import 'dart:async';
import 'dart:io';

import 'package:file/file.dart' as f;
import 'package:flutter_cache_manager/src/result/file_info.dart';
import 'package:flutter_cache_manager/src/storage/cache_info_repository.dart';
import 'package:flutter_cache_manager/src/storage/cache_object.dart';
import 'package:flutter_cache_manager/src/storage/cache_object_provider.dart';
import 'package:path/path.dart' as p;
import 'package:pedantic/pedantic.dart';
import 'package:sqflite/sqflite.dart';

///Flutter Cache Manager
///Copyright (c) 2019 Rene Floor
///Released under MIT License.

class CacheStore {
  Duration cleanupRunMinInterval;

  final _futureCache = <String, Future<CacheObject>>{};
  final _memCache = <String, CacheObject>{};

  Future<f.Directory> fileDir;
  f.Directory _fileDir;

  final String storeKey;
  Future<CacheInfoRepository> _cacheInfoRepository;
  final int _capacity;
  final Duration _maxAge;

  DateTime lastCleanupRun = DateTime.now();
  Timer _scheduledCleanup;

  CacheStore(
      Future<f.Directory> basedir, this.storeKey, this._capacity, this._maxAge,
      {Future<CacheInfoRepository> cacheRepoProvider,
      this.cleanupRunMinInterval = const Duration(seconds: 10)}) {
    fileDir = basedir.then((dir) => _fileDir = dir);
    _cacheInfoRepository = cacheRepoProvider ?? _getObjectProvider();
  }

  Future<CacheInfoRepository> _getObjectProvider() async {
    final databasesPath = await getDatabasesPath();
    try {
      await Directory(databasesPath).create(recursive: true);
    } catch (_) {}
    final provider = CacheObjectProvider(p.join(databasesPath, '$storeKey.db'));
    await provider.open();
    return provider;
  }

  Future<FileInfo> getFile(String url, {bool ignoreMemCache = false}) async {
    final cacheObject =
        await retrieveCacheData(url, ignoreMemCache: ignoreMemCache);
    if (cacheObject == null || cacheObject.relativePath == null) {
      return null;
    }
    final file = (await fileDir).childFile(cacheObject.relativePath);
    return FileInfo(file, FileSource.Cache, cacheObject.validTill, url);
  }

  Future<void> putFile(CacheObject cacheObject) async {
    _memCache[cacheObject.url] = cacheObject;
    await _updateCacheDataInDatabase(cacheObject);
  }

  Future<CacheObject> retrieveCacheData(String url,
      {bool ignoreMemCache = false}) async {
    if (!ignoreMemCache && _memCache.containsKey(url)) {
      if (await _fileExists(_memCache[url])) {
        return _memCache[url];
      }
    }
    if (!_futureCache.containsKey(url)) {
      final completer = Completer<CacheObject>();
      unawaited(_getCacheDataFromDatabase(url).then((cacheObject) async {
        if (cacheObject != null && !await _fileExists(cacheObject)) {
          final provider = await _cacheInfoRepository;
          await provider.delete(cacheObject.id);
          cacheObject = null;
        }

        _memCache[url] = cacheObject;
        completer.complete(cacheObject);
        unawaited(_futureCache.remove(url));
      }));
      _futureCache[url] = completer.future;
    }
    return _futureCache[url];
  }

  FileInfo getFileFromMemory(String url) {
    if (_memCache[url] == null || _fileDir == null) {
      return null;
    }
    final cacheObject = _memCache[url];
    final file = _fileDir.childFile(cacheObject.relativePath);
    return FileInfo(file, FileSource.Cache, cacheObject.validTill, url);
  }

  Future<bool> _fileExists(CacheObject cacheObject) async {
    if (cacheObject?.relativePath == null) {
      return false;
    }

    var dirPath = await fileDir;
    var file = dirPath.childFile(cacheObject.relativePath);
    return file.exists();
  }

  Future<CacheObject> _getCacheDataFromDatabase(String url) async {
    final provider = await _cacheInfoRepository;
    final data = await provider.get(url);
    if (await _fileExists(data)) {
      unawaited(_updateCacheDataInDatabase(data));
    }
    _scheduleCleanup();
    return data;
  }

  void _scheduleCleanup() {
    if (_scheduledCleanup != null) {
      return;
    }
    _scheduledCleanup = Timer(cleanupRunMinInterval, () {
      _scheduledCleanup = null;
      _cleanupCache();
    });
  }

  Future<dynamic> _updateCacheDataInDatabase(CacheObject cacheObject) async {
    final provider = await _cacheInfoRepository;
    return provider.updateOrInsert(cacheObject);
  }

  Future<void> _cleanupCache() async {
    final toRemove = <int>[];
    final provider = await _cacheInfoRepository;

    final overCapacity = await provider.getObjectsOverCapacity(_capacity);
    for (final cacheObject in overCapacity) {
      unawaited(_removeCachedFile(cacheObject, toRemove));
    }

    final oldObjects = await provider.getOldObjects(_maxAge);
    for (final cacheObject in oldObjects) {
      unawaited(_removeCachedFile(cacheObject, toRemove));
    }

    await provider.deleteAll(toRemove);
  }

  Future<void> emptyCache() async {
    final provider = await _cacheInfoRepository;
    final toRemove = <int>[];
    final allObjects = await provider.getAllObjects();
    for (final cacheObject in allObjects) {
      unawaited(_removeCachedFile(cacheObject, toRemove));
    }
    await provider.deleteAll(toRemove);
  }

  void emptyMemoryCache() {
    _memCache.clear();
  }

  Future<void> removeCachedFile(CacheObject cacheObject) async {
    final provider = await _cacheInfoRepository;
    final toRemove = <int>[];
    unawaited(_removeCachedFile(cacheObject, toRemove));
    await provider.deleteAll(toRemove);
  }

  Future<void> _removeCachedFile(
      CacheObject cacheObject, List<int> toRemove) async {
    if (toRemove.contains(cacheObject.id)) return;

    toRemove.add(cacheObject.id);
    if (_memCache.containsKey(cacheObject.url)) {
      _memCache.remove(cacheObject.url);
    }
    if (_futureCache.containsKey(cacheObject.url)) {
      unawaited(_futureCache.remove(cacheObject.url));
    }
    final file = (await fileDir).childFile(cacheObject.relativePath);
    if (await file.exists()) {
      unawaited(file.delete());
    }
  }

  Future<void> dispose() async {
    final provider = await _cacheInfoRepository;
    await provider.close();
  }
}
