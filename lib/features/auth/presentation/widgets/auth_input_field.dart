import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';

enum AuthInputType { email, password, name, text }

class AuthInput extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final AuthInputType inputType;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const AuthInput({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.inputType = AuthInputType.text,
    this.controller,
    this.validator,
  });

  @override
  State<AuthInput> createState() => _AuthInputState();
}

class _AuthInputState extends State<AuthInput> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscureText,
          keyboardType: _getKeyboardType(),
          inputFormatters: _getInputFormatters(),
          validator: widget.validator ?? _getValidator(),
          style: AppTypography.bodyMedium.copyWith(
            color: context.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            constraints: const BoxConstraints(minHeight: 56),
            prefixIcon: Icon(
              widget.icon,
              color: context.textTertiary,
              size: 20,
            ),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: context.textTertiary,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscureText = !_obscureText),
                  )
                : null,
          ),
        ),
      ],
    );
  }

  TextInputType _getKeyboardType() {
    if (widget.inputType == AuthInputType.email) {
      return TextInputType.emailAddress;
    }
    return TextInputType.text;
  }

  List<TextInputFormatter>? _getInputFormatters() {
    if (widget.inputType == AuthInputType.name) {
      return [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))];
    }
    return null;
  }

  String? Function(String?)? _getValidator() {
    return (value) {
      if (value == null || value.isEmpty) {
        return '${widget.label} is required';
      }

      switch (widget.inputType) {
        case AuthInputType.email:
          final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
          if (!emailRegExp.hasMatch(value)) {
            return 'Please enter a valid email';
          }
          break;
        case AuthInputType.password:
          if (value.length < 6) {
            return 'Password must be at least 6 characters';
          }
          break;
        case AuthInputType.name:
          if (value.trim().split(' ').length < 2) {
            return 'Please enter your full name';
          }
          break;
        default:
          return null;
      }
      return null;
    };
  }
}
