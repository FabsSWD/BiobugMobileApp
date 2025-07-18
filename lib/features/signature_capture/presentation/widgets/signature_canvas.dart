import 'dart:typed_data';
// ignore: unused_import
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/themes/app_colors.dart';
import '../../domain/entities/signature_params.dart';

class SignatureCanvas extends StatefulWidget {
  final Function(int pointsCount)? onSignatureChanged;
  final double strokeWidth;
  final Color strokeColor;

  const SignatureCanvas({
    super.key,
    this.onSignatureChanged,
    this.strokeWidth = 2.5,
    this.strokeColor = AppColors.primary,
  });

  @override
  State<SignatureCanvas> createState() => SignatureCanvasState();
}

class SignatureCanvasState extends State<SignatureCanvas> {
  late SignatureController _controller;
  final GlobalKey _signatureKey = GlobalKey();
  int _currentPointsCount = 0;
  bool _isDrawing = false;

  @override
  void initState() {
    super.initState();
    _controller = SignatureController(
      penStrokeWidth: widget.strokeWidth,
      penColor: widget.strokeColor,
      exportBackgroundColor: Colors.white,
      onDrawStart: () {
        setState(() {
          _isDrawing = true;
        });
        _onSignatureChanged();
      },
      onDrawMove: () => _onSignatureChanged(),
      onDrawEnd: () {
        setState(() {
          _isDrawing = false;
        });
        _onSignatureChanged();
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSignatureChanged() {
    final points = _controller.points;
    _currentPointsCount = points.length;
    
    if (widget.onSignatureChanged != null) {
      widget.onSignatureChanged!(_currentPointsCount);
    }
    
    if (mounted) {
      setState(() {});
    }
  }

  bool get _meetsSizeRequirements {
    final context = _signatureKey.currentContext;
    if (context == null) return false;
    
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    
    return size.width >= AppConstants.signatureMinResolutionWidth &&
           size.height >= AppConstants.signatureMinResolutionHeight;
  }

  bool get _meetsPointsRequirement {
    return _currentPointsCount >= AppConstants.signatureMinPoints;
  }

  bool get _isValid {
    return _controller.isNotEmpty && 
           _meetsSizeRequirements && 
           _meetsPointsRequirement;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _signatureKey,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getStatusColor(),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Status header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _getStatusColor().withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getStatusIcon(),
                  size: 16,
                  color: _getStatusColor(),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getStatusText(),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getStatusColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (_isDrawing)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
          
          // Canvas
          Expanded(
            child: Stack(
              children: [
                // Background with guide
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: CustomPaint(
                    painter: _SignatureGuidePainter(),
                  ),
                ),
                
                // Signature widget
                Signature(
                  controller: _controller,
                  backgroundColor: Colors.transparent,
                ),
                
                // Empty state overlay
                if (_controller.isEmpty)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.gesture,
                          size: 48,
                          color: AppColors.grey400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Dibuje su firma aquí',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.grey500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Use su dedo o stylus',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.grey400,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          
          // Bottom info bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                _buildInfoChip(
                  icon: Icons.timeline,
                  label: 'Puntos',
                  value: '$_currentPointsCount',
                  isValid: _meetsPointsRequirement,
                ),
                const SizedBox(width: 12),
                _buildInfoChip(
                  icon: Icons.aspect_ratio,
                  label: 'Tamaño',
                  value: 'Min 300x150',
                  isValid: _meetsSizeRequirements,
                ),
                const Spacer(),
                if (_isValid)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Válida',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
    required bool isValid,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12,
          color: isValid ? AppColors.success : AppColors.grey400,
        ),
        const SizedBox(width: 4),
        Text(
          '$label: $value',
          style: TextStyle(
            fontSize: 10,
            color: isValid ? AppColors.success : AppColors.grey500,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    if (_controller.isEmpty) return AppColors.grey400;
    if (_isValid) return AppColors.success;
    return AppColors.warning;
  }

  IconData _getStatusIcon() {
    if (_controller.isEmpty) return Icons.draw;
    if (_isValid) return Icons.check_circle;
    return Icons.warning;
  }

  String _getStatusText() {
    if (_controller.isEmpty) return 'Listo para dibujar';
    if (_isValid) return 'Firma válida y lista';
    
    List<String> issues = [];
    if (!_meetsPointsRequirement) {
      issues.add('Necesita más puntos');
    }
    if (!_meetsSizeRequirements) {
      issues.add('Área muy pequeña');
    }
    
    return issues.join(' • ');
  }

  void clear() {
    _controller.clear();
    _currentPointsCount = 0;
    _onSignatureChanged();
  }

  Future<SignatureParams?> exportSignature() async {
    if (_controller.isEmpty) {
      return null;
    }

    try {
      final RenderBox renderBox = _signatureKey.currentContext!.findRenderObject() as RenderBox;
      final size = renderBox.size;

      final Uint8List? signatureBytes = await _controller.toPngBytes(
        height: size.height.toInt(),
        width: size.width.toInt(),
      );

      if (signatureBytes == null) {
        return null;
      }

      final pointsCount = _controller.points.length;
      final area = size.width * size.height;
      final density = pointsCount / area;
      final quality = (density * 1000).clamp(0.1, 1.0);

      return SignatureParams(
        imageBytes: signatureBytes,
        fileName: 'signature_${DateTime.now().millisecondsSinceEpoch}.png',
        quality: quality,
        compressionLevel: 6,
        width: size.width.toInt(),
        height: size.height.toInt(),
        pointsCount: pointsCount,
        strokeWidth: widget.strokeWidth,
      );
    } catch (e) {
      debugPrint('Error exporting signature: $e');
      return null;
    }
  }

  bool get isEmpty => _controller.isEmpty;
  bool get isNotEmpty => _controller.isNotEmpty;
  int get pointsCount => _currentPointsCount;
  bool get isValid => _isValid;
}

class _SignatureGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.grey300.withOpacity(0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Línea guía horizontal para la firma
    final y = size.height * 0.7;
    canvas.drawLine(
      Offset(size.width * 0.1, y),
      Offset(size.width * 0.9, y),
      paint,
    );

    // Líneas guía verticales sutiles
    final dashedPaint = Paint()
      ..color = AppColors.grey300.withOpacity(0.2)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (int i = 1; i < 4; i++) {
      final x = size.width * (i / 4);
      _drawDashedLine(canvas, Offset(x, 0), Offset(x, size.height), dashedPaint);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 5.0;
    const dashSpace = 5.0;
    double distance = (end - start).distance;
    
    for (double i = 0; i < distance; i += dashWidth + dashSpace) {
      final startOffset = start + (end - start) * (i / distance);
      final endOffset = start + (end - start) * ((i + dashWidth) / distance);
      canvas.drawLine(startOffset, endOffset, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}