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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Indicador visual
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Botones principales
            if (isSmallScreen)
              _buildVerticalLayout()
            else
              _buildHorizontalLayout(),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalLayout() {
    return Row(
      children: [
        // Clear Button
        Expanded(
          flex: 2,
          child: _buildClearButton(),
        ),
        
        const SizedBox(width: 12),
        
        // Cancel Button
        Expanded(
          flex: 2,
          child: _buildCancelButton(),
        ),
        
        const SizedBox(width: 12),
        
        // Save Button - más grande
        Expanded(
          flex: 3,
          child: _buildSaveButton(),
        ),
      ],
    );
  }

  Widget _buildVerticalLayout() {
    return Column(
      children: [
        // Primera fila: Clear y Cancel
        Row(
          children: [
            Expanded(child: _buildClearButton()),
            const SizedBox(width: 12),
            Expanded(child: _buildCancelButton()),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Segunda fila: Save button completo
        SizedBox(
          width: double.infinity,
          child: _buildSaveButton(),
        ),
      ],
    );
  }

  Widget _buildClearButton() {
    return OutlinedButton.icon(
      onPressed: isEnabled ? onClear : null,
      icon: const Icon(Icons.clear_all, size: 20),
      label: const Text(
        'Limpiar',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.warning,
        side: const BorderSide(color: AppColors.warning, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return OutlinedButton.icon(
      onPressed: onCancel,
      icon: const Icon(Icons.close, size: 20),
      label: const Text(
        'Cancelar',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.error,
        side: const BorderSide(color: AppColors.error, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton.icon(
      onPressed: isEnabled ? onSave : null,
      icon: const Icon(Icons.save, size: 20),
      label: const Text(
        'Guardar Firma',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isEnabled ? AppColors.success : AppColors.grey400,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        elevation: isEnabled ? 3 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        shadowColor: AppColors.success.withOpacity(0.3),
      ),
    );
  }
}