import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/injection/injection.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/inventory/presentation/bloc/inventory_bloc.dart'; // ← Agregar import
import 'shared/themes/app_theme.dart';
import 'shared/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure dependency injection
  await configureDependencies();
  
  runApp(const BioBugApp());
}

class BioBugApp extends StatelessWidget {
  const BioBugApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(  // MultiBlocProvider
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => getIt<AuthBloc>()..add(AuthCheckStatusEvent()),
        ),
        BlocProvider<InventoryBloc>(
          create: (context) => getIt<InventoryBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'BIOBUG',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        initialRoute: AppRoutes.splash,
      ),
    );
  }
}