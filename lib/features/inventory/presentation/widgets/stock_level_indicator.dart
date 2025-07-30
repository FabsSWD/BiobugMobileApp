import 'package:flutter/material.dart';
import '../../../../shared/themes/app_colors.dart';

class StockLevelIndicator extends StatelessWidget {
  final double currentStock;
  final double minimumStock;
  final double maximumStock;
  final bool showValues;

  const StockLevelIndicator({
    super.key,
    required this.currentStock,
    required this.minimumStock,
    required this.maximumStock,
    this.showValues = true,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = maximumStock > 0 ? (currentStock / maximumStock).clamp(0.0, 1.0) : 0.0;
    final color = _getColorForStockLevel(currentStock, minimumStock, maximumStock);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showValues) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Stock: ${currentStock.toStringAsFixed(1)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                'Máx: ${maximumStock.toStringAsFixed(1)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.grey200,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        if (showValues) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                width: 8,
                height: 2,
                color: AppColors.warning,
              ),
              const SizedBox(width: 4),
              Text(
                'Mín: ${minimumStock.toStringAsFixed(1)}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Color _getColorForStockLevel(double current, double minimum, double maximum) {
    if (current <= 0) return AppColors.error;
    if (current <= minimum) return AppColors.warning;
    if (current > maximum * 0.8) return AppColors.success;
    return AppColors.info;
  }
}