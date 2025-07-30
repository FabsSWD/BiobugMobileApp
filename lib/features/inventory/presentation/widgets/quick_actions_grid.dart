import 'package:flutter/material.dart';
import '../../../../shared/themes/app_colors.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildActionCard(
          context,
          'Agregar Producto',
          Icons.add_box,
          AppColors.primary,
          () => Navigator.pushNamed(context, '/inventory/products/add'),
        ),
        _buildActionCard(
          context,
          'Movimiento Stock',
          Icons.swap_horiz,
          AppColors.secondary,
          () => Navigator.pushNamed(context, '/inventory/stock/movements'),
        ),
        _buildActionCard(
          context,
          'Ver Inventario',
          Icons.inventory_2,
          AppColors.success,
          () => Navigator.pushNamed(context, '/inventory/stock'),
        ),
        _buildActionCard(
          context,
          'Reportes',
          Icons.analytics,
          AppColors.info,
          () => Navigator.pushNamed(context, '/inventory/reports'),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}