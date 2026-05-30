import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Map<String, String>? details;
  final Widget? content;

  const InfoCard({super.key, required this.title, this.icon, this.details, this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                CircleAvatar(backgroundColor: const Color(0xFFE8F5E9), child: Icon(icon, color: AppColors.primaryGreen, size: 20)),
                const SizedBox(width: 12),
              ],
              Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 20),
          if (details != null)
            ...details!.entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(child: Text(e.key, style: const TextStyle(color: AppColors.textGrey))),
                  const SizedBox(width: 8),
                  Flexible(child: Text(e.value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy), textAlign: TextAlign.end)),
                ],
              ),
            )),
          if (content != null) content!,
        ],
      ),
    );
  }
}