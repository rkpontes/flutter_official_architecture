// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:flutter_oficial_architecture/data/services/local_storage/local_storage.dart';
import 'package:flutter_oficial_architecture/utils/exceptions.dart';

class LocalStorageImpl implements LocalStorage {
  LocalStorageImpl(this.sharedPreferences);

  final SharedPreferences sharedPreferences;

  @override
  Future<void> delete(String key) async {
    try {
      await sharedPreferences.remove(key);
    } catch (e) {
      throw LocalStorageException('Error deleting key: $key');
    }
  }

  @override
  Future<String?> read(String key) async {
    try {
      return sharedPreferences.getString(key);
    } catch (e) {
      throw LocalStorageException('Error reading key: $key');
    }
  }

  @override
  Future<void> save(String key, String value) async {
    try {
      await sharedPreferences.setString(key, value);
    } catch (e) {
      throw LocalStorageException('Error saving key: $key');
    }
  }
}
