// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signature_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignatureModel _$SignatureModelFromJson(Map<String, dynamic> json) =>
    SignatureModel(
      id: json['id'] as String,
      imageData: SignatureModel._bytesFromString(json['imageBytes'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      width: (json['width'] as num).toInt(),
      height: (json['height'] as num).toInt(),
      quality: (json['quality'] as num).toDouble(),
      filePath: json['filePath'] as String?,
      isUploaded: json['isUploaded'] as bool,
      pointsCount: (json['pointsCount'] as num).toInt(),
      strokeWidth: (json['strokeWidth'] as num).toDouble(),
    );

Map<String, dynamic> _$SignatureModelToJson(SignatureModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'imageBytes': SignatureModel._bytesToString(instance.imageData),
      'createdAt': instance.createdAt.toIso8601String(),
      'width': instance.width,
      'height': instance.height,
      'quality': instance.quality,
      'filePath': instance.filePath,
      'isUploaded': instance.isUploaded,
      'pointsCount': instance.pointsCount,
      'strokeWidth': instance.strokeWidth,
    };

// Update core/injection/injection.config.dart - Add these imports and registrations
/*
Add these imports at the top:
import 'package:biobug_mobile_app/features/signature_capture/data/datasources/signature_local_datasource.dart' as _i999;
import 'package:biobug_mobile_app/features/signature_capture/data/datasources/signature_remote_datasource.dart' as _i998;
import 'package:biobug_mobile_app/features/signature_capture/data/repositories/signature_repository_impl.dart' as _i997;
import 'package:biobug_mobile_app/features/signature_capture/domain/repositories/signature_repository.dart' as _i996;
import 'package:biobug_mobile_app/features/signature_capture/domain/usecases/capture_signature.dart' as _i995;
import 'package:biobug_mobile_app/features/signature_capture/domain/usecases/save_signature.dart' as _i994;
import 'package:biobug_mobile_app/features/signature_capture/domain/usecases/validate_signature.dart' as _i993;
import 'package:biobug_mobile_app/features/signature_capture/domain/usecases/upload_signature.dart' as _i992;
import 'package:biobug_mobile_app/features/signature_capture/domain/usecases/get_saved_signatures.dart' as _i991;
import 'package:biobug_mobile_app/features/signature_capture/domain/usecases/delete_signature.dart' as _i990;
import 'package:biobug_mobile_app/features/signature_capture/presentation/bloc/signature_bloc.dart' as _i989;

Add these registrations in the init method:

    // Signature Module DataSources
    gh.lazySingleton<_i999.SignatureLocalDataSource>(
      () => _i999.SignatureLocalDataSourceImpl(gh<_i777.LocalStorage>()),
    );
    gh.lazySingleton<_i998.SignatureRemoteDataSource>(
      () => _i998.SignatureRemoteDataSourceImpl(gh<_i182.ApiClient>()),
    );

    // Signature Repository
    gh.lazySingleton<_i996.SignatureRepository>(
      () => _i997.SignatureRepositoryImpl(
        gh<_i999.SignatureLocalDataSource>(),
        gh<_i998.SignatureRemoteDataSource>(),
        gh<_i580.NetworkInfo>(),
      ),
    );

    // Signature Use Cases
    gh.lazySingleton<_i995.CaptureSignature>(
      () => _i995.CaptureSignature(gh<_i996.SignatureRepository>()),
    );
    gh.lazySingleton<_i994.SaveSignature>(
      () => _i994.SaveSignature(gh<_i996.SignatureRepository>()),
    );
    gh.lazySingleton<_i993.ValidateSignature>(
      () => _i993.ValidateSignature(gh<_i996.SignatureRepository>()),
    );
    gh.lazySingleton<_i992.UploadSignature>(
      () => _i992.UploadSignature(gh<_i996.SignatureRepository>()),
    );
    gh.lazySingleton<_i991.GetSavedSignatures>(
      () => _i991.GetSavedSignatures(gh<_i996.SignatureRepository>()),
    );
    gh.lazySingleton<_i990.DeleteSignature>(
      () => _i990.DeleteSignature(gh<_i996.SignatureRepository>()),
    );

    // Signature BLoC
    gh.factory<_i989.SignatureBloc>(
      () => _i989.SignatureBloc(
        gh<_i995.CaptureSignature>(),
        gh<_i994.SaveSignature>(),
        gh<_i993.ValidateSignature>(),
        gh<_i992.UploadSignature>(),
        gh<_i991.GetSavedSignatures>(),
        gh<_i990.DeleteSignature>(),
      ),
    );
*/

// Update shared/routes/app_routes.dart - Add signature routes
/*
Add these imports:
import '../../features/signature_capture/presentation/pages/signature_capture_page.dart';
import '../../features/signature_capture/presentation/pages/signature_gallery_page.dart';

Add these route constants:
  static const String signatureCapture = '/signature-capture';
  static const String signatureGallery = '/signature-gallery';

Add these cases in onGenerateRoute:
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
*/

// Update pubspec.yaml - Add required dependencies
/*
Add these dependencies to pubspec.yaml:

dependencies:
  # Existing dependencies...
  
  # Signature capture
  signature: ^5.4.0
  
  # File and image handling
  path_provider: ^2.1.1
  image: ^4.1.3
  
  # Encryption
  encrypt: ^5.0.1
  
  # Already included in project:
  # dio: ^5.3.2
  # sqflite: ^2.3.0
  # uuid: ^4.1.0
  # shared_preferences: ^2.2.2
  # flutter_secure_storage: ^9.0.0
  # connectivity_plus: ^5.0.1
*/

// Build runner command to generate code
/*
Run these commands in terminal:

1. Add dependencies:
   flutter pub add signature path_provider image encrypt

2. Generate code:
   flutter packages pub run build_runner build --delete-conflicting-outputs

3. If you get conflicts:
   flutter packages pub run build_runner clean
   flutter packages pub run build_runner build

4. Update injection:
   The injection file will be regenerated automatically when you run the build_runner
*/

// Integration with existing app - Update home page
/*
In lib/shared/pages/home_page.dart, update the signature module card:

Replace the existing signature module in _menuItems:
{
  'title': 'Captura de Firma',
  'subtitle': 'Registrar firmas digitales',
  'icon': Icons.draw,
  'color': AppColors.primary,
  'route': '/signature-capture',
},

Update the _buildModuleCard onTap to actually navigate:
onTap: () {
  Navigator.pushNamed(context, item['route']);
},

Or for signature capture specifically:
onTap: () {
  if (item['route'] == '/signature-capture') {
    Navigator.pushNamed(
      context, 
      SignatureCapturePage.routeName,
      arguments: SignatureCapturePageArguments(
        autoSave: true,
        autoUpload: false,
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item['title']} - En desarrollo'),
      ),
    );
  }
},
*/

// Test the signature module
/*
Create a test file: test/features/signature_capture/signature_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:mocktail/mocktail.dart';
import 'package:biobug_mobile_app/features/signature_capture/domain/repositories/signature_repository.dart';
import 'package:biobug_mobile_app/features/signature_capture/domain/usecases/capture_signature.dart';
import 'package:biobug_mobile_app/features/signature_capture/domain/entities/signature_params.dart';
import 'package:biobug_mobile_app/features/signature_capture/domain/entities/signature.dart';
import 'dart:typed_data';

class MockSignatureRepository extends Mock implements SignatureRepository {}

void main() {
  late CaptureSignature usecase;
  late MockSignatureRepository mockRepository;

  setUp(() {
    mockRepository = MockSignatureRepository();
    usecase = CaptureSignature(mockRepository);
  });

  test('should capture signature with valid params', () async {
    // Arrange
    final params = SignatureParams(
      imageBytes: Uint8List.fromList([1, 2, 3, 4]),
      fileName: 'test_signature.png',
      quality: 0.8,
      compressionLevel: 6,
      width: 400,
      height: 200,
      pointsCount: 15,
      strokeWidth: 2.0,
    );

    final expectedSignature = Signature(
      id: 'test-id',
      imageBytes: params.imageBytes,
      createdAt: DateTime.now(),
      width: params.width,
      height: params.height,
      quality: params.quality,
      isUploaded: false,
      pointsCount: params.pointsCount,
      strokeWidth: params.strokeWidth,
    );

    when(() => mockRepository.captureSignature(params))
        .thenAnswer((_) async => Right(expectedSignature));

    // Act
    final result = await usecase(params);

    // Assert
    expect(result, Right(expectedSignature));
    verify(() => mockRepository.captureSignature(params));
  });
}
*/

// Usage example
/*
// In any page, you can capture a signature like this:

import 'package:flutter/material.dart';
import '../features/signature_capture/presentation/pages/signature_capture_page.dart';

class ExampleUsagePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Example')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final signature = await Navigator.pushNamed(
              context,
              SignatureCapturePage.routeName,
              arguments: SignatureCapturePageArguments(
                autoSave: true,
                autoUpload: false,
              ),
            );
            
            if (signature != null) {
              print('Signature captured: ${signature.id}');
            }
          },
          child: Text('Capture Signature'),
        ),
      ),
    );
  }
}
*/