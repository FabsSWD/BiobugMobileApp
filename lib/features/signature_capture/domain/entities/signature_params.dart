import 'dart:typed_data';
import 'package:equatable/equatable.dart';

class SignatureParams extends Equatable {
  final Uint8List imageBytes;
  final String fileName;
  final double quality;
  final int compressionLevel;
  final int width;
  final int height;
  final int pointsCount;
  final double strokeWidth;

  const SignatureParams({
    required this.imageBytes,
    required this.fileName,
    required this.quality,
    required this.compressionLevel,
    required this.width,
    required this.height,
    required this.pointsCount,
    required this.strokeWidth,
  });

  @override
  List<Object> get props => [
        imageBytes,
        fileName,
        quality,
        compressionLevel,
        width,
        height,
        pointsCount,
        strokeWidth,
      ];

  @override
  String toString() {
    return 'SignatureParams(fileName: $fileName, size: ${width}x$height, quality: $quality, points: $pointsCount)';
  }
}