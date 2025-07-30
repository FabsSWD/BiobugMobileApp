import 'package:equatable/equatable.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/toxicological_classification.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductEvent {}

class LoadProductDetail extends ProductEvent {
  final String productId;

  const LoadProductDetail(this.productId);

  @override
  List<Object?> get props => [productId];
}

class SearchProductsEvent extends ProductEvent {
  final String query;

  const SearchProductsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterProducts extends ProductEvent {
  final String? supplier;
  final ToxicologicalClassification? classification;
  final bool? isActive;

  const FilterProducts({
    this.supplier,
    this.classification,
    this.isActive,
  });

  @override
  List<Object?> get props => [supplier, classification, isActive];
}

class CreateProduct extends ProductEvent {
  final Product product;

  const CreateProduct(this.product);

  @override
  List<Object?> get props => [product];
}

class UpdateProductEvent extends ProductEvent {
  final Product product;

  const UpdateProductEvent(this.product);

  @override
  List<Object?> get props => [product];
}

class DeleteProductEvent extends ProductEvent {
  final String productId;

  const DeleteProductEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}

class LoadExpiringProducts extends ProductEvent {
  final int daysThreshold;

  const LoadExpiringProducts(this.daysThreshold);

  @override
  List<Object?> get props => [daysThreshold];
}