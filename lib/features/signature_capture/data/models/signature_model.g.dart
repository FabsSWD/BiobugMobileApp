// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signature_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignatureModel _$SignatureModelFromJson(Map<String, dynamic> json) =>
    SignatureModel(
      id: json['id'] as String,
      imageData: SignatureModel._bytesFromString(json['imageBytes'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      width: (json['width'] as num).toInt(),
      height: (json['height'] as num).toInt(),
      quality: (json['quality'] as num).toDouble(),
      filePath: json['filePath'] as String?,
      isUploaded: json['isUploaded'] as bool,
      pointsCount: (json['pointsCount'] as num).toInt(),
      strokeWidth: (json['strokeWidth'] as num).toDouble(),
    );

Map<String, dynamic> _$SignatureModelToJson(SignatureModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'width': instance.width,
      'height': instance.height,
      'quality': instance.quality,
      'filePath': instance.filePath,
      'isUploaded': instance.isUploaded,
      'pointsCount': instance.pointsCount,
      'strokeWidth': instance.strokeWidth,
      'imageBytes': SignatureModel._bytesToString(instance.imageData),
    };
