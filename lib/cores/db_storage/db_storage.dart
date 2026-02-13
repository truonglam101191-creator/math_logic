import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logic_mathematics/cores/db_storage/ipl_db_storage.dart';

class DbStorage implements IplDbStorage {
  late FlutterSecureStorage? storage;

  DbStorage() {
    storage = null;
    init();
  }

  @override
  Future<void> clear() async {
    if (storage != null) {
      await storage!.deleteAll();
    }
  }

  @override
  Future<void> delete(String key) async {
    if (storage != null) {
      await storage!.delete(key: key);
    }
  }

  @override
  Future get(String key) async {
    if (storage != null) {
      return await storage!.read(key: key);
    }
  }

  @override
  Future<void> init() async {
    storage = FlutterSecureStorage(
      aOptions: const AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    );
  }

  @override
  Future<void> save(String key, value) async {
    if (storage != null) {
      await storage!.write(key: key, value: value);
    }
  }
}
