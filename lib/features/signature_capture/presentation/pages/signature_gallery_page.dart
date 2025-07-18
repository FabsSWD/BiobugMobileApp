import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/injection/injection.dart';
import '../../../../shared/themes/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../domain/entities/signature.dart';
import '../bloc/signature_bloc.dart';
import '../bloc/signature_event.dart';
import '../bloc/signature_state.dart';
import '../widgets/signature_gallery_item.dart';
import 'signature_capture_page.dart';

class SignatureGalleryPage extends StatelessWidget {
  static const String routeName = '/signature-gallery';

  const SignatureGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SignatureBloc>()..add(SignatureListRequested()),
      child: const SignatureGalleryView(),
    );
  }
}

class SignatureGalleryView extends StatelessWidget {
  const SignatureGalleryView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignatureBloc, SignatureState>(
      listener: (context, state) {
        if (state is SignatureError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.failure.message),
              backgroundColor: AppColors.error,
            ),
          );
        } else if (state is SignatureDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Firma eliminada exitosamente'),
              backgroundColor: AppColors.success,
            ),
          );
          // Refresh list
          context.read<SignatureBloc>().add(SignatureListRequested());
        }
      },
      child: Scaffold(
        appBar: const CustomAppBar(
          title: 'Galería de Firmas',
          backgroundColor: AppColors.primary,
        ),
        body: BlocBuilder<SignatureBloc, SignatureState>(
          builder: (context, state) {
            if (state is SignatureListLoading) {
              return const LoadingWidget(message: 'Cargando firmas...');
            }

            if (state is SignatureListLoaded) {
              if (state.signatures.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.draw,
                  title: 'Sin firmas guardadas',
                  message: 'No tienes firmas guardadas aún.\nCaptura tu primera firma para comenzar.',
                  action: ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      SignatureCapturePage.routeName,
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Capturar Firma'),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<SignatureBloc>().add(SignatureListRequested());
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.signatures.length,
                  itemBuilder: (context, index) {
                    final signature = state.signatures[index];
                    return SignatureGalleryItem(
                      signature: signature,
                      onTap: () => _showSignatureDetails(context, signature),
                      onDelete: () => _showDeleteConfirmation(context, signature),
                      onUpload: () => context.read<SignatureBloc>().add(
                        SignatureUploadRequested(signature),
                      ),
                    );
                  },
                ),
              );
            }

            return const EmptyStateWidget(
              icon: Icons.error_outline,
              title: 'Error',
              message: 'Error al cargar las firmas',
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.pushNamed(
            context,
            SignatureCapturePage.routeName,
          ),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: AppColors.white),
        ),
      ),
    );
  }

  void _showSignatureDetails(BuildContext context, Signature signature) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Detalles de Firma',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.grey300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.memory(
                  signature.imageBytes,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Tamaño', '${signature.width} x ${signature.height}'),
              _buildDetailRow('Archivo', '${signature.fileSizeInKB.toStringAsFixed(2)} KB'),
              _buildDetailRow('Puntos', '${signature.pointsCount}'),
              _buildDetailRow('Calidad', '${(signature.quality * 100).toInt()}%'),
              _buildDetailRow('Creado', _formatDate(signature.createdAt)),
              _buildDetailRow('Estado', signature.isUploaded ? 'Subido' : 'Local'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Cerrar'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (!signature.isUploaded)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          context.read<SignatureBloc>().add(
                            SignatureUploadRequested(signature),
                          );
                        },
                        child: const Text('Subir'),
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

  void _showDeleteConfirmation(BuildContext context, Signature signature) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Firma'),
        content: const Text('¿Estás seguro de que quieres eliminar esta firma?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<SignatureBloc>().add(
                SignatureDeleteRequested(signature.id),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}