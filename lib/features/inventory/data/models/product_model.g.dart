// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) => ProductModel(
  id: json['id'] as String,
  name: json['name'] as String,
  activeIngredient: json['activeIngredient'] as String,
  concentration: (json['concentration'] as num).toDouble(),
  formulation: json['formulation'] as String,
  sanitaryRegistryNumber: json['sanitaryRegistryNumber'] as String,
  expirationDate: DateTime.parse(json['expirationDate'] as String),
  toxicologicalClassification: $enumDecode(
    _$ToxicologicalClassificationEnumMap,
    json['toxicologicalClassification'],
  ),
  manufacturer: json['manufacturer'] as String,
  supplier: json['supplier'] as String,
  unitCost: (json['unitCost'] as num).toDouble(),
  applicationCost: (json['applicationCost'] as num).toDouble(),
  unit: json['unit'] as String,
  description: json['description'] as String,
  isActive: json['isActive'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'activeIngredient': instance.activeIngredient,
      'concentration': instance.concentration,
      'formulation': instance.formulation,
      'sanitaryRegistryNumber': instance.sanitaryRegistryNumber,
      'expirationDate': instance.expirationDate.toIso8601String(),
      'toxicologicalClassification':
          _$ToxicologicalClassificationEnumMap[instance
              .toxicologicalClassification]!,
      'manufacturer': instance.manufacturer,
      'supplier': instance.supplier,
      'unitCost': instance.unitCost,
      'applicationCost': instance.applicationCost,
      'unit': instance.unit,
      'description': instance.description,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$ToxicologicalClassificationEnumMap = {
  ToxicologicalClassification.ia: 'ia',
  ToxicologicalClassification.ib: 'ib',
  ToxicologicalClassification.ii: 'ii',
  ToxicologicalClassification.iii: 'iii',
  ToxicologicalClassification.iv: 'iv',
  ToxicologicalClassification.u: 'u',
};
