import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/themes/app_colors.dart';
import '../bloc/alert_bloc.dart';
import '../bloc/alert_state.dart';
import 'alert_card.dart';

class RecentAlertsList extends StatelessWidget {
  const RecentAlertsList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlertBloc, AlertState>(
      builder: (context, state) {
        if (state is AlertLoaded) {
          final recentAlerts = state.alerts.take(3).toList();
          
          if (recentAlerts.isEmpty) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 48,
                      color: AppColors.success,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sin alertas',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      'Todo está bajo control',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: recentAlerts.map((alert) => AlertCard(alert: alert)).toList(),
          );
        }

        return Card(
          child: Container(
            height: 120,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}