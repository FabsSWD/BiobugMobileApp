import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/signature_capture/presentation/pages/signature_capture_page.dart';
// ignore: unused_import
import '../../features/signature_capture/presentation/pages/signature_gallery_page.dart';
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
      'implemented': true, // NEW: Mark as implemented
    },
    {
      'title': 'Galería de Firmas',
      'subtitle': 'Ver firmas guardadas',
      'icon': Icons.photo_library,
      'color': AppColors.accent,
      'route': AppRoutes.signatureGallery,
      'implemented': true, // NEW: Mark as implemented
    },
    {
      'title': 'Facturación',
      'subtitle': 'Generar comprobantes y facturas',
      'icon': Icons.receipt_long,
      'color': AppColors.secondary,
      'route': '/billing',
      'implemented': false,
    },
    {
      'title': 'Tratamientos',
      'subtitle': 'Registrar actividades de tratamiento',
      'icon': Icons.science,
      'color': AppColors.accent,
      'route': '/treatments',
      'implemented': false,
    },
    {
      'title': 'Monitoreo',
      'subtitle': 'Gestionar estaciones de control',
      'icon': Icons.monitor_heart,
      'color': AppColors.success,
      'route': '/monitoring',
      'implemented': false,
    },
    {
      'title': 'Técnicas',
      'subtitle': 'Base de datos de técnicas',
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
        if (state is AuthUnauthenticated) {
          Navigator.pushReplacementNamed(context, '/login');
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
                    child: Row(
                      children: [
                        // User Avatar
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: AppColors.white,
                          child: BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              if (state is AuthAuthenticated) {
                                return Text(
                                  state.user.fullName[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                );
                              }
                              return const Icon(
                                Icons.person,
                                color: AppColors.primary,
                              );
                            },
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
                              BlocBuilder<AuthBloc, AuthState>(
                                builder: (context, state) {
                                  if (state is AuthAuthenticated) {
                                    return Text(
                                      state.user.fullName,
                                      style: const TextStyle(
                                        color: AppColors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    );
                                  }
                                  return const Text(
                                    'Usuario',
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
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
              childAspectRatio: 1.2,
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
          padding: const EdgeInsets.all(16),
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
            children: [
              Stack(
                children: [
                  Icon(
                    item['icon'],
                    size: 48,
                    color: isImplemented ? item['color'] : AppColors.grey400,
                  ),
                  if (isImplemented)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                item['title'],
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isImplemented ? null : AppColors.grey500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                item['subtitle'],
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isImplemented ? null : AppColors.grey400,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (!isImplemented) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'En desarrollo',
                    style: TextStyle(
                      fontSize: 10,
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
      // Navigate to implemented modules
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
      // Show development message for unimplemented modules
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
        if (state is AuthAuthenticated) {
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
                
                // NEW: Quick access to signature gallery
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
        return const Center(
          child: Text('No se pudieron cargar los datos del usuario'),
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

// Added Android permissions in android/app/src/main/AndroidManifest.xml
/*
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- Existing permissions -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    
    <!-- NEW: Storage permissions for signature files -->
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" 
                     android:maxSdkVersion="28" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    
    <application
        android:label="BIOBUG"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"
              />
              
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
*/