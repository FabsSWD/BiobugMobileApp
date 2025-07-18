enum InventoryAlertType {
  lowStock,
  outOfStock,
  productExpiring,
  productExpired,
  overStock,
  negativeStock,
}

extension InventoryAlertTypeExtension on InventoryAlertType {
  String get displayName {
    switch (this) {
      case InventoryAlertType.lowStock:
        return 'Stock bajo';
      case InventoryAlertType.outOfStock:
        return 'Sin stock';
      case InventoryAlertType.productExpiring:
        return 'Producto próximo a vencer';
      case InventoryAlertType.productExpired:
        return 'Producto vencido';
      case InventoryAlertType.overStock:
        return 'Sobre stock';
      case InventoryAlertType.negativeStock:
        return 'Stock negativo';
    }
  }
}