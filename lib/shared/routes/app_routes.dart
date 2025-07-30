import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/inventory/domain/entities/product.dart';
import '../../features/inventory/presentation/pages/alerts_page.dart';
import '../../features/inventory/presentation/pages/inventory_list_page.dart';
import '../../features/inventory/presentation/pages/inventory_overview_page.dart';
import '../../features/inventory/presentation/pages/inventory_reports_page.dart';
import '../../features/inventory/presentation/pages/product_detail_page.dart';
import '../../features/inventory/presentation/pages/product_form_page.dart';
import '../../features/inventory/presentation/pages/product_list_page.dart';
import '../../features/signature_capture/presentation/pages/signature_capture_page.dart';
import '../../features/signature_capture/presentation/pages/signature_gallery_page.dart';
import '../pages/splash_page.dart';
import '../pages/home_page.dart';

class AppRoutes {
  static const String splash = '/';
  
  // Authentication Module
  static const String login = '/login';
  static const String register = '/register';

  // Home Page
  static const String home = '/home';
  
  // Signature Module
  static const String signatureCapture = '/signature-capture';
  static const String signatureGallery = '/signature-gallery';
  
  // Inventory Module
  static const String inventory = '/inventory';
  static const String inventoryProducts = '/inventory/products';
  static const String inventoryProductAdd = '/inventory/products/add';
  static const String inventoryProductEdit = '/inventory/products/edit';
  static const String inventoryProductDetail = '/inventory/products/detail';
  static const String inventoryStock = '/inventory/stock';
  static const String inventoryAlerts = '/inventory/alerts';
  static const String inventoryReports = '/inventory/reports';


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
      
      case inventory:
        return MaterialPageRoute(builder: (_) => const InventoryOverviewPage());
      
      case inventoryProducts:
        return MaterialPageRoute(builder: (_) => const ProductListPage());
      
      case inventoryProductAdd:
        return MaterialPageRoute(
          builder: (_) => const ProductFormPage(),
          settings: RouteSettings(
            name: inventoryProductAdd,
            arguments: ProductFormPageArguments(isEdit: false),
          ),
        );
      
      case inventoryProductEdit:
        final product = settings.arguments as Product?;
        return MaterialPageRoute(
          builder: (_) => const ProductFormPage(),
          settings: RouteSettings(
            name: inventoryProductEdit,
            arguments: ProductFormPageArguments(
              product: product,
              isEdit: true,
            ),
          ),
        );
      
      case inventoryProductDetail:
        final productId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ProductDetailPage(productId: productId),
        );
      
      case inventoryStock:
        return MaterialPageRoute(builder: (_) => const InventoryListPage());
      
      case inventoryAlerts:
        return MaterialPageRoute(builder: (_) => const AlertsPage());
      
      case inventoryReports:
        return MaterialPageRoute(builder: (_) => const InventoryReportsPage());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Página no encontrada')),
            body: const Center(
              child: Text('La página solicitada no existe'),
            ),
          ),
        );
    }
  }
}