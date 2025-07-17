import 'dart:io';
import 'package:dio/dio.dart';

class SignatureRequestModel {
  final File signatureFile;
  final String fileName;
  final String contentType;

  SignatureRequestModel({
    required this.signatureFile,
    required this.fileName,
    this.contentType = 'image/png',
  });

  Future<MultipartFile> toMultipartFile() async {
    return await MultipartFile.fromFile(
      signatureFile.path,
      filename: fileName,
      contentType: DioMediaType.parse(contentType),
    );
  }

  Map<String, dynamic> toFormData() {
    return {
      'signatureFile': toMultipartFile(),
    };
  }
}