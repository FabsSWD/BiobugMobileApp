import 'package:flutter/material.dart';
import '../../../../shared/themes/app_colors.dart';
import '../../domain/entities/inventory_alert.dart';
import '../../domain/entities/inventory_alert_priority.dart';

class AlertCard extends StatelessWidget {
  final InventoryAlert alert;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDismiss;
  final VoidCallback? onTap;

  const AlertCard({
    super.key,
    required this.alert,
    this.onMarkAsRead,
    this.onDismiss,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final priorityColor = _getColorForPriority(alert.priority);
    final priorityIcon = _getIconForPriority(alert.priority);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: priorityColor.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      priorityIcon,
                      color: priorityColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: priorityColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        alert.priority.name.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (!alert.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                Text(
                  alert.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  alert.message,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(alert.createdAt),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    if (!alert.isRead && onMarkAsRead != null)
                      TextButton.icon(
                        onPressed: onMarkAsRead,
                        icon: const Icon(Icons.mark_email_read, size: 16),
                        label: const Text('Marcar leído'),
                      ),
                    if (onDismiss != null)
                      TextButton.icon(
                        onPressed: onDismiss,
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Descartar'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getColorForPriority(InventoryAlertPriority priority) {
    switch (priority) {
      case InventoryAlertPriority.critical:
        return AppColors.error;
      case InventoryAlertPriority.high:
        return AppColors.warning;
      case InventoryAlertPriority.medium:
        return AppColors.info;
      case InventoryAlertPriority.low:
        return AppColors.success;
    }
  }

  IconData _getIconForPriority(InventoryAlertPriority priority) {
    switch (priority) {
      case InventoryAlertPriority.critical:
        return Icons.error;
      case InventoryAlertPriority.high:
        return Icons.warning;
      case InventoryAlertPriority.medium:
        return Icons.info;
      case InventoryAlertPriority.low:
        return Icons.check_circle;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inMinutes}m';
    }
  }
}