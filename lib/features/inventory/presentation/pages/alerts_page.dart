import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/injection/injection.dart';
import '../../../../shared/themes/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../bloc/alert_bloc.dart';
import '../bloc/alert_event.dart';
import '../bloc/alert_state.dart';
import '../widgets/alert_card.dart';

class AlertsPage extends StatelessWidget {
  static const String routeName = '/inventory/alerts';

  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AlertBloc>()..add(LoadAlerts()),
      child: BlocListener<AlertBloc, AlertState>(
        listener: (context, state) {
          if (state is AlertError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: Scaffold(
          appBar: CustomAppBar(
            title: 'Alertas de Inventario',
            actions: [
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'all',
                    child: Text('Todas'),
                  ),
                  const PopupMenuItem(
                    value: 'critical',
                    child: Text('Críticas'),
                  ),
                  const PopupMenuItem(
                    value: 'high',
                    child: Text('Altas'),
                  ),
                  const PopupMenuItem(
                    value: 'medium',
                    child: Text('Medias'),
                  ),
                ],
                onSelected: (value) {
                  // Implement filtering logic
                  context.read<AlertBloc>().add(LoadAlerts());
                },
              ),
            ],
          ),
          body: BlocBuilder<AlertBloc, AlertState>(
            builder: (context, state) {
              if (state is AlertLoading) {
                return const LoadingWidget(message: 'Cargando alertas...');
              }

              if (state is AlertLoaded) {
                if (state.alerts.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.notifications_none,
                    title: 'Sin alertas',
                    message: 'No hay alertas activas en este momento.',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<AlertBloc>().add(LoadAlerts());
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.alerts.length,
                    itemBuilder: (context, index) {
                      final alert = state.alerts[index];
                      return AlertCard(
                        alert: alert,
                        onMarkAsRead: () {
                          context.read<AlertBloc>().add(MarkAlertAsReadEvent(alert.id));
                        },
                        onDismiss: () {
                          context.read<AlertBloc>().add(DismissAlert(alert.id));
                        },
                      );
                    },
                  ),
                );
              }

              return const Center(
                child: Text('Estado no reconocido'),
              );
            },
          ),
        ),
      ),
    );
  }
}