import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/signature_capture/presentation/pages/signature_capture_page.dart';
import '../themes/app_colors.dart';
import '../widgets/offline_indicator.dart';
import '../routes/app_routes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _menuItems = [
    {
      'title': 'Captura de Firma',
      'subtitle': 'Registrar firmas digitales',
      'icon': Icons.draw,
      'color': AppColors.primary,
      'route': AppRoutes.signatureCapture,
      'implemented': true,
    },
    {
      'title': 'Galería de Firmas',
      'subtitle': 'Ver firmas guardadas',
      'icon': Icons.photo_library,
      'color': AppColors.accent,
      'route': AppRoutes.signatureGallery,
      'implemented': true,
    },
    {
      'title': 'Facturación',
      'subtitle': 'Generar comprobantes',
      'icon': Icons.receipt_long,
      'color': AppColors.secondary,
      'route': '/billing',
      'implemented': false,
    },
    {
      'title': 'Tratamientos',
      'subtitle': 'Registrar actividades',
      'icon': Icons.science,
      'color': AppColors.accent,
      'route': '/treatments',
      'implemented': false,
    },
    {
      'title': 'Monitoreo',
      'subtitle': 'Gestionar estaciones',
      'icon': Icons.monitor_heart,
      'color': AppColors.success,
      'route': '/monitoring',
      'implemented': false,
    },
    {
      'title': 'Técnicas',
      'subtitle': 'Base de datos',
      'icon': Icons.menu_book,
      'color': AppColors.info,
      'route': '/techniques',
      'implemented': false,
    },
    {
      'title': 'Inventario',
      'subtitle': 'Control de productos',
      'icon': Icons.inventory,
      'color': AppColors.warning,
      'route': '/inventory',
      'implemented': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        print('HomePage BlocListener - State: ${state.runtimeType}');
        if (state is AuthUnauthenticated) {
          print('Redirecting to login - user unauthenticated');
          Navigator.pushReplacementNamed(context, '/login');
        } else if (state is AuthAuthenticated) {
          print('User authenticated: ${state.user.fullName}');
        }
      },
      child: Scaffold(
        body: OfflineIndicator(
          child: Column(
            children: [
              // Custom App Bar
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primaryDark,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        print('AppBar BlocBuilder - State: ${state.runtimeType}');
                        
                        // Mostrar loading mientras se cargan los datos
                        if (state is AuthLoading) {
                          return Row(
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundColor: AppColors.white,
                                child: const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Bienvenido',
                                      style: TextStyle(
                                        color: AppColors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      'Cargando...',
                                      style: TextStyle(
                                        color: AppColors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }
                        
                        // Mostrar datos del usuario cuando está autenticado
                        if (state is AuthAuthenticated) {
                          print('Rendering authenticated user: ${state.user.fullName}');
                          return Row(
                            children: [
                              // User Avatar
                              CircleAvatar(
                                radius: 25,
                                backgroundColor: AppColors.white,
                                child: Text(
                                  state.user.fullName[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              
                              const SizedBox(width: 16),
                              
                              // Welcome Text
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Bienvenido',
                                      style: TextStyle(
                                        color: AppColors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      state.user.fullName,
                                      style: const TextStyle(
                                        color: AppColors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Logout Button
                              IconButton(
                                onPressed: () => _showLogoutDialog(context),
                                icon: const Icon(
                                  Icons.logout,
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          );
                        }
                        
                        // Estado por defecto (no autenticado, error, etc.)
                        print('Rendering default state');
                        return Row(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundColor: AppColors.white,
                              child: const Icon(
                                Icons.person,
                                color: AppColors.primary,
                              ),
                            ),
                            
                            const SizedBox(width: 16),
                            
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bienvenido',
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'Usuario',
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Logout Button
                            IconButton(
                              onPressed: () => _showLogoutDialog(context),
                              icon: const Icon(
                                Icons.logout,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              
              // Body Content
              Expanded(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: [
                    _buildDashboard(),
                    _buildStatistics(),
                    _buildProfile(),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics),
              label: 'Estadísticas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Módulos del Sistema',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.0,
            ),
            itemCount: _menuItems.length,
            itemBuilder: (context, index) {
              final item = _menuItems[index];
              return _buildModuleCard(item);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(Map<String, dynamic> item) {
    final isImplemented = item['implemented'] as bool;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _handleModuleTap(item),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                item['color'].withOpacity(isImplemented ? 0.1 : 0.05),
                item['color'].withOpacity(isImplemented ? 0.05 : 0.02),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    item['icon'],
                    size: 40,
                    color: isImplemented ? item['color'] : AppColors.grey400,
                  ),
                  if (isImplemented)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              Text(
                item['title'],
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isImplemented ? null : AppColors.grey500,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 2),
              
              Flexible(
                child: Text(
                  item['subtitle'],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isImplemented ? null : AppColors.grey400,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              if (!isImplemented) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'En desarrollo',
                    style: TextStyle(
                      fontSize: 9,
                      color: AppColors.warning,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _handleModuleTap(Map<String, dynamic> item) {
    final isImplemented = item['implemented'] as bool;
    final route = item['route'] as String;

    if (isImplemented) {
      if (route == AppRoutes.signatureCapture) {
        Navigator.pushNamed(
          context,
          AppRoutes.signatureCapture,
          arguments: SignatureCapturePageArguments(
            autoSave: true,
            autoUpload: false,
          ),
        );
      } else if (route == AppRoutes.signatureGallery) {
        Navigator.pushNamed(context, AppRoutes.signatureGallery);
      } else {
        Navigator.pushNamed(context, route);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item['title']} - En desarrollo'),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  Widget _buildStatistics() {
    return const Center(
      child: Text(
        'Estadísticas - En desarrollo',
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildProfile() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        print('Profile BlocBuilder - State: ${state.runtimeType}');
        
        if (state is AuthLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (state is AuthAuthenticated) {
          print('Rendering profile for user: ${state.user.fullName}');
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            state.user.fullName[0].toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.user.fullName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.user.email,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ID: ${state.user.identification}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.draw, color: AppColors.primary),
                    title: const Text('Mis Firmas'),
                    subtitle: const Text('Ver firmas guardadas'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => Navigator.pushNamed(context, AppRoutes.signatureGallery),
                  ),
                ),
                
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _showLogoutDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                  ),
                  child: const Text('Cerrar Sesión'),
                ),
              ],
            ),
          );
        }
        
        // Si no está autenticado o hay error
        print('Rendering profile error/unauthenticated state');
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.grey400,
              ),
              const SizedBox(height: 16),
              const Text(
                'No se pudieron cargar los datos del usuario',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Intentar recargar los datos del usuario
                  context.read<AuthBloc>().add(AuthCheckStatusEvent());
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(AuthLogoutEvent());
            },
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}