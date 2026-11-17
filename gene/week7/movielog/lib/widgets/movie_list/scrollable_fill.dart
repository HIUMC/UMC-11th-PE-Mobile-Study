import 'package:flutter/material.dart';

/// 내용이 화면보다 작아도 당겨서 새로고침이 동작하도록
/// 남은 높이를 채운 채 스크롤 가능하게 감쌉니다.
class ScrollableFill extends StatelessWidget {
  const ScrollableFill({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
