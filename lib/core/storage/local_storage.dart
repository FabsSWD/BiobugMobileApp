import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';
import '../constants/storage_constants.dart';
import '../error/exceptions.dart';

@LazySingleton()
class LocalStorage {
  final SharedPreferences _prefs;

  LocalStorage(this._prefs);

  // App Settings
  Future<void> setFirstLaunch(bool isFirstLaunch) async {
    try {
      await _prefs.setBool(StorageConstants.isFirstLaunch, isFirstLaunch);
    } catch (e) {
      throw CacheException('Error al guardar primer inicio: $e');
    }
  }

  bool isFirstLaunch() {
    try {
      return _prefs.getBool(StorageConstants.isFirstLaunch) ?? true;
    } catch (e) {
      throw CacheException('Error al verificar primer inicio: $e');
    }
  }

  Future<void> setOfflineMode(bool isOffline) async {
    try {
      await _prefs.setBool(StorageConstants.offlineMode, isOffline);
    } catch (e) {
      throw CacheException('Error al guardar modo offline: $e');
    }
  }

  bool isOfflineMode() {
    try {
      return _prefs.getBool(StorageConstants.offlineMode) ?? false;
    } catch (e) {
      throw CacheException('Error al obtener modo offline: $e');
    }
  }

  Future<void> setAppTheme(String theme) async {
    try {
      await _prefs.setString(StorageConstants.appTheme, theme);
    } catch (e) {
      throw CacheException('Error al guardar tema: $e');
    }
  }

  String? getAppTheme() {
    try {
      return _prefs.getString(StorageConstants.appTheme);
    } catch (e) {
      throw CacheException('Error al obtener tema: $e');
    }
  }

  // Generic methods
  Future<void> setString(String key, String value) async {
    try {
      await _prefs.setString(key, value);
    } catch (e) {
      throw CacheException('Error al guardar string: $e');
    }
  }

  String? getString(String key) {
    try {
      return _prefs.getString(key);
    } catch (e) {
      throw CacheException('Error al obtener string: $e');
    }
  }

  Future<void> setInt(String key, int value) async {
    try {
      await _prefs.setInt(key, value);
    } catch (e) {
      throw CacheException('Error al guardar entero: $e');
    }
  }

  int? getInt(String key) {
    try {
      return _prefs.getInt(key);
    } catch (e) {
      throw CacheException('Error al obtener entero: $e');
    }
  }

  Future<void> setBool(String key, bool value) async {
    try {
      await _prefs.setBool(key, value);
    } catch (e) {
      throw CacheException('Error al guardar booleano: $e');
    }
  }

  bool? getBool(String key) {
    try {
      return _prefs.getBool(key);
    } catch (e) {
      throw CacheException('Error al obtener booleano: $e');
    }
  }

  Future<void> remove(String key) async {
    try {
      await _prefs.remove(key);
    } catch (e) {
      throw CacheException('Error al eliminar clave: $e');
    }
  }

  Future<void> clear() async {
    try {
      await _prefs.clear();
    } catch (e) {
      throw CacheException('Error al limpiar almacenamiento local: $e');
    }
  }
}