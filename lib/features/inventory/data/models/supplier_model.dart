import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/supplier.dart';

part 'supplier_model.g.dart';

@JsonSerializable()
class SupplierModel extends Supplier {
  const SupplierModel({
    required super.id,
    required super.name,
    required super.contactPerson,
    required super.email,
    required super.phone,
    required super.address,
    super.website,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
    super.notes,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) => _$SupplierModelFromJson(json);
  Map<String, dynamic> toJson() => _$SupplierModelToJson(this);

  factory SupplierModel.fromEntity(Supplier supplier) {
    return SupplierModel(
      id: supplier.id,
      name: supplier.name,
      contactPerson: supplier.contactPerson,
      email: supplier.email,
      phone: supplier.phone,
      address: supplier.address,
      website: supplier.website,
      isActive: supplier.isActive,
      createdAt: supplier.createdAt,
      updatedAt: supplier.updatedAt,
      notes: supplier.notes,
    );
  }

  Supplier toEntity() {
    return Supplier(
      id: id,
      name: name,
      contactPerson: contactPerson,
      email: email,
      phone: phone,
      address: address,
      website: website,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      notes: notes,
    );
  }
}