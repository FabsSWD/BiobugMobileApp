import 'package:flutter/material.dart';
import '../../../../shared/themes/app_colors.dart';

class InventoryChart extends StatelessWidget {
  const InventoryChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildChartItem(
                  context,
                  'Ene',
                  0.8,
                  AppColors.primary,
                ),
                _buildChartItem(
                  context,
                  'Feb',
                  0.6,
                  AppColors.primary,
                ),
                _buildChartItem(
                  context,
                  'Mar',
                  0.9,
                  AppColors.primary,
                ),
                _buildChartItem(
                  context,
                  'Abr',
                  0.7,
                  AppColors.primary,
                ),
                _buildChartItem(
                  context,
                  'May',
                  0.5,
                  AppColors.primary,
                ),
                _buildChartItem(
                  context,
                  'Jun',
                  0.3,
                  AppColors.warning,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Últimos 6 meses',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartItem(BuildContext context, String label, double value, Color color) {
    return Column(
      children: [
        Container(
          height: 100,
          width: 20,
          decoration: BoxDecoration(
            color: AppColors.grey200,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: 100 * value,
                width: 20,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}