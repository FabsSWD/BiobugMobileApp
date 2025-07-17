// ignore_for_file: unused_import

import 'dart:typed_data';
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
    this.strokeWidth = 2.0,
    this.strokeColor = AppColors.primary,
  });

  @override
  State<SignatureCanvas> createState() => SignatureCanvasState();
}

class SignatureCanvasState extends State<SignatureCanvas> {
  late SignatureController _controller;
  final GlobalKey _signatureKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = SignatureController(
      penStrokeWidth: widget.strokeWidth,
      penColor: widget.strokeColor,
      exportBackgroundColor: Colors.white,
      onDrawStart: () => _onSignatureChanged(),
      onDrawMove: () => _onSignatureChanged(),
      onDrawEnd: () => _onSignatureChanged(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSignatureChanged() {
    if (widget.onSignatureChanged != null) {
      final points = _controller.points;
      final pointsCount = points.length;
      widget.onSignatureChanged!(pointsCount);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _signatureKey,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _controller.points.isEmpty ? AppColors.grey300 : AppColors.success,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Canvas
          Expanded(
            child: Signature(
              controller: _controller,
              backgroundColor: Colors.white,
            ),
          ),
          
          // Canvas Info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(6),
                bottomRight: Radius.circular(6),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.draw,
                  size: 16,
                  color: _controller.points.isEmpty ? AppColors.grey400 : AppColors.success,
                ),
                const SizedBox(width: 8),
                Text(
                  _controller.points.isEmpty 
                      ? 'Dibuje su firma aquí'
                      : 'Puntos: ${_controller.points.length}',
                  style: TextStyle(
                    fontSize: 12,
                    color: _controller.points.isEmpty ? AppColors.grey500 : AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  'Min: 300x150px',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.grey500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void clear() {
    _controller.clear();
    _onSignatureChanged();
  }

  Future<SignatureParams?> exportSignature() async {
    if (_controller.isEmpty) {
      return null;
    }

    try {
      // Get the canvas size
      final RenderBox renderBox = _signatureKey.currentContext!.findRenderObject() as RenderBox;
      final size = renderBox.size;

      // Export signature as image
      final Uint8List? signatureBytes = await _controller.toPngBytes(
        height: size.height.toInt(),
        width: size.width.toInt(),
      );

      if (signatureBytes == null) {
        return null;
      }

      // Calculate quality based on points density
      final pointsCount = _controller.points.length;
      final area = size.width * size.height;
      final density = pointsCount / area;
      final quality = (density * 1000).clamp(0.1, 1.0);

      return SignatureParams(
        imageBytes: signatureBytes,
        fileName: 'signature_${DateTime.now().millisecondsSinceEpoch}.png',
        quality: quality,
        compressionLevel: 6, // PNG compression level (0-9)
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
  int get pointsCount => _controller.points.length;
}