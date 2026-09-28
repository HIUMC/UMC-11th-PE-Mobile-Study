import 'package:flutter/material.dart';

abstract final class AppColors { // abstract는 인스턴스를 만들 수 없다는 뜻. final은 상속할 수 없다는 뜻. 즉 상수를 담는 상자일 뿐 객체로 만들거나 확장할 일 없다는 뜻
  static const violet = Color(0xFF6750A4); // static이라 인스턴스 없이 AppColors.violet으로 바로 접근 가능

  static const warmWhite = Color(0xFFFAF9F5);
  static const white = Color(0xFFFFFFFF);

  static const black = Color(0xFF1C1B1F);
  static const gray = Color(0xFF79747E);
}