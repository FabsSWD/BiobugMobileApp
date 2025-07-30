import 'package:flutter/material.dart';
import '../../../../shared/themes/app_colors.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/inventory_item.dart';
import 'toxicological_badge.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final InventoryItem? inventoryItem; // Nuevo parámetro opcional
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onAddToInventory; // Nueva acción
  final VoidCallback? onManageStock; // Nueva acción

  const ProductCard({
    super.key,
    required this.product,
    this.inventoryItem,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onAddToInventory,
    this.onManageStock,
  });

  @override
  Widget build(BuildContext context) {
    final isExpiring = product.expirationDate.difference(DateTime.now()).inDays <= 30;
    final isExpired = product.expirationDate.isBefore(DateTime.now());
    final hasInventory = inventoryItem != null;

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
                          product.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.activeIngredient,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ToxicologicalBadge(classification: product.toxicologicalClassification),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Stock Status Row
              if (hasInventory) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getStockStatusColor(inventoryItem!).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getStockStatusColor(inventoryItem!).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getStockStatusIcon(inventoryItem!),
                        size: 16,
                        color: _getStockStatusColor(inventoryItem!),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Stock: ${inventoryItem!.currentStock.toStringAsFixed(1)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getStockStatusColor(inventoryItem!),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _getStockStatusText(inventoryItem!),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getStockStatusColor(inventoryItem!),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ] else ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.warning.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 16,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Sin inventario configurado',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
              
              Row(
                children: [
                  Icon(
                    Icons.science,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${product.concentration}% ${product.formulation}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.business,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      product.manufacturer,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              Row(
                children: [
                  Icon(
                    Icons.monetization_on,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  // 🔧 ARREGLO: Envuelto en Expanded para evitar overflow
                  Expanded(
                    child: Text(
                      '\$${product.unitCost.toStringAsFixed(2)}/${product.unit}',
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis, // 🔧 Truncar si es muy largo
                    ),
                  ),
                  if (isExpired)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'VENCIDO',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else if (isExpiring)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'POR VENCER',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              const Divider(height: 1),
              
              // 🔧 SOLUCIÓN PRINCIPAL: Action Buttons con Wrap para evitar overflow
              Wrap(
                spacing: 8, // Espacio horizontal entre botones
                runSpacing: 8, // Espacio vertical si se van a nueva línea
                alignment: WrapAlignment.spaceBetween,
                children: [
                  // Left side actions
                  Row(
                    mainAxisSize: MainAxisSize.min, // 🔧 Importante: solo usar espacio necesario
                    children: [
                      if (onEdit != null)
                        TextButton.icon(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Editar'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // 🔧 Reducir padding
                          ),
                        ),
                      if (onDelete != null)
                        TextButton.icon(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete, size: 16),
                          label: const Text('Eliminar'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.error,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // 🔧 Reducir padding
                          ),
                        ),
                    ],
                  ),
                  
                  // Right side - Stock actions
                  if (hasInventory)
                    ElevatedButton.icon(
                      onPressed: onManageStock,
                      icon: const Icon(Icons.tune, size: 16),
                      label: const Text('Stock'),  // 🔧 Texto más corto
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), // 🔧 Reducir padding
                      ),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: onAddToInventory,
                      icon: const Icon(Icons.add_box, size: 16),
                      label: const Text('Inventario'), // 🔧 Texto más corto
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), // 🔧 Reducir padding
                      ),
                    ),
                ],
              ),
              
              // 🔧 ALTERNATIVA: Si Wrap no funciona, usar Column en pantallas pequeñas
              // _buildResponsiveActionButtons(context, hasInventory),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStockStatusColor(InventoryItem item) {
    if (item.currentStock <= 0) return AppColors.error;
    if (item.currentStock <= item.minimumStock) return AppColors.warning;
    if (item.currentStock > item.maximumStock) return AppColors.info;
    return AppColors.success;
  }

  IconData _getStockStatusIcon(InventoryItem item) {
    if (item.currentStock <= 0) return Icons.error;
    if (item.currentStock <= item.minimumStock) return Icons.warning;
    if (item.currentStock > item.maximumStock) return Icons.trending_up;
    return Icons.check_circle;
  }

  String _getStockStatusText(InventoryItem item) {
    if (item.currentStock <= 0) return 'SIN STOCK';
    if (item.currentStock <= item.minimumStock) return 'STOCK BAJO';
    if (item.currentStock > item.maximumStock) return 'SOBRESTOCK';
    return 'NORMAL';
  }
}