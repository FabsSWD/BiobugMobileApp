import 'package:flutter/material.dart';
import '../../../../shared/themes/app_colors.dart';
import '../../domain/entities/inventory_item.dart';
import 'stock_level_indicator.dart';

class InventoryItemCard extends StatelessWidget {
  final InventoryItem inventoryItem;
  final VoidCallback? onTap;
  final Function(double)? onStockAdjustment;

  const InventoryItemCard({
    super.key,
    required this.inventoryItem,
    this.onTap,
    this.onStockAdjustment,
  });

  @override
  Widget build(BuildContext context) {
    final isLowStock = inventoryItem.currentStock <= inventoryItem.minimumStock;
    final isOutOfStock = inventoryItem.currentStock <= 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          inventoryItem.productId, // In real app, this would be product name
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (inventoryItem.location.isNotEmpty)
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                inventoryItem.location,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  if (isOutOfStock)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'SIN STOCK',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else if (isLowStock)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'STOCK BAJO',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              StockLevelIndicator(
                currentStock: inventoryItem.currentStock,
                minimumStock: inventoryItem.minimumStock,
                maximumStock: inventoryItem.maximumStock,
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  // ignore: unnecessary_null_comparison
                  if (inventoryItem.batchNumber != null) ...[
                    Icon(
                      Icons.qr_code,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Lote: ${inventoryItem.batchNumber}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const Spacer(),
                  ],
                  Text(
                    'Actualizado: ${_formatDate(inventoryItem.lastUpdated)}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              if (onStockAdjustment != null) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => onStockAdjustment?.call(inventoryItem.currentStock),
                      icon: const Icon(Icons.tune, size: 16),
                      label: const Text('Ajustar Stock'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}