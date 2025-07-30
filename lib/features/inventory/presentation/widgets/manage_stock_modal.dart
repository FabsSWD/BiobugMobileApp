import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../../../shared/themes/app_colors.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/entities/stock_movement.dart';
import '../../domain/entities/stock_movement_type.dart';
import '../widgets/stock_level_indicator.dart';

class ManageStockModal extends StatefulWidget {
  final Product product;
  final InventoryItem inventoryItem;
  final Function(StockMovement) onStockMovement;

  const ManageStockModal({
    super.key,
    required this.product,
    required this.inventoryItem,
    required this.onStockMovement,
  });

  @override
  State<ManageStockModal> createState() => _ManageStockModalState();
}

class _ManageStockModalState extends State<ManageStockModal> {
  late FormGroup form;
  StockMovementType selectedType = StockMovementType.purchase;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    form = FormGroup({
      'type': FormControl<StockMovementType>(
        value: selectedType,
        validators: [Validators.required],
      ),
      'quantity': FormControl<double>(
        validators: [Validators.required, Validators.min(0.1)],
      ),
      'reason': FormControl<String>(
        validators: [Validators.required],
      ),
      'reference': FormControl<String>(),
      'notes': FormControl<String>(),
    });

    // Listen to type changes to update UI
    form.control('type').valueChanges.listen((type) {
      if (type != null) {
        setState(() {
          selectedType = type as StockMovementType;
        });
        _updateFormBasedOnType(type as StockMovementType);
      }
    });
  }

  void _updateFormBasedOnType(StockMovementType type) {
    final reasonControl = form.control('reason');
    
    switch (type) {
      case StockMovementType.purchase:
        reasonControl.value = 'Compra de inventario';
        break;
      case StockMovementType.consumption:
        reasonControl.value = 'Consumo en servicio';
        break;
      case StockMovementType.adjustment:
        reasonControl.value = 'Ajuste de inventario';
        break;
      case StockMovementType.waste:
        reasonControl.value = 'Producto dañado/vencido';
        break;
      case StockMovementType.transfer:
        reasonControl.value = 'Transferencia de ubicación';
        break;
      case StockMovementType.return_:
        reasonControl.value = 'Devolución';
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width > 600 
            ? 500 
            : MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(24),
        child: ReactiveForm(
          formGroup: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.tune,
                    color: AppColors.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gestionar Stock',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          widget.product.name,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Current Stock Status
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.grey200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estado Actual del Stock',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    StockLevelIndicator(
                      currentStock: widget.inventoryItem.currentStock,
                      minimumStock: widget.inventoryItem.minimumStock,
                      maximumStock: widget.inventoryItem.maximumStock,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Movement Type
              Text(
                'Tipo de Movimiento',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              ReactiveDropdownField<StockMovementType>(
                formControlName: 'type',
                decoration: const InputDecoration(
                  labelText: 'Tipo de Movimiento *',
                  suffixIcon: Icon(Icons.swap_horiz),
                ),
                items: StockMovementType.values.map((type) => DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(
                        _getIconForMovementType(type),
                        size: 20,
                        color: _getColorForMovementType(type),
                      ),
                      const SizedBox(width: 8),
                      Text(type.displayName),
                    ],
                  ),
                )).toList(),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: ReactiveTextField<double>(
                      formControlName: 'quantity',
                      decoration: InputDecoration(
                        labelText: 'Cantidad *',
                        helperText: _getHelperTextForType(selectedType),
                        suffixText: widget.product.unit,
                        suffixIcon: Icon(
                          selectedType.isIncoming ? Icons.add : Icons.remove,
                          color: selectedType.isIncoming ? AppColors.success : AppColors.error,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: selectedType.isIncoming 
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      selectedType.isIncoming ? Icons.arrow_upward : Icons.arrow_downward,
                      color: selectedType.isIncoming ? AppColors.success : AppColors.error,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              ReactiveTextField<String>(
                formControlName: 'reason',
                decoration: const InputDecoration(
                  labelText: 'Motivo *',
                  suffixIcon: Icon(Icons.description),
                ),
              ),

              const SizedBox(height: 16),

              if (selectedType == StockMovementType.purchase) ...[
                ReactiveTextField<String>(
                  formControlName: 'reference',
                  decoration: const InputDecoration(
                    labelText: 'Referencia (Factura/Orden)',
                    suffixIcon: Icon(Icons.receipt),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              ReactiveTextField<String>(
                formControlName: 'notes',
                decoration: const InputDecoration(
                  labelText: 'Notas Adicionales',
                  suffixIcon: Icon(Icons.note),
                ),
                maxLines: 2,
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _onSave,
                      icon: Icon(selectedType.isIncoming ? Icons.add : Icons.remove),
                      label: Text(selectedType.isIncoming ? 'Agregar Stock' : 'Reducir Stock'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedType.isIncoming ? AppColors.success : AppColors.warning,
                        foregroundColor: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForMovementType(StockMovementType type) {
    switch (type) {
      case StockMovementType.purchase:
        return Icons.shopping_cart;
      case StockMovementType.consumption:
        return Icons.science;
      case StockMovementType.adjustment:
        return Icons.tune;
      case StockMovementType.waste:
        return Icons.delete;
      case StockMovementType.transfer:
        return Icons.swap_horiz;
      case StockMovementType.return_:
        return Icons.undo;
    }
  }

  Color _getColorForMovementType(StockMovementType type) {
    return type.isIncoming ? AppColors.success : AppColors.error;
  }

  String _getHelperTextForType(StockMovementType type) {
    if (type.isIncoming) {
      return 'Cantidad a agregar al inventario';
    } else {
      return 'Cantidad a reducir del inventario (disponible: ${widget.inventoryItem.currentStock})';
    }
  }

  void _onSave() {
    if (form.valid) {
      final formValue = form.value;
      final quantity = formValue['quantity'] as double;
      
      // Validate that we have enough stock for outgoing movements
      if (!selectedType.isIncoming && quantity > widget.inventoryItem.currentStock) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Stock insuficiente. Disponible: ${widget.inventoryItem.currentStock}'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      final movement = StockMovement(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        inventoryItemId: widget.inventoryItem.id,
        productId: widget.product.id,
        type: selectedType,
        quantity: quantity,
        unitCost: widget.product.unitCost,
        totalCost: widget.product.unitCost * quantity,
        reason: formValue['reason'] as String,
        reference: formValue['reference'] as String?,
        createdAt: DateTime.now(),
        createdBy: 'user', // Esto vendría del contexto de autenticación
        notes: formValue['notes'] as String?,
      );

      widget.onStockMovement(movement);
      Navigator.of(context).pop();
    } else {
      form.markAllAsTouched();
    }
  }

  @override
  void dispose() {
    form.dispose();
    super.dispose();
  }
}