import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/utils/file_utils.dart';
import '../models/signature_model.dart';

abstract class SignatureLocalDataSource {
  Future<void> saveSignature(SignatureModel signature);
  Future<List<SignatureModel>> getSavedSignatures();
  Future<void> deleteSignature(String id);
  Future<SignatureModel?> getSignatureById(String id);
  Future<String> saveSignatureFile(Uint8List imageBytes, String fileName);
  Future<Uint8List> readSignatureFile(String filePath);
  Future<bool> deleteSignatureFile(String filePath);
}

@LazySingleton(as: SignatureLocalDataSource)
class SignatureLocalDataSourceImpl implements SignatureLocalDataSource {
  final LocalStorage _localStorage;
  // ignore: unused_field
  final _uuid = const Uuid();
  
  static const String _signaturesKey = 'saved_signatures';

  SignatureLocalDataSourceImpl(this._localStorage);

  @override
  Future<void> saveSignature(SignatureModel signature) async {
    try {
      final signatures = await getSavedSignatures();
      
      // Remove existing signature with same ID if exists
      signatures.removeWhere((s) => s.id == signature.id);
      
      // Add new signature
      signatures.add(signature);
      
      // Save to local storage
      final signaturesJson = signatures.map((s) => s.toJson()).toList();
      await _localStorage.setString(_signaturesKey, jsonEncode(signaturesJson));
    } catch (e) {
      throw CacheException('Error al guardar firma: $e');
    }
  }

  @override
  Future<List<SignatureModel>> getSavedSignatures() async {
    try {
      final signaturesJson = _localStorage.getString(_signaturesKey);
      if (signaturesJson == null) return [];
      
      final List<dynamic> signaturesList = jsonDecode(signaturesJson);
      return signaturesList
          .map((json) => SignatureModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException('Error al obtener firmas guardadas: $e');
    }
  }

  @override
  Future<void> deleteSignature(String id) async {
    try {
      final signatures = await getSavedSignatures();
      final signatureToDelete = signatures.where((s) => s.id == id).firstOrNull;
      
      if (signatureToDelete == null) {
        throw CacheException('Firma no encontrada');
      }
      
      // Delete file if exists
      if (signatureToDelete.filePath != null) {
        await deleteSignatureFile(signatureToDelete.filePath!);
      }
      
      // Remove from list
      signatures.removeWhere((s) => s.id == id);
      
      // Save updated list
      final signaturesJson = signatures.map((s) => s.toJson()).toList();
      await _localStorage.setString(_signaturesKey, jsonEncode(signaturesJson));
    } catch (e) {
      throw CacheException('Error al eliminar firma: $e');
    }
  }

  @override
  Future<SignatureModel?> getSignatureById(String id) async {
    try {
      final signatures = await getSavedSignatures();
      return signatures.where((s) => s.id == id).firstOrNull;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String> saveSignatureFile(Uint8List imageBytes, String fileName) async {
    try {
      final signaturesDir = await FileUtils.getSignaturesDirectory();
      
      // Save file directly without encryption (for simplicity)
      final filePath = '$signaturesDir/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(imageBytes);
      
      return filePath;
    } catch (e) {
      throw CacheException('Error al guardar archivo de firma: $e');
    }
  }

  @override
  Future<Uint8List> readSignatureFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw CacheException('Archivo de firma no encontrado');
      }
      
      return await file.readAsBytes();
    } catch (e) {
      throw CacheException('Error al leer archivo de firma: $e');
    }
  }

  @override
  Future<bool> deleteSignatureFile(String filePath) async {
    try {
      return await FileUtils.deleteFile(filePath);
    } catch (e) {
      throw CacheException('Error al eliminar archivo de firma: $e');
    }
  }
}