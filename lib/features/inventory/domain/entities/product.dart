import 'package:biobug_mobile_app/features/inventory/domain/entities/toxicological_classification.dart';
import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String activeIngredient;
  final double concentration;
  final String formulation;
  final String sanitaryRegistryNumber;
  final DateTime expirationDate;
  final ToxicologicalClassification toxicologicalClassification;
  final String manufacturer;
  final String supplier;
  final double unitCost;
  final double applicationCost;
  final String unit; // L, kg, g, ml
  final String description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.name,
    required this.activeIngredient,
    required this.concentration,
    required this.formulation,
    required this.sanitaryRegistryNumber,
    required this.expirationDate,
    required this.toxicologicalClassification,
    required this.manufacturer,
    required this.supplier,
    required this.unitCost,
    required this.applicationCost,
    required this.unit,
    required this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object> get props => [
        id,
        name,
        activeIngredient,
        concentration,
        formulation,
        sanitaryRegistryNumber,
        expirationDate,
        toxicologicalClassification,
        manufacturer,
        supplier,
        unitCost,
        applicationCost,
        unit,
        description,
        isActive,
        createdAt,
        updatedAt,
      ];

  bool get isExpiringSoon {
    final now = DateTime.now();
    final daysUntilExpiration = expirationDate.difference(now).inDays;
    return daysUntilExpiration <= 30; // Expira en 30 días o menos
  }

  bool get isExpired {
    return DateTime.now().isAfter(expirationDate);
  }

  Product copyWith({
    String? id,
    String? name,
    String? activeIngredient,
    double? concentration,
    String? formulation,
    String? sanitaryRegistryNumber,
    DateTime? expirationDate,
    ToxicologicalClassification? toxicologicalClassification,
    String? manufacturer,
    String? supplier,
    double? unitCost,
    double? applicationCost,
    String? unit,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      activeIngredient: activeIngredient ?? this.activeIngredient,
      concentration: concentration ?? this.concentration,
      formulation: formulation ?? this.formulation,
      sanitaryRegistryNumber: sanitaryRegistryNumber ?? this.sanitaryRegistryNumber,
      expirationDate: expirationDate ?? this.expirationDate,
      toxicologicalClassification: toxicologicalClassification ?? this.toxicologicalClassification,
      manufacturer: manufacturer ?? this.manufacturer,
      supplier: supplier ?? this.supplier,
      unitCost: unitCost ?? this.unitCost,
      applicationCost: applicationCost ?? this.applicationCost,
      unit: unit ?? this.unit,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, activeIngredient: $activeIngredient, concentration: $concentration)';
  }
}