import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/signature_capture/presentation/pages/signature_capture_page.dart';
import '../../features/signature_capture/presentation/pages/signature_gallery_page.dart';
import '../pages/splash_page.dart';
import '../pages/home_page.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String signatureCapture = '/signature-capture';
  static const String signatureGallery = '/signature-gallery';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashPage(),
          settings: settings,
        );
        
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
          settings: settings,
        );
        
      case register:
        return MaterialPageRoute(
          builder: (_) => const RegisterPage(),
          settings: settings,
        );
        
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
          settings: settings,
        );
        
      case signatureCapture:
        return MaterialPageRoute(
          builder: (_) => const SignatureCapturePage(),
          settings: settings,
        );
        
      case signatureGallery:
        return MaterialPageRoute(
          builder: (_) => const SignatureGalleryPage(),
          settings: settings,
        );
        
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Página no encontrada'),
            ),
          ),
          settings: settings,
        );
    }
  }
}