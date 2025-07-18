enum StockMovementType {
  purchase, // Compra
  consumption, // Consumo en servicio
  adjustment, // Ajuste de inventario
  waste, // Desperdicio/merma
  transfer, // Transferencia entre ubicaciones
  return_, // Devolución
}

extension StockMovementTypeExtension on StockMovementType {
  String get displayName {
    switch (this) {
      case StockMovementType.purchase:
        return 'Compra';
      case StockMovementType.consumption:
        return 'Consumo';
      case StockMovementType.adjustment:
        return 'Ajuste';
      case StockMovementType.waste:
        return 'Desperdicio';
      case StockMovementType.transfer:
        return 'Transferencia';
      case StockMovementType.return_:
        return 'Devolución';
    }
  }

  bool get isIncoming {
    switch (this) {
      case StockMovementType.purchase:
      case StockMovementType.adjustment:
      case StockMovementType.return_:
        return true;
      case StockMovementType.consumption:
      case StockMovementType.waste:
      case StockMovementType.transfer:
        return false;
    }
  }
}