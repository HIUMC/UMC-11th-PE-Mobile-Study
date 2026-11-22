import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class LoadingOverlay extends StatelessWidget { // child 위에 어두운 막과 흰 인디케이터를 겹침
  const LoadingOverlay({super.key, required this.isLoading, required this.child});

  final bool isLoading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading) const ModalBarrier(dismissible: false, color: Colors.black45), // 아래 화면 터치를 막음
        if (isLoading)
          const Center(
            child: CircularProgressIndicator(color: AppColors.white),
          ),
      ],
    );
  }
}