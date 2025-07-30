import 'package:flutter/material.dart';
import '../../../../shared/themes/app_colors.dart';
import '../../domain/entities/toxicological_classification.dart';

class ToxicologicalBadge extends StatelessWidget {
  final ToxicologicalClassification classification;
  final bool showTooltip;

  const ToxicologicalBadge({
    super.key,
    required this.classification,
    this.showTooltip = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColorForClassification(classification);
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        classification.name.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: _getTextColorForBackground(color),
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    if (showTooltip) {
      return Tooltip(
        message: classification.displayName,
        child: badge,
      );
    }

    return badge;
  }

  Color _getColorForClassification(ToxicologicalClassification classification) {
    switch (classification) {
      case ToxicologicalClassification.ia:
      case ToxicologicalClassification.ib:
        return AppColors.error;
      case ToxicologicalClassification.ii:
        return AppColors.warning;
      case ToxicologicalClassification.iii:
        return AppColors.info;
      case ToxicologicalClassification.iv:
        return AppColors.success;
      case ToxicologicalClassification.u:
        return AppColors.grey300;
    }
  }

  Color _getTextColorForBackground(Color backgroundColor) {
    // Simple logic to determine text color based on background
    return backgroundColor == AppColors.grey300 ? AppColors.black : AppColors.white;
  }
}