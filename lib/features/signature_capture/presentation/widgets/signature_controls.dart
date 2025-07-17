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
                  padding: const EdgeInsets.symmetric(vertical: 12),
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
                  padding: const EdgeInsets.symmetric(vertical: 12),
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
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}