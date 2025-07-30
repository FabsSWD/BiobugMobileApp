import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/injection/injection.dart';
import '../../../../shared/themes/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../bloc/inventory_bloc.dart';
import '../bloc/inventory_event.dart';
import '../bloc/inventory_state.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';

class InventoryReportsPage extends StatelessWidget {
  static const String routeName = '/inventory/reports';

  const InventoryReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<InventoryBloc>()..add(LoadInventory())),
        BlocProvider(create: (context) => getIt<ProductBloc>()..add(LoadProducts())),
      ],
      child: const InventoryReportsView(),
    );
  }
}

class InventoryReportsView extends StatelessWidget {
  const InventoryReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Reportes de Inventario',
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<InventoryBloc>().add(RefreshInventory());
          context.read<ProductBloc>().add(LoadProducts());
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Resumen ejecutivo
              _buildExecutiveSummary(context),
              
              const SizedBox(height: 24),
              
              // Reportes disponibles
              Text(
                'Reportes Disponibles',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildReportsGrid(context),
              
              const SizedBox(height: 24),
              
              // Alertas y notificaciones
              Text(
                'Estado del Inventario',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildInventoryStatus(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExecutiveSummary(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen Ejecutivo',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            BlocBuilder<InventoryBloc, InventoryState>(
              builder: (context, inventoryState) {
                return BlocBuilder<ProductBloc, ProductState>(
                  builder: (context, productState) {
                    if (inventoryState is InventoryLoaded && productState is ProductLoaded) {
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildSummaryItem(
                                  context,
                                  'Valor Total',
                                  '\$${inventoryState.totalValue.toStringAsFixed(2)}',
                                  Icons.monetization_on,
                                  AppColors.success,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildSummaryItem(
                                  context,
                                  'Productos',
                                  '${productState.products.length}',
                                  Icons.inventory_2,
                                  AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildSummaryItem(
                                  context,
                                  'Stock Bajo',
                                  '${inventoryState.lowStockCount}',
                                  Icons.warning,
                                  AppColors.warning,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildSummaryItem(
                                  context,
                                  'Alertas',
                                  '${inventoryState.alertsCount}',
                                  Icons.notifications,
                                  AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }
                    
                    if (inventoryState is InventoryLoading || productState is ProductLoading) {
                      return const SizedBox(
                        height: 100,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    
                    return const SizedBox(
                      height: 100,
                      child: Center(child: Text('Error al cargar datos')),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildReportCard(
          context,
          'Consumo por Período',
          'Análisis de consumo mensual y tendencias',
          Icons.trending_down,
          AppColors.primary,
          () => _showConsumptionReport(context),
        ),
        _buildReportCard(
          context,
          'Valor del Inventario',
          'Valor total y distribución por producto',
          Icons.monetization_on,
          AppColors.success,
          () => _showValueReport(context),
        ),
        _buildReportCard(
          context,
          'Productos por Vencer',
          'Lista de productos próximos a vencer',
          Icons.schedule,
          AppColors.warning,
          () => _showExpiringProducts(context),
        ),
        _buildReportCard(
          context,
          'Stock Crítico',
          'Productos con stock bajo o agotado',
          Icons.inventory,
          AppColors.error,
          () => _showCriticalStock(context),
        ),
        _buildReportCard(
          context,
          'Análisis por Proveedor',
          'Distribución de productos por proveedor',
          Icons.business,
          AppColors.info,
          () => _showSupplierAnalysis(context),
        ),
        _buildReportCard(
          context,
          'Movimientos de Stock',
          'Historial de entradas y salidas',
          Icons.swap_horiz,
          AppColors.secondary,
          () => _showStockMovements(context),
        ),
      ],
    );
  }

  Widget _buildReportCard(
    BuildContext context,
    String title,
    String description,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 24,
                    color: color,
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInventoryStatus(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is ProductLoaded) {
          final products = state.products;
          final activeProducts = products.where((p) => p.isActive).length;
          final expiredProducts = products.where((p) => p.expirationDate.isBefore(DateTime.now())).length;
          final expiringProducts = products.where((p) {
            final daysUntilExpiration = p.expirationDate.difference(DateTime.now()).inDays;
            return daysUntilExpiration <= 30 && daysUntilExpiration >= 0;
          }).length;

          return Column(
            children: [
              _buildStatusCard(
                context,
                'Productos Activos',
                '$activeProducts de ${products.length}',
                Icons.check_circle,
                AppColors.success,
                () => Navigator.pushNamed(context, '/inventory/products'),
              ),
              const SizedBox(height: 12),
              if (expiringProducts > 0)
                _buildStatusCard(
                  context,
                  'Productos por Vencer',
                  '$expiringProducts productos en los próximos 30 días',
                  Icons.schedule,
                  AppColors.warning,
                  () => _showExpiringProducts(context),
                ),
              const SizedBox(height: 12),
              if (expiredProducts > 0)
                _buildStatusCard(
                  context,
                  'Productos Vencidos',
                  '$expiredProducts productos vencidos',
                  Icons.error,
                  AppColors.error,
                  () => _showExpiredProducts(context),
                ),
            ],
          );
        }

        if (state is ProductLoading) {
          return const LoadingWidget(message: 'Analizando inventario...');
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    String title,
    String description,
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
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Métodos para mostrar reportes específicos
  void _showConsumptionReport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reporte de Consumo'),
        content: const Text(
          'Esta funcionalidad estará disponible próximamente.\n\n'
          'El reporte mostrará:\n'
          '• Consumo mensual por producto\n'
          '• Tendencias de uso\n'
          '• Proyecciones de demanda',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showValueReport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reporte de Valor'),
        content: const Text(
          'Esta funcionalidad estará disponible próximamente.\n\n'
          'El reporte mostrará:\n'
          '• Valor total del inventario\n'
          '• Distribución por categoría\n'
          '• Análisis de rotación',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showExpiringProducts(BuildContext context) {
    context.read<ProductBloc>().add(LoadExpiringProducts(30));
    Navigator.pushNamed(context, '/inventory/products');
  }

  void _showExpiredProducts(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Productos Vencidos'),
        content: const Text(
          'Se recomienda revisar y retirar los productos vencidos del inventario.\n\n'
          'Navegue a la lista de productos para ver los detalles.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/inventory/products');
            },
            child: const Text('Ver Productos'),
          ),
        ],
      ),
    );
  }

  void _showCriticalStock(BuildContext context) {
    Navigator.pushNamed(context, '/inventory/stock');
  }

  void _showSupplierAnalysis(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Análisis por Proveedor'),
        content: const Text(
          'Esta funcionalidad estará disponible próximamente.\n\n'
          'El análisis mostrará:\n'
          '• Productos por proveedor\n'
          '• Evaluación de proveedores\n'
          '• Análisis de costos',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showStockMovements(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Movimientos de Stock'),
        content: const Text(
          'Esta funcionalidad estará disponible próximamente.\n\n'
          'El reporte mostrará:\n'
          '• Historial de movimientos\n'
          '• Entradas y salidas\n'
          '• Análisis de rotación',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}