enum InventoryAlertPriority {
  low,
  medium,
  high,
  critical,
}

extension InventoryAlertPriorityExtension on InventoryAlertPriority {
  String get displayName {
    switch (this) {
      case InventoryAlertPriority.low:
        return 'Baja';
      case InventoryAlertPriority.medium:
        return 'Media';
      case InventoryAlertPriority.high:
        return 'Alta';
      case InventoryAlertPriority.critical:
        return 'Crítica';
    }
  }

  String get colorCode {
    switch (this) {
      case InventoryAlertPriority.low:
        return 'blue';
      case InventoryAlertPriority.medium:
        return 'yellow';
      case InventoryAlertPriority.high:
        return 'orange';
      case InventoryAlertPriority.critical:
        return 'red';
    }
  }
}