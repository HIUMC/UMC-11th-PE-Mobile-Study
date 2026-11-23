import 'package:flutter/foundation.dart'; // ChangeNotifier 사용 가능

class LearningMemberSession extends ChangeNotifier { // 가입 결과의 memberId를 앱 전체에서 같이 씀. 메모리에만 있어서 앱을 끄면 사라짐
  int? memberId; // null이면 아직 가입 전. 이 값을 안다고 인증된 건 아님

  void setMemberId(int id) {
    memberId = id;
    notifyListeners();
  }

  void clear() {
    memberId = null;
    notifyListeners();
  }
}