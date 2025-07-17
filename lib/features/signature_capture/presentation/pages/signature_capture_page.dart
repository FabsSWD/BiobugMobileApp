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
      create: (context) => getIt<SignatureBloc>()..add(SignatureCaptureStarted()),
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
          title: 'Captura de Firma Digital',
          backgroundColor: AppColors.primary,
        ),
        body: SafeArea(
          child: BlocBuilder<SignatureBloc, SignatureState>(
            builder: (context, state) {
              if (state is SignatureCapturing) {
                return const Center(
                  child: LoadingWidget(message: 'Inicializando captura...'),
                );
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
        // Validation Info
        const SignatureValidationInfo(),
        
        // Canvas Section
        Expanded(
          flex: 7,
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.grey300, width: 2),
              borderRadius: BorderRadius.circular(12),
              color: AppColors.white,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SignatureCanvas(
                key: _canvasKey,
                onSignatureChanged: (pointsCount) {
                  context.read<SignatureBloc>().add(
                    SignatureCaptureStarted(),
                  );
                },
              ),
            ),
          ),
        ),
        
        // Controls Section
        Container(
          padding: const EdgeInsets.all(16),
          child: SignatureControls(
            onClear: () {
              _canvasKey.currentState?.clear();
              context.read<SignatureBloc>().add(SignatureClearRequested());
              setState(() {
                _showPreview = false;
              });
            },
            onSave: _handleSave,
            onCancel: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewSection(signature, bool isValid) {
    return Column(
      children: [
        // Preview
        Expanded(
          child: SignaturePreview(
            signature: signature,
            isValid: isValid,
          ),
        ),
        
        // Preview Controls
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showPreview = false;
                    });
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isValid ? () => _confirmSave(signature) : null,
                  icon: const Icon(Icons.save),
                  label: const Text('Confirmar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isValid ? AppColors.success : AppColors.grey400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleSave() async {
    final signatureData = await _canvasKey.currentState?.exportSignature();
    if (signatureData != null) {
      context.read<SignatureBloc>().add(SignatureCaptureCompleted(signatureData));
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