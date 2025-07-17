import 'dart:convert';
import 'dart:typed_data';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/signature.dart';

part 'signature_model.g.dart';

@JsonSerializable()
class SignatureModel extends Signature {
  @JsonKey(name: 'imageBytes', fromJson: _bytesFromString, toJson: _bytesToString)
  final Uint8List imageData;

  const SignatureModel({
    required super.id,
    required this.imageData,
    required super.createdAt,
    required super.width,
    required super.height,
    required super.quality,
    super.filePath,
    required super.isUploaded,
    required super.pointsCount,
    required super.strokeWidth,
  }) : super(
          imageBytes: imageData,
        );

  factory SignatureModel.fromJson(Map<String, dynamic> json) =>
      _$SignatureModelFromJson(json);

  Map<String, dynamic> toJson() => _$SignatureModelToJson(this);

  factory SignatureModel.fromEntity(Signature signature) {
    return SignatureModel(
      id: signature.id,
      imageData: signature.imageBytes,
      createdAt: signature.createdAt,
      width: signature.width,
      height: signature.height,
      quality: signature.quality,
      filePath: signature.filePath,
      isUploaded: signature.isUploaded,
      pointsCount: signature.pointsCount,
      strokeWidth: signature.strokeWidth,
    );
  }

  Signature toEntity() {
    return Signature(
      id: id,
      imageBytes: imageData,
      createdAt: createdAt,
      width: width,
      height: height,
      quality: quality,
      filePath: filePath,
      isUploaded: isUploaded,
      pointsCount: pointsCount,
      strokeWidth: strokeWidth,
    );
  }

  static String _bytesToString(Uint8List bytes) => base64Encode(bytes);
  static Uint8List _bytesFromString(String encoded) => base64Decode(encoded);
}