import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/toxicological_classification.dart';

part 'product_model.g.dart';

@JsonSerializable()
class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.activeIngredient,
    required super.concentration,
    required super.formulation,
    required super.sanitaryRegistryNumber,
    required super.expirationDate,
    required super.toxicologicalClassification,
    required super.manufacturer,
    required super.supplier,
    required super.unitCost,
    required super.applicationCost,
    required super.unit,
    required super.description,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => _$ProductModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProductModelToJson(this);

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      activeIngredient: product.activeIngredient,
      concentration: product.concentration,
      formulation: product.formulation,
      sanitaryRegistryNumber: product.sanitaryRegistryNumber,
      expirationDate: product.expirationDate,
      toxicologicalClassification: product.toxicologicalClassification,
      manufacturer: product.manufacturer,
      supplier: product.supplier,
      unitCost: product.unitCost,
      applicationCost: product.applicationCost,
      unit: product.unit,
      description: product.description,
      isActive: product.isActive,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
    );
  }

  Product toEntity() {
    return Product(
      id: id,
      name: name,
      activeIngredient: activeIngredient,
      concentration: concentration,
      formulation: formulation,
      sanitaryRegistryNumber: sanitaryRegistryNumber,
      expirationDate: expirationDate,
      toxicologicalClassification: toxicologicalClassification,
      manufacturer: manufacturer,
      supplier: supplier,
      unitCost: unitCost,
      applicationCost: applicationCost,
      unit: unit,
      description: description,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}