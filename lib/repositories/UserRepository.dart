import '../models/UserModel.dart';
import '../database/Mongodb.dart';
import 'package:mongo_dart/mongo_dart.dart';

class UserRepository {
  static const String _collection = 'users';

  DbCollection get _col =>
      MongoDatabase.instance.collection(_collection);

  Future<User?> findByEmail(String email) async {
    final doc = await _col.findOne(where.eq('email', email));
    if (doc == null) return null;
    return User.fromMap(doc);
  }

  Future<void> save(User user) async {
    await _col.insertOne(user.toMap());
  }

  Future<User?> findById(String id) async {
    final doc = await _col.findOne(where.eq('id', id));
    if (doc == null) return null;
    return User.fromMap(doc);
  }
}