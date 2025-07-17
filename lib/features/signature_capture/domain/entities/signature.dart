import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import '../../../../core/constants/app_constants.dart';

class Signature extends Equatable {
  final String id;
  final Uint8List imageBytes;
  final DateTime createdAt;
  final int width;
  final int height;
  final double quality;
  final String? filePath;
  final bool isUploaded;
  final int pointsCount;
  final double strokeWidth;

  const Signature({
    required this.id,
    required this.imageBytes,
    required this.createdAt,
    required this.width,
    required this.height,
    required this.quality,
    this.filePath,
    required this.isUploaded,
    required this.pointsCount,
    required this.strokeWidth,
  });

  @override
  List<Object?> get props => [
        id,
        imageBytes,
        createdAt,
        width,
        height,
        quality,
        filePath,
        isUploaded,
        pointsCount,
        strokeWidth,
      ];

  bool get isValid => 
      width >= AppConstants.signatureMinResolutionWidth && 
      height >= AppConstants.signatureMinResolutionHeight && 
      pointsCount >= AppConstants.signatureMinPoints && 
      imageBytes.isNotEmpty &&
      imageBytes.length <= AppConstants.signatureMaxFileSize;

  int get fileSizeInBytes => imageBytes.length;

  double get fileSizeInKB => fileSizeInBytes / 1024;

  double get fileSizeInMB => fileSizeInBytes / 1024 / 1024;

  String get formattedFileSize {
    if (fileSizeInMB >= 1) {
      return '${fileSizeInMB.toStringAsFixed(2)} MB';
    } else {
      return '${fileSizeInKB.toStringAsFixed(1)} KB';
    }
  }

  Signature copyWith({
    String? id,
    Uint8List? imageBytes,
    DateTime? createdAt,
    int? width,
    int? height,
    double? quality,
    String? filePath,
    bool? isUploaded,
    int? pointsCount,
    double? strokeWidth,
  }) {
    return Signature(
      id: id ?? this.id,
      imageBytes: imageBytes ?? this.imageBytes,
      createdAt: createdAt ?? this.createdAt,
      width: width ?? this.width,
      height: height ?? this.height,
      quality: quality ?? this.quality,
      filePath: filePath ?? this.filePath,
      isUploaded: isUploaded ?? this.isUploaded,
      pointsCount: pointsCount ?? this.pointsCount,
      strokeWidth: strokeWidth ?? this.strokeWidth,
    );
  }

  @override
  String toString() {
    return 'Signature(id: $id, size: ${width}x$height, quality: $quality, points: $pointsCount, fileSize: $formattedFileSize, isUploaded: $isUploaded)';
  }
}