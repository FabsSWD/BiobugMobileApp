import 'package:flutter/material.dart';
import '../themes/app_colors.dart';

class CustomErrorWidget extends StatelessWidget {
  final String message;
  final String? title;
  final VoidCallback? onRetry;
  final IconData? icon;

  const CustomErrorWidget({
    super.key,
    required this.message,
    this.title,
    this.onRetry,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            if (title != null) ...[
              Text(
                title!,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}