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
          widget.label.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textGrey,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscureText,
          keyboardType: _getKeyboardType(),
          inputFormatters: _getInputFormatters(),
          validator: widget.validator ?? _getValidator(),
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: Icon(widget.icon, color: AppColors.textGrey, size: 20),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.textGrey,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
          ),
        ),
      ],
    );
  }

  TextInputType _getKeyboardType() {
    if (widget.inputType == AuthInputType.email) return TextInputType.emailAddress;
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