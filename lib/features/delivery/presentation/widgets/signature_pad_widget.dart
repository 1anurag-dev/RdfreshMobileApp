import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import '../../../../core/theme/app_theme.dart';

class SignaturePadWidget extends StatefulWidget {
  final Function(String signatureData) onSignatureChanged;
  final bool isEnabled;

  const SignaturePadWidget({
    super.key,
    required this.onSignatureChanged,
    this.isEnabled = true,
  });

  @override
  State<SignaturePadWidget> createState() => _SignaturePadWidgetState();
}

class _SignaturePadWidgetState extends State<SignaturePadWidget> {
  late final SignatureController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SignatureController(
      penStrokeWidth: 3.0,
      penColor: AppColors.primaryGreenDark,
      exportBackgroundColor: Colors.white,
    );
    
    _controller.addListener(_onSignatureChanged);
  }

  @override
  void didUpdateWidget(SignaturePadWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isEnabled && oldWidget.isEnabled) {
      _controller.clear();
      widget.onSignatureChanged('');
    }
  }

  void _onSignatureChanged() {
    if (widget.isEnabled) {
      _updateSignature();
    }
  }

  void _updateSignature() {
    if (!_controller.isEmpty) {
      exportSignature().then((signature) {
        widget.onSignatureChanged(signature);
      });
    } else {
      widget.onSignatureChanged('');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: context.borderColor),
        borderRadius: AppRadius.mdBr,
        color: context.cardColor,
      ),
      child: Stack(
        children: [
          Signature(
            controller: _controller,
            height: 200,
            backgroundColor: context.cardColor,
          ),
          if (!widget.isEnabled)
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: context.inputFillColor,
                borderRadius: AppRadius.mdBr,
              ),
              child: Center(
                child: Text(
                  'Signature disabled',
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ),
            ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: widget.isEnabled ? _clearSignature : null,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: context.inputFillColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.clear,
                  size: 16,
                  color: widget.isEnabled
                      ? context.textSecondary
                      : context.borderColor,
                ),
              ),
            ),
          ),
          if (_controller.isEmpty && widget.isEnabled)
            Positioned.fill(
              child: Center(
                child: Text(
                  'Sign here',
                  style: AppTypography.bodyLarge.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _clearSignature() {
    _controller.clear();
    widget.onSignatureChanged('');
  }

  Future<String> exportSignature() async {
    if (!_controller.isEmpty) {
      final Uint8List? data = await _controller.toPngBytes();
      if (data != null) {
        return 'data:image/png;base64,${data.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join()}';
      }
    }
    return '';
  }
}
