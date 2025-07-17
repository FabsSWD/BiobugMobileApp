import 'package:flutter/material.dart';
import '../../../../shared/themes/app_colors.dart';

class SignatureControls extends StatelessWidget {
  final VoidCallback? onClear;
  final VoidCallback? onSave;
  final VoidCallback? onCancel;
  final bool isEnabled;

  const SignatureControls({
    super.key,
    this.onClear,
    this.onSave,
    this.onCancel,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Stroke Width Slider (Optional feature)
        _buildStrokeWidthSlider(),
        
        const SizedBox(height: 16),
        
        // Action Buttons
        Row(
          children: [
            // Clear Button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isEnabled ? onClear : null,
                icon: const Icon(Icons.clear),
                label: const Text('Limpiar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.warning,
                  side: const BorderSide(color: AppColors.warning),
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Cancel Button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.close),
                label: const Text('Cancelar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Save Button
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: isEnabled ? onSave : null,
                icon: const Icon(Icons.save),
                label: const Text('Guardar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStrokeWidthSlider() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Grosor del trazo',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.grey700,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.remove,
                size: 16,
                color: AppColors.grey500,
              ),
              Expanded(
                child: Slider(
                  value: 2.0, // Default stroke width
                  min: 1.0,
                  max: 8.0,
                  divisions: 7,
                  activeColor: AppColors.primary,
                  onChanged: isEnabled ? (value) {
                    // TODO: Implement stroke width change
                  } : null,
                ),
              ),
              Icon(
                Icons.add,
                size: 16,
                color: AppColors.grey500,
              ),
            ],
          ),
        ],
      ),
    );
  }
}