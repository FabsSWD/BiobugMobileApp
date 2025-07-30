import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../../../core/injection/injection.dart';
import '../../../../shared/themes/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/toxicological_classification.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../widgets/toxicological_badge.dart';

class ProductFormPageArguments {
  final Product? product; // null for create, Product instance for edit
  final bool isEdit;

  ProductFormPageArguments({
    this.product,
    this.isEdit = false,
  });
}

class ProductFormPage extends StatelessWidget {
  static const String routeName = '/inventory/products/form';

  const ProductFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as ProductFormPageArguments?;
    
    return BlocProvider(
      create: (context) => getIt<ProductBloc>(),
      child: ProductFormView(
        product: args?.product,
        isEdit: args?.isEdit ?? false,
      ),
    );
  }
}

class ProductFormView extends StatefulWidget {
  final Product? product;
  final bool isEdit;

  const ProductFormView({
    super.key,
    this.product,
    required this.isEdit,
  });

  @override
  State<ProductFormView> createState() => _ProductFormViewState();
}

class _ProductFormViewState extends State<ProductFormView> {
  late FormGroup form;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    form = FormGroup({
      'name': FormControl<String>(
        value: widget.product?.name ?? '',
        validators: [Validators.required],
      ),
      'activeIngredient': FormControl<String>(
        value: widget.product?.activeIngredient ?? '',
        validators: [Validators.required],
      ),
      'concentration': FormControl<double>(
        value: widget.product?.concentration ?? 0.0,
        validators: [Validators.required, Validators.min(0)],
      ),
      'formulation': FormControl<String>(
        value: widget.product?.formulation ?? '',
        validators: [Validators.required],
      ),
      'sanitaryRegistryNumber': FormControl<String>(
        value: widget.product?.sanitaryRegistryNumber ?? '',
        validators: [Validators.required],
      ),
      'expirationDate': FormControl<DateTime>(
        value: widget.product?.expirationDate ?? DateTime.now().add(const Duration(days: 365)),
        validators: [Validators.required],
      ),
      'toxicologicalClassification': FormControl<ToxicologicalClassification>(
        value: widget.product?.toxicologicalClassification ?? ToxicologicalClassification.u,
        validators: [Validators.required],
      ),
      'manufacturer': FormControl<String>(
        value: widget.product?.manufacturer ?? '',
        validators: [Validators.required],
      ),
      'supplier': FormControl<String>(
        value: widget.product?.supplier ?? '',
        validators: [Validators.required],
      ),
      'unitCost': FormControl<double>(
        value: widget.product?.unitCost ?? 0.0,
        validators: [Validators.required, Validators.min(0)],
      ),
      'applicationCost': FormControl<double>(
        value: widget.product?.applicationCost ?? 0.0,
        validators: [Validators.required, Validators.min(0)],
      ),
      'unit': FormControl<String>(
        value: widget.product?.unit ?? 'L',
        validators: [Validators.required],
      ),
      'description': FormControl<String>(
        value: widget.product?.description ?? '',
      ),
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductBloc, ProductState>(
      listener: (context, state) {
        if (state is ProductCreated || state is ProductUpdated) {
          Navigator.of(context).pop();
        } else if (state is ProductError) {
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
          title: widget.isEdit ? 'Editar Producto' : 'Nuevo Producto',
        ),
        body: ReactiveForm(
          formGroup: form,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic Information
                _buildSectionTitle('Información Básica'),
                const SizedBox(height: 16),
                ReactiveTextField<String>(
                  formControlName: 'name',
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Producto *',
                    hintText: 'Ej: Insecticida XYZ',
                  ),
                ),
                const SizedBox(height: 16),
                ReactiveTextField<String>(
                  formControlName: 'activeIngredient',
                  decoration: const InputDecoration(
                    labelText: 'Ingrediente Activo *',
                    hintText: 'Ej: Cipermetrina',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: ReactiveTextField<double>(
                        formControlName: 'concentration',
                        decoration: const InputDecoration(
                          labelText: 'Concentración *',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ReactiveTextField<String>(
                        formControlName: 'formulation',
                        decoration: const InputDecoration(
                          labelText: 'Formulación *',
                          hintText: 'EC, WP, etc.',
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Classification and Registration
                _buildSectionTitle('Clasificación y Registro'),
                const SizedBox(height: 16),
                ReactiveDropdownField<ToxicologicalClassification>(
                  formControlName: 'toxicologicalClassification',
                  decoration: const InputDecoration(
                    labelText: 'Clasificación Toxicológica *',
                  ),
                  items: ToxicologicalClassification.values
                      .map((classification) => DropdownMenuItem(
                            value: classification,
                            // 🔧 ARREGLO FINAL: Solo Row sin SizedBox wrapper
                            child: Row(
                              mainAxisSize: MainAxisSize.min, // 🔧 Crucial: usa solo el espacio necesario
                              children: [
                                ToxicologicalBadge(classification: classification),
                                const SizedBox(width: 8),
                                // 🔧 Text simple sin Flexible/Expanded para evitar problemas
                                Text(
                                  classification.displayName,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),
                ReactiveTextField<String>(
                  formControlName: 'sanitaryRegistryNumber',
                  decoration: const InputDecoration(
                    labelText: 'Número de Registro Sanitario *',
                  ),
                ),
                const SizedBox(height: 16),
                ReactiveDatePicker<DateTime>(
                  formControlName: 'expirationDate',
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
                  builder: (context, picker, child) {
                    return ReactiveTextField<DateTime>(
                      formControlName: 'expirationDate',
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Fecha de Vencimiento *',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: (control) => picker.showPicker(),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Supplier and Costs
                _buildSectionTitle('Proveedor y Costos'),
                const SizedBox(height: 16),
                ReactiveTextField<String>(
                  formControlName: 'manufacturer',
                  decoration: const InputDecoration(
                    labelText: 'Fabricante *',
                  ),
                ),
                const SizedBox(height: 16),
                ReactiveTextField<String>(
                  formControlName: 'supplier',
                  decoration: const InputDecoration(
                    labelText: 'Proveedor *',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ReactiveTextField<double>(
                        formControlName: 'unitCost',
                        decoration: const InputDecoration(
                          labelText: 'Costo Unitario *',
                          prefixText: '\$',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ReactiveTextField<String>(
                        formControlName: 'unit',
                        decoration: const InputDecoration(
                          labelText: 'Unidad *',
                          hintText: 'L, Kg, etc.',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ReactiveTextField<double>(
                  formControlName: 'applicationCost',
                  decoration: const InputDecoration(
                    labelText: 'Costo de Aplicación *',
                    prefixText: '\$',
                    helperText: 'Costo por aplicación/uso',
                  ),
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 24),

                // Description
                _buildSectionTitle('Descripción'),
                const SizedBox(height: 16),
                ReactiveTextField<String>(
                  formControlName: 'description',
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    hintText: 'Información adicional del producto...',
                  ),
                  maxLines: 3,
                ),

                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: BlocBuilder<ProductBloc, ProductState>(
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: state is ProductLoading ? null : _onSave,
                        child: state is ProductLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(widget.isEdit ? 'Actualizar Producto' : 'Crear Producto'),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  void _onSave() {
    if (form.valid) {
      final formValue = form.value;
      
      final product = Product(
        id: widget.product?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: formValue['name'] as String,
        activeIngredient: formValue['activeIngredient'] as String,
        concentration: formValue['concentration'] as double,
        formulation: formValue['formulation'] as String,
        sanitaryRegistryNumber: formValue['sanitaryRegistryNumber'] as String,
        expirationDate: formValue['expirationDate'] as DateTime,
        toxicologicalClassification: formValue['toxicologicalClassification'] as ToxicologicalClassification,
        manufacturer: formValue['manufacturer'] as String,
        supplier: formValue['supplier'] as String,
        unitCost: formValue['unitCost'] as double,
        applicationCost: formValue['applicationCost'] as double,
        unit: formValue['unit'] as String,
        description: formValue['description'] as String? ?? '',
        isActive: widget.product?.isActive ?? true,
        createdAt: widget.product?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.isEdit) {
        context.read<ProductBloc>().add(UpdateProductEvent(product));
      } else {
        context.read<ProductBloc>().add(CreateProduct(product));
      }
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