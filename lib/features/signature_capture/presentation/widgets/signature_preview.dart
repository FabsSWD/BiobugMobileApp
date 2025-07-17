import 'package:flutter/material.dart';
import '../../../../shared/themes/app_colors.dart';
import '../../domain/entities/signature.dart';

class SignaturePreview extends StatelessWidget {
  final Signature signature;
  final bool isValid;

  const SignaturePreview({
    super.key,
    required this.signature,
    required this.isValid,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Vista Previa de Firma',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Signature Image
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(
              minHeight: 200,
              maxHeight: 300,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: isValid ? AppColors.success : AppColors.error,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.memory(
                signature.imageBytes,
                fit: BoxFit.contain,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Validation Status
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isValid ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isValid ? AppColors.success : AppColors.error,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isValid ? Icons.check_circle : Icons.error,
                  color: isValid ? AppColors.success : AppColors.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isValid 
                        ? 'Firma válida y lista para guardar'
                        : 'La firma no cumple con los requisitos mínimos',
                    style: TextStyle(
                      color: isValid ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Signature Details
          _buildDetailsCard(),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detalles de la Firma',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            
            const SizedBox(height: 12),
            
            _buildDetailRow(
              'Resolución',
              '${signature.width} x ${signature.height} px',
              isValid: signature.width >= 300 && signature.height >= 150,
            ),
            
            _buildDetailRow(
              'Tamaño de archivo',
              '${signature.fileSizeInKB.toStringAsFixed(2)} KB',
              isValid: signature.fileSizeInBytes <= 51200,
            ),
            
            _buildDetailRow(
              'Puntos de trazo',
              '${signature.pointsCount}',
              isValid: signature.pointsCount >= 10,
            ),
            
            _buildDetailRow(
              'Calidad',
              '${(signature.quality * 100).toInt()}%',
              isValid: signature.quality > 0.1,
            ),
            
            _buildDetailRow(
              'Grosor de trazo',
              '${signature.strokeWidth.toStringAsFixed(1)} px',
              isValid: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {required bool isValid}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check : Icons.close,
            size: 16,
            color: isValid ? AppColors.success : AppColors.error,
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isValid ? AppColors.textPrimary : AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
