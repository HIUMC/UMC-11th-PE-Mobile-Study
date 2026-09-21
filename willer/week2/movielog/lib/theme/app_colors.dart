import 'package:flutter/material.dart'; // Color 클래스 사용

abstract final class AppColors { // abstract는 인스턴스를 만들 수 없다는 뜻. final은 상속할 수 없다는 뜻. 즉 상수를 담는 상자일 뿐 객체로 만들거나 확장할 일 없다는 뜻
  static const violet = Color(0xFF6750A4); // static이라 인스턴스 없이 AppColors.violet으로 바로 접근 가능. 0xFF는 불투명도(FF=완전 불투명), 나머지 6자리가 RGB
  static const violetLight = Color(0xFFD5CCE8); // 가입 버튼 비활성 상태 배경색

  static const warmWhite = Color(0xFFFAF9F5); // 앱 전체 배경. 순백이 아니라 살짝 따뜻한 톤
  static const white = Color(0xFFFFFFFF); // 버튼 활성 상태의 글자색

  static const black = Color(0xFF1C1B1F); // 완전한 검정(000000)이 아니라 살짝 보랏빛이 도는 검정
  static const gray = Color(0xFF79747E); // hint 텍스트, 보조 문구

  static const fieldFill = Color(0xFFF0EEEA); // 입력창 기본 배경. 배경이 따뜻한 톤이라 회색도 따뜻한 쪽으로 맞춤
  static const fieldBorder = Color(0xFFDDD9D2); // 입력창 기본 테두리

  static const error = Color(0xFFB3261E); // 오류 테두리·아이콘·메시지. Material 3 표준 에러색
  static const errorFill = Color(0xFFF7E8E7); // 오류 상태 배경으로 준비했으나 이번 구현에서는 사용하지 않음
}