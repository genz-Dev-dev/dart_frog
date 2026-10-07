import 'package:mongo_dart/mongo_dart.dart';

class MongoDatabase {
  static Db? _db;

  static Future<Db> connect() async {
    if (_db != null && _db!.isConnected) {
      return _db!;
    }

    final db = await Db.create(
      'mongodb://localhost:27017/ecommerce',
    );

    await db.open();

    _db = db;

    print('MongoDB connected successfully');

    return db;
  }

  static Db get instance {
    if (_db == null) {
      throw Exception('MongoDB is not connected');
    }

    return _db!;
  }

  static Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}