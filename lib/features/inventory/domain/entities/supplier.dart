import 'package:equatable/equatable.dart';

class Supplier extends Equatable {
  final String id;
  final String name;
  final String contactPerson;
  final String email;
  final String phone;
  final String address;
  final String? website;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;

  const Supplier({
    required this.id,
    required this.name,
    required this.contactPerson,
    required this.email,
    required this.phone,
    required this.address,
    this.website,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        contactPerson,
        email,
        phone,
        address,
        website,
        isActive,
        createdAt,
        updatedAt,
        notes,
      ];

  Supplier copyWith({
    String? id,
    String? name,
    String? contactPerson,
    String? email,
    String? phone,
    String? address,
    String? website,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      contactPerson: contactPerson ?? this.contactPerson,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      website: website ?? this.website,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'Supplier(id: $id, name: $name, contactPerson: $contactPerson)';
  }
}