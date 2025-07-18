import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import '../constants/app_constants.dart';
import '../error/exceptions.dart';

class FileUtils {
  static Future<String> getAppDocumentsPath() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    } catch (e) {
      throw CacheException('Error al obtener directorio de documentos: $e');
    }
  }

  static Future<String> createDirectoryIfNotExists(String path) async {
    try {
      final directory = Directory(path);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      return directory.path;
    } catch (e) {
      throw CacheException('Error al crear directorio: $e');
    }
  }

  static Future<String> getImagesDirectory() async {
    final documentsPath = await getAppDocumentsPath();
    final imagesPath = '$documentsPath/${AppConstants.imagesPath}';
    return await createDirectoryIfNotExists(imagesPath);
  }

  static Future<String> getSignaturesDirectory() async {
    final documentsPath = await getAppDocumentsPath();
    final signaturesPath = '$documentsPath/${AppConstants.signaturesPath}';
    return await createDirectoryIfNotExists(signaturesPath);
  }

  static Future<String> getDocumentsDirectory() async {
    final documentsPath = await getAppDocumentsPath();
    final documentsDir = '$documentsPath/${AppConstants.documentsPath}';
    return await createDirectoryIfNotExists(documentsDir);
  }

  static Future<File> saveBytes(Uint8List bytes, String fileName, String directoryPath) async {
    try {
      final filePath = '$directoryPath/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      throw CacheException('Error al guardar archivo: $e');
    }
  }

  static Future<Uint8List> readBytes(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw CacheException('Archivo no encontrado: $filePath');
      }
      return await file.readAsBytes();
    } catch (e) {
      throw CacheException('Error al leer archivo: $e');
    }
  }

  static Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      throw CacheException('Error al eliminar archivo: $e');
    }
  }

  static Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw CacheException('Archivo no encontrado: $filePath');
      }
      return await file.length();
    } catch (e) {
      throw CacheException('Error al obtener tamaño del archivo: $e');
    }
  }

  static String generateUniqueFileName(String extension) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${timestamp}_${DateTime.now().microsecond}.$extension';
  }
}