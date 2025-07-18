import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/injection/injection.dart';
import '../../../../shared/themes/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../bloc/signature_bloc.dart';
import '../bloc/signature_event.dart';
import '../bloc/signature_state.dart';
import '../widgets/signature_canvas.dart';
import '../widgets/signature_controls.dart';
import '../widgets/signature_preview.dart';
// ignore: unused_import
import '../widgets/signature_validation_info.dart';

class SignatureCapturePageArguments {
  final bool autoSave;
  final bool autoUpload;

  SignatureCapturePageArguments({
    this.autoSave = true,
    this.autoUpload = false,
  });
}

class SignatureCapturePage extends StatelessWidget {
  static const String routeName = '/signature-capture';

  const SignatureCapturePage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as SignatureCapturePageArguments?;
    
    return BlocProvider(
      create: (context) => getIt<SignatureBloc>(),
      child: SignatureCaptureView(
        autoSave: args?.autoSave ?? true,
        autoUpload: args?.autoUpload ?? false,
      ),
    );
  }
}

class SignatureCaptureView extends StatefulWidget {
  final bool autoSave;
  final bool autoUpload;

  const SignatureCaptureView({
    super.key,
    required this.autoSave,
    required this.autoUpload,
  });

  @override
  State<SignatureCaptureView> createState() => _SignatureCaptureViewState();
}

class _SignatureCaptureViewState extends State<SignatureCaptureView> {
  final GlobalKey<SignatureCanvasState> _canvasKey = GlobalKey<SignatureCanvasState>();
  bool _showPreview = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignatureBloc, SignatureState>(
      listener: (context, state) {
        if (state is SignatureError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.failure.message),
              backgroundColor: AppColors.error,
            ),
          );
        } else if (state is SignatureSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Firma guardada exitosamente'),
              backgroundColor: AppColors.success,
            ),
          );
          if (widget.autoUpload) {
            context.read<SignatureBloc>().add(SignatureUploadRequested(state.signature));
          }
        } else if (state is SignatureUploaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Firma subida exitosamente'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context, state.signature);
        } else if (state is SignatureValidated && state.isValid) {
          setState(() {
            _showPreview = true;
          });
        }
      },
      child: Scaffold(
        appBar: const CustomAppBar(
          title: 'Captura de Firma',
          backgroundColor: AppColors.primary,
        ),
        body: SafeArea(
          child: BlocBuilder<SignatureBloc, SignatureState>(
            builder: (context, state) {
              if (state is SignatureCapturing || state is SignatureValidating) {
                return const LoadingWidget(message: 'Procesando firma...');
              }

              if (_showPreview && state is SignatureValidated) {
                return _buildPreviewSection(state.signature, state.isValid);
              }

              return _buildCaptureSection();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCaptureSection() {
    return Column(
      children: [
        // Instructions - Collapsible on mobile
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: ExpansionTile(
            title: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.info,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Instrucciones',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.info.withOpacity(0.05),
            collapsedBackgroundColor: AppColors.info.withOpacity(0.05),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppColors.info.withOpacity(0.3)),
            ),
            collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppColors.info.withOpacity(0.3)),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInstructionItem('Resolución mínima: 300x150 píxeles'),
                    _buildInstructionItem('Tamaño máximo: 5MB'),
                    _buildInstructionItem('Mínimo 5 puntos de trazo'),
                    _buildInstructionItem('Use un trazo claro y continuo'),
                    _buildInstructionItem('Evite levantar el dedo durante el trazo'),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Canvas Section - Flexible height
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.white,
                      AppColors.grey50,
                    ],
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SignatureCanvas(
                    key: _canvasKey,
                    onSignatureChanged: (pointsCount) {
                      // Actualizar UI si es necesario
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        
        // Controls Section - Fixed at bottom
        SignatureControls(
          onClear: () {
            _canvasKey.currentState?.clear();
            context.read<SignatureBloc>().add(SignatureClearRequested());
            setState(() {
              _showPreview = false;
            });
          },
          onSave: _handleSave,
          onCancel: () => Navigator.pop(context),
          isEnabled: true,
        ),
      ],
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6, right: 8),
            decoration: BoxDecoration(
              color: AppColors.info,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.info,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewSection(signature, bool isValid) {
    return Column(
      children: [
        // Preview Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                isValid ? Icons.check_circle : Icons.error,
                color: isValid ? AppColors.success : AppColors.error,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vista Previa',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      isValid ? 'Firma válida' : 'Revisar requisitos',
                      style: TextStyle(
                        fontSize: 14,
                        color: isValid ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Preview Content
        Expanded(
          child: SignaturePreview(
            signature: signature,
            isValid: isValid,
          ),
        ),
        
        // Preview Controls
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _showPreview = false;
                      });
                    },
                    icon: const Icon(Icons.edit, size: 20),
                    label: const Text('Editar'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: isValid ? () => _confirmSave(signature) : null,
                    icon: const Icon(Icons.check, size: 20),
                    label: const Text('Confirmar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isValid ? AppColors.success : AppColors.grey400,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _handleSave() async {
    final signatureData = await _canvasKey.currentState?.exportSignature();
    if (signatureData != null) {
      context.read<SignatureBloc>().add(SignatureCaptureCompleted(signatureData));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, dibuje una firma antes de guardar'),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  void _confirmSave(signature) {
    if (widget.autoSave) {
      context.read<SignatureBloc>().add(SignatureSaveRequested(signature));
    } else {
      Navigator.pop(context, signature);
    }
  }
}