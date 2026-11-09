import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class MovieLogButton extends StatelessWidget {
  const MovieLogButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.width,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: 44,
    child: ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: const Color(0xFFBDBDBD),
        disabledForegroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: isLoading
          ? Semantics(
              label: '확인 중',
              child: const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            )
          : Text(label),
    ),
  );
}
