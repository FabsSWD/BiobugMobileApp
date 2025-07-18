enum StockStatus {
  outOfStock,
  lowStock,
  normal,
  overStock,
}

extension StockStatusExtension on StockStatus {
  String get displayName {
    switch (this) {
      case StockStatus.outOfStock:
        return 'Sin stock';
      case StockStatus.lowStock:
        return 'Stock bajo';
      case StockStatus.normal:
        return 'Stock normal';
      case StockStatus.overStock:
        return 'Sobre stock';
    }
  }

  String get colorCode {
    switch (this) {
      case StockStatus.outOfStock:
        return 'red';
      case StockStatus.lowStock:
        return 'orange';
      case StockStatus.normal:
        return 'green';
      case StockStatus.overStock:
        return 'blue';
    }
  }
}