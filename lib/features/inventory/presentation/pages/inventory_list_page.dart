import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/injection/injection.dart';
import '../../../../shared/themes/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../bloc/inventory_bloc.dart';
import '../bloc/inventory_event.dart';
import '../bloc/inventory_state.dart';
import '../widgets/inventory_item_card.dart';

class InventoryListPage extends StatelessWidget {
  static const String routeName = '/inventory/stock';

  const InventoryListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<InventoryBloc>()..add(LoadInventory()),
      child: BlocListener<InventoryBloc, InventoryState>(
        listener: (context, state) {
          if (state is InventoryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is InventoryItemUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Stock actualizado exitosamente'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        child: Scaffold(
          appBar: CustomAppBar(
            title: 'Inventario de Stock',
            actions: [
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'all',
                    child: Text('Todos'),
                  ),
                  const PopupMenuItem(
                    value: 'low',
                    child: Text('Stock Bajo'),
                  ),
                  const PopupMenuItem(
                    value: 'out',
                    child: Text('Sin Stock'),
                  ),
                  const PopupMenuItem(
                    value: 'over',
                    child: Text('Sobrestock'),
                  ),
                ],
                onSelected: (value) {
                  if (value != 'all') {
                    // ignore: unnecessary_cast
                    context.read<InventoryBloc>().add(FilterInventoryByStockLevel(value as String));
                  } else {
                    context.read<InventoryBloc>().add(LoadInventory());
                  }
                },
              ),
            ],
          ),
          body: BlocBuilder<InventoryBloc, InventoryState>(
            builder: (context, state) {
              if (state is InventoryLoading) {
                return const LoadingWidget(message: 'Cargando inventario...');
              }

              if (state is InventoryLoaded) {
                if (state.inventoryItems.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.inventory,
                    title: 'Sin items de inventario',
                    message: 'No hay items de inventario registrados.\nAgrega productos primero.',
                    action: ElevatedButton.icon(        // ← Botón con icono
                      onPressed: () => Navigator.pushNamed(context, '/inventory/products'),
                      icon: const Icon(Icons.visibility),
                      label: const Text('Ver Productos'),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<InventoryBloc>().add(RefreshInventory());
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.inventoryItems.length,
                    itemBuilder: (context, index) {
                      final item = state.inventoryItems[index];
                      return InventoryItemCard(
                        inventoryItem: item,
                        onTap: () => _showStockAdjustmentDialog(context, item),
                        onStockAdjustment: (newStock) {
                          final updatedItem = item.copyWith(currentStock: newStock);
                          context.read<InventoryBloc>().add(UpdateInventoryItem(updatedItem));
                        },
                      );
                    },
                  ),
                );
              }

              return const Center(
                child: Text('Estado no reconocido'),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showStockAdjustmentDialog(BuildContext context, item) {
    final controller = TextEditingController(text: item.currentStock.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajustar Stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Stock actual: ${item.currentStock}'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nuevo stock',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final newStock = double.tryParse(controller.text) ?? item.currentStock;
              Navigator.of(context).pop();
              
              final updatedItem = item.copyWith(currentStock: newStock);
              context.read<InventoryBloc>().add(UpdateInventoryItem(updatedItem));
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }
}