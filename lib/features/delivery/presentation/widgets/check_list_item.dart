import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class ChecklistItem extends StatelessWidget {
  final String label;
  const ChecklistItem({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 15, color: AppColors.primaryNavy))),
        ],
      ),
    );
  }
}