import 'package:flutter_cache_manager/src/storage/cache_info_repository.dart';
import 'package:flutter_cache_manager/src/storage/cache_object.dart';
import 'package:sqflite/sqflite.dart';

const _tableCacheObject = 'cacheObject';

class CacheObjectProvider implements CacheInfoRepository {
  Database db;
  String path;

  CacheObjectProvider(this.path);

  @override
  Future open() async {
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
      create table $_tableCacheObject ( 
        ${CacheObject.columnId} integer primary key, 
        ${CacheObject.columnUrl} text, 
        ${CacheObject.columnPath} text,
        ${CacheObject.columnETag} text,
        ${CacheObject.columnValidTill} integer,
        ${CacheObject.columnTouched} integer
        )
      ''');
    });
  }

  @override
  Future<dynamic> updateOrInsert(CacheObject cacheObject) {
    if (cacheObject.id == null) {
      return insert(cacheObject);
    } else {
      return update(cacheObject);
    }
  }

  @override
  Future<CacheObject> insert(CacheObject cacheObject) async {
    cacheObject.id = await db.insert(_tableCacheObject, cacheObject.toMap());
    return cacheObject;
  }

  @override
  Future<CacheObject> get(String url) async {
    List<Map> maps = await db.query(_tableCacheObject,
        columns: null, where: '${CacheObject.columnUrl} = ?', whereArgs: [url]);
    if (maps.isNotEmpty) {
      return CacheObject.fromMap(maps.first.cast<String, dynamic>());
    }
    return null;
  }

  @override
  Future<int> delete(int id) {
    return db.delete(_tableCacheObject,
        where: '${CacheObject.columnId} = ?', whereArgs: [id]);
  }

  @override
  Future deleteAll(Iterable<int> ids) {
    return db.delete(_tableCacheObject,
        where: '${CacheObject.columnId} IN (' + ids.join(',') + ')');
  }

  @override
  Future<int> update(CacheObject cacheObject) {
    return db.update(_tableCacheObject, cacheObject.toMap(),
        where: '${CacheObject.columnId} = ?', whereArgs: [cacheObject.id]);
  }

  @override
  Future<List<CacheObject>> getAllObjects() async {
    return CacheObject.fromMapList(
      await db.query(_tableCacheObject, columns: null),
    );
  }

  @override
  Future<List<CacheObject>> getObjectsOverCapacity(int capacity) async {
    return CacheObject.fromMapList(await db.query(
      _tableCacheObject,
      columns: null,
      orderBy: '${CacheObject.columnTouched} DESC',
      where: '${CacheObject.columnTouched} < ?',
      whereArgs: [
        DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch
      ],
      limit: 100,
      offset: capacity,
    ));
  }

  @override
  Future<List<CacheObject>> getOldObjects(Duration maxAge) async {
    return CacheObject.fromMapList(await db.query(
      _tableCacheObject,
      where: '${CacheObject.columnTouched} < ?',
      columns: null,
      whereArgs: [DateTime.now().subtract(maxAge).millisecondsSinceEpoch],
      limit: 100,
    ));
  }

  @override
  Future close() => db.close();
}
