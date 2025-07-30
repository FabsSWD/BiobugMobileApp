import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/injection/injection.dart';
import '../../../../shared/themes/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../domain/entities/inventory_item.dart';
import '../bloc/inventory_state.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../bloc/inventory_bloc.dart';
import '../bloc/inventory_event.dart';
import '../bloc/stock_movement_bloc.dart';
import '../bloc/stock_movement_event.dart';
import '../widgets/product_card.dart';
import '../widgets/product_search_delegate.dart';
import '../widgets/add_to_inventory_modal.dart';
import '../widgets/manage_stock_modal.dart';

class ProductListPage extends StatefulWidget {
  static const String routeName = '/inventory/products';

  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  Map<String, InventoryItem> _inventoryItemsMap = {};

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<ProductBloc>()..add(LoadProducts())),
        BlocProvider(create: (context) => getIt<InventoryBloc>()..add(LoadInventory())),
        BlocProvider(create: (context) => getIt<StockMovementBloc>()),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<ProductBloc, ProductState>(
            listener: (context, state) {
              if (state is ProductError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                  ),
                );
              } else if (state is ProductCreated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Producto creado exitosamente'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } else if (state is ProductDeleted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Producto eliminado exitosamente'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
          ),
          BlocListener<InventoryBloc, InventoryState>(
            listener: (context, state) {
              if (state is InventoryLoaded) {
                setState(() {
                  _inventoryItemsMap = {
                    for (var item in state.inventoryItems) item.productId: item
                  };
                });
              } else if (state is InventoryError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
          ),
        ],
        child: Builder(
          builder: (context) => Scaffold(
            appBar: CustomAppBar(
              title: 'Productos',
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: ProductSearchDelegate(),
                    );
                  },
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'filter',
                      child: Row(
                        children: [
                          Icon(Icons.filter_list),
                          SizedBox(width: 8),
                          Text('Filtrar'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'expiring',
                      child: Row(
                        children: [
                          Icon(Icons.schedule),
                          SizedBox(width: 8),
                          Text('Próximos a vencer'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'without_inventory',
                      child: Row(
                        children: [
                          Icon(Icons.inventory_2_outlined),
                          SizedBox(width: 8),
                          Text('Sin inventario'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'with_inventory',
                      child: Row(
                        children: [
                          Icon(Icons.inventory),
                          SizedBox(width: 8),
                          Text('Con inventario'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'filter':
                        _showFilterDialog(context);
                        break;
                      case 'expiring':
                        context.read<ProductBloc>().add(LoadExpiringProducts(30));
                        break;
                      case 'without_inventory':
                        _filterProductsWithoutInventory();
                        break;
                      case 'with_inventory':
                        _filterProductsWithInventory();
                        break;
                    }
                  },
                ),
              ],
            ),
            body: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state is ProductLoading) {
                  return const LoadingWidget(message: 'Cargando productos...');
                }

                if (state is ProductLoaded) {
                  if (state.products.isEmpty) {
                    return EmptyStateWidget(
                      icon: Icons.inventory_2,
                      title: 'Sin productos',
                      message: 'No hay productos registrados.\nAgrega tu primer producto para comenzar.',
                      action: ElevatedButton.icon(
                        onPressed: () => Navigator.pushNamed(context, '/inventory/products/add'),
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar Producto'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<ProductBloc>().add(LoadProducts());
                      context.read<InventoryBloc>().add(RefreshInventory());
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.products.length,
                      itemBuilder: (context, index) {
                        final product = state.products[index];
                        final inventoryItem = _inventoryItemsMap[product.id];

                        return ProductCard(
                          product: product,
                          inventoryItem: inventoryItem,
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/inventory/products/detail',
                            arguments: product.id,
                          ),
                          onEdit: () => Navigator.pushNamed(
                            context,
                            '/inventory/products/edit',
                            arguments: product,
                          ),
                          onDelete: () => _showDeleteDialog(context, product.id),
                          onAddToInventory: () => _showAddToInventoryModal(context, product),
                          onManageStock: inventoryItem != null
                              ? () => _showManageStockModal(context, product, inventoryItem)
                              : null,
                        );
                      },
                    ),
                  );
                }

                if (state is ProductError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error al cargar productos',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.read<ProductBloc>().add(LoadProducts()),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                return const SizedBox();
              },
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => Navigator.pushNamed(context, '/inventory/products/add'),
              child: const Icon(Icons.add),
            ),
          ),
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrar Productos'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Opciones de filtro disponibles próximamente'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }

  void _filterProductsWithoutInventory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mostrando productos sin inventario configurado'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _filterProductsWithInventory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mostrando productos con inventario configurado'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String productId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: const Text('¿Estás seguro de que deseas eliminar este producto? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ProductBloc>().add(DeleteProductEvent(productId));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showAddToInventoryModal(BuildContext context, product) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<InventoryBloc>(),
        child: AddToInventoryModal(
          product: product,
          onAddToInventory: (inventoryItem) {
            context.read<InventoryBloc>().add(AddInventoryItemEvent(inventoryItem));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Producto agregado al inventario exitosamente'),
                backgroundColor: AppColors.success,
              ),
            );
          },
        ),
      ),
    );
  }

  void _showManageStockModal(BuildContext context, product, inventoryItem) {
    showDialog(
      context: context,
      builder: (context) => ManageStockModal(
        product: product,
        inventoryItem: inventoryItem,
        onStockMovement: (movement) {
          context.read<StockMovementBloc>().add(CreateStockMovementEvent(movement));
          final newStock = movement.isIncoming
              ? inventoryItem.currentStock + movement.quantity
              : inventoryItem.currentStock - movement.quantity;
          final updatedItem = inventoryItem.copyWith(
            currentStock: newStock,
            lastUpdated: DateTime.now(),
            lastUpdatedBy: 'user',
          );
          context.read<InventoryBloc>().add(UpdateInventoryItem(updatedItem));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                movement.isIncoming
                    ? 'Stock agregado exitosamente'
                    : 'Stock reducido exitosamente',
              ),
              backgroundColor: AppColors.success,
            ),
          );
        },
      ),
    );
  }
}