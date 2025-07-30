import 'package:flutter/material.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/entities/product.dart';
import '../../../../shared/themes/app_colors.dart';

class AddToInventoryModal extends StatefulWidget {
  final Product product;
  final Function(InventoryItem) onAddToInventory;

  const AddToInventoryModal({
    super.key,
    required this.product,
    required this.onAddToInventory,
  });

  @override
  State<AddToInventoryModal> createState() => _AddToInventoryModalState();
}

class _AddToInventoryModalState extends State<AddToInventoryModal> {
  final _formKey = GlobalKey<FormState>();
  double _quantity = 0.0;
  String _location = '';
  String _batchNumber = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Agregar ${widget.product.name} al inventario'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Cantidad',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese una cantidad';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Ingrese una cantidad válida';
                  }
                  return null;
                },
                onSaved: (value) {
                  _quantity = double.parse(value!);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Ubicación',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese una ubicación';
                  }
                  return null;
                },
                onSaved: (value) {
                  _location = value!;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Número de lote',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese un número de lote';
                  }
                  return null;
                },
                onSaved: (value) {
                  _batchNumber = value!;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              final inventoryItem = InventoryItem(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                productId: widget.product.id,
                currentStock: _quantity,
                minimumStock: 0,
                maximumStock: 999999.0,
                location: _location,
                batchNumber: _batchNumber,
                lastUpdated: DateTime.now(),
                lastUpdatedBy: 'user',
              );
              widget.onAddToInventory(inventoryItem);
              Navigator.of(context).pop();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
          ),
          child: const Text('Agregar'),
        ),
      ],
    );
  }
}