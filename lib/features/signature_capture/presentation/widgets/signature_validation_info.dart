import 'package:flutter/material.dart';
import '../../../../shared/themes/app_colors.dart';

class SignatureValidationInfo extends StatelessWidget {
  const SignatureValidationInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.info),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.info,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Requisitos de la Firma',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          _buildRequirementRow('Resolución mínima: 300x150 píxeles'),
          _buildRequirementRow('Tamaño máximo: 50KB'),
          _buildRequirementRow('Mínimo 10 puntos de trazo'),
          _buildRequirementRow('Use un trazo claro y continuo'),
        ],
      ),
    );
  }

  Widget _buildRequirementRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 28, top: 2),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.info,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.info,
              ),
            ),
          ),
        ],
      ),
    );
  }
}