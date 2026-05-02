import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class StarRatingWidget extends StatefulWidget {
  final int initialRating;
  final Function(int rating) onRatingChanged;
  final bool isEnabled;

  const StarRatingWidget({
    super.key,
    this.initialRating = 0,
    required this.onRatingChanged,
    this.isEnabled = true,
  });

  @override
  State<StarRatingWidget> createState() => _StarRatingWidgetState();
}

class _StarRatingWidgetState extends State<StarRatingWidget> {
  late int _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: widget.isEnabled
              ? () {
                  setState(() {
                    _currentRating = index + 1;
                  });
                  widget.onRatingChanged(_currentRating);
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              index < _currentRating
                  ? Icons.star_rounded
                  : Icons.star_border_rounded,
              size: 32,
              color: widget.isEnabled
                  ? (index < _currentRating
                      ? AppColors.warning
                      : context.borderColor)
                  : context.borderColor,
            ),
          ),
        );
      }),
    );
  }
}
