import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/themes/app_colors.dart';

class SignatureValidationInfo extends StatelessWidget {
  final bool isCompact;
  
  const SignatureValidationInfo({
    super.key,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return _buildCompactInfo();
    }
    
    return _buildFullInfo();
  }

  Widget _buildCompactInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.info,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Dibuje su firma claramente. Mín: 300x150px, 5 puntos',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.info,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.info.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: AppColors.info.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.info,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Instrucciones para la Firma',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.info,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          
          // Requirements
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildRequirementItem(
                  icon: Icons.photo_size_select_large,
                  title: 'Resolución mínima',
                  value: '${AppConstants.signatureMinResolutionWidth}x${AppConstants.signatureMinResolutionHeight} píxeles',
                ),
                _buildRequirementItem(
                  icon: Icons.file_copy,
                  title: 'Tamaño máximo',
                  value: '${(AppConstants.signatureMaxFileSize / 1024 / 1024).toStringAsFixed(1)}MB',
                ),
                _buildRequirementItem(
                  icon: Icons.timeline,
                  title: 'Puntos mínimos',
                  value: '${AppConstants.signatureMinPoints} puntos de trazo',
                ),
                _buildRequirementItem(
                  icon: Icons.draw,
                  title: 'Técnica recomendada',
                  value: 'Trazo claro y continuo',
                ),
                _buildRequirementItem(
                  icon: Icons.touch_app,
                  title: 'Consejo',
                  value: 'No levante el dedo durante el trazo',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: AppColors.info,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}