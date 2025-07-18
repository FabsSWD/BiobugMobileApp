import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/inventory_item.dart';
import 'product_model.dart';

part 'inventory_item_model.g.dart';

@JsonSerializable()
class InventoryItemModel extends InventoryItem {
  @JsonKey(name: 'product')
  final ProductModel? productModel;

  const InventoryItemModel({
    required super.id,
    required super.productId,
    this.productModel,
    required super.currentStock,
    required super.minimumStock,
    required super.maximumStock,
    required super.location,
    required super.batchNumber,
    required super.lastUpdated,
    required super.lastUpdatedBy,
  }) : super(product: productModel);

  factory InventoryItemModel.fromJson(Map<String, dynamic> json) => _$InventoryItemModelFromJson(json);
  Map<String, dynamic> toJson() => _$InventoryItemModelToJson(this);

  factory InventoryItemModel.fromEntity(InventoryItem item) {
    return InventoryItemModel(
      id: item.id,
      productId: item.productId,
      productModel: item.product != null ? ProductModel.fromEntity(item.product!) : null,
      currentStock: item.currentStock,
      minimumStock: item.minimumStock,
      maximumStock: item.maximumStock,
      location: item.location,
      batchNumber: item.batchNumber,
      lastUpdated: item.lastUpdated,
      lastUpdatedBy: item.lastUpdatedBy,
    );
  }

  InventoryItem toEntity() {
    return InventoryItem(
      id: id,
      productId: productId,
      product: productModel?.toEntity(),
      currentStock: currentStock,
      minimumStock: minimumStock,
      maximumStock: maximumStock,
      location: location,
      batchNumber: batchNumber,
      lastUpdated: lastUpdated,
      lastUpdatedBy: lastUpdatedBy,
    );
  }
}