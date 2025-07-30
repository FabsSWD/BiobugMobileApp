import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/injection/injection.dart';
import '../../../../shared/themes/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../widgets/toxicological_badge.dart';

class ProductDetailPage extends StatelessWidget {
  final String productId;

  const ProductDetailPage({
    super.key,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ProductBloc>()..add(LoadProductDetail(productId)),
      child: ProductDetailView(productId: productId),
    );
  }
}

class ProductDetailView extends StatelessWidget {
  final String productId;

  const ProductDetailView({
    super.key,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductBloc, ProductState>(
      listener: (context, state) {
        if (state is ProductError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Detalle del Producto',
          actions: [
            BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state is ProductDetailLoaded) {
                  return PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'stock',
                        child: Row(
                          children: [
                            Icon(Icons.inventory),
                            SizedBox(width: 8),
                            Text('Ver Stock'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'movements',
                        child: Row(
                          children: [
                            Icon(Icons.swap_horiz),
                            SizedBox(width: 8),
                            Text('Movimientos'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          Navigator.pushNamed(
                            context,
                            '/inventory/products/edit',
                            arguments: state.product,
                          );
                          break;
                        case 'stock':
                          Navigator.pushNamed(context, '/inventory/stock');
                          break;
                        case 'movements':
                          // TODO: Navigate to movements page with product filter
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Movimientos próximamente'),
                            ),
                          );
                          break;
                      }
                    },
                  );
                }
                return const SizedBox();
              },
            ),
          ],
        ),
        body: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            if (state is ProductLoading) {
              return const LoadingWidget(message: 'Cargando producto...');
            }

            if (state is ProductDetailLoaded) {
              final product = state.product;
              final isExpired = product.expirationDate.isBefore(DateTime.now());
              final isExpiring = product.expirationDate.difference(DateTime.now()).inDays <= 30;
              
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card con información principal
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    product.name,
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                ToxicologicalBadge(
                                  classification: product.toxicologicalClassification,
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 8),
                            
                            Text(
                              product.activeIngredient,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Status indicators
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: product.isActive ? AppColors.success : AppColors.grey400,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    product.isActive ? 'ACTIVO' : 'INACTIVO',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (isExpired)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Información del producto
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Información del Producto',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildDetailRow(
                              context,
                              'Concentración',
                              '${product.concentration}%',
                            ),
                            _buildDetailRow(
                              context,
                              'Formulación',
                              product.formulation,
                            ),
                            _buildDetailRow(
                              context,
                              'Registro Sanitario',
                              product.sanitaryRegistryNumber,
                            ),
                            _buildDetailRow(
                              context,
                              'Fecha de Vencimiento',
                              '${product.expirationDate.day}/${product.expirationDate.month}/${product.expirationDate.year}',
                            ),
                            _buildDetailRow(
                              context,
                              'Unidad',
                              product.unit,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Información comercial
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Información Comercial',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildDetailRow(
                              context,
                              'Fabricante',
                              product.manufacturer,
                            ),
                            _buildDetailRow(
                              context,
                              'Proveedor',
                              product.supplier,
                            ),
                            _buildDetailRow(
                              context,
                              'Costo Unitario',
                              '\$${product.unitCost.toStringAsFixed(2)} / ${product.unit}',
                            ),
                            _buildDetailRow(
                              context,
                              'Costo de Aplicación',
                              '\$${product.applicationCost.toStringAsFixed(2)}',
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Descripción (solo si existe)
                    if (product.description.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Descripción',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                product.description,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 16),
                    
                    // Información de auditoría
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Información del Sistema',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildDetailRow(
                              context,
                              'Creado',
                              '${product.createdAt.day}/${product.createdAt.month}/${product.createdAt.year}',
                            ),
                            _buildDetailRow(
                              context,
                              'Última Actualización',
                              '${product.updatedAt.day}/${product.updatedAt.month}/${product.updatedAt.year}',
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 100), // Espacio para el FAB
                  ],
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
                      'Error al cargar producto',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ProductBloc>().add(LoadProductDetail(productId));
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox();
          },
        ),
        floatingActionButton: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            if (state is ProductDetailLoaded) {
              return FloatingActionButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/inventory/products/edit',
                    arguments: state.product,
                  );
                },
                child: const Icon(Icons.edit),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}