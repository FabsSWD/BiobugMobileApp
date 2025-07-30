import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/injection/injection.dart';
import '../../../../shared/themes/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../bloc/alert_state.dart';
import '../bloc/inventory_bloc.dart';
import '../bloc/inventory_event.dart';
import '../bloc/inventory_state.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/alert_bloc.dart';
import '../bloc/alert_event.dart';
import '../widgets/inventory_stat_card.dart';
import '../widgets/inventory_chart.dart';
import '../widgets/recent_alerts_list.dart';
import '../widgets/quick_actions_grid.dart';

class InventoryOverviewPage extends StatelessWidget {
  static const String routeName = '/inventory';

  const InventoryOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<InventoryBloc>()..add(LoadInventory())),
        BlocProvider(create: (context) => getIt<ProductBloc>()..add(LoadExpiringProducts(30))),
        BlocProvider(create: (context) => getIt<AlertBloc>()..add(LoadAlerts())),
      ],
      child: const InventoryOverviewView(),
    );
  }
}

class InventoryOverviewView extends StatelessWidget {
  const InventoryOverviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Control de Inventario',
        backgroundColor: AppColors.primary,
        showBackButton: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<InventoryBloc>().add(RefreshInventory());
          context.read<ProductBloc>().add(LoadExpiringProducts(30));
          context.read<AlertBloc>().add(LoadAlerts());
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Cards
              BlocBuilder<InventoryBloc, InventoryState>(
                builder: (context, state) {
                  if (state is InventoryLoaded) {
                    return Row(
                      children: [
                        Expanded(
                          child: InventoryStatCard(
                            title: 'Valor Total',
                            value: '\$${state.totalValue.toStringAsFixed(2)}',
                            icon: Icons.monetization_on,
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InventoryStatCard(
                            title: 'Stock Bajo',
                            value: '${state.lowStockCount}',
                            icon: Icons.warning,
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    );
                  }
                  return const SizedBox(height: 120);
                },
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: InventoryStatCard(
                      title: 'Productos Activos',
                      value: '0', // This would come from ProductBloc
                      icon: Icons.inventory_2,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: BlocBuilder<AlertBloc, AlertState>(
                      builder: (context, state) {
                        final alertCount = state is AlertLoaded ? state.alerts.length : 0;
                        return InventoryStatCard(
                          title: 'Alertas',
                          value: '$alertCount',
                          icon: Icons.notifications,
                          color: AppColors.error,
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Chart Section
              Text(
                'Evolución del Inventario',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const InventoryChart(),

              const SizedBox(height: 24),

              // Recent Alerts
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Alertas Recientes',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/inventory/alerts'),
                    child: const Text('Ver todas'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const RecentAlertsList(),

              const SizedBox(height: 24),

              // Quick Actions
              Text(
                'Acciones Rápidas',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const QuickActionsGrid(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}