import 'package:shared_preferences/shared_preferences.dart';

// === [학습 · SharedPreferencesAsync] 장르·정렬 같은 공개 설정의 로컬 저장 ===
// 읽기도 Future를 반환하므로 await 필요. 앱 재실행 후에도 값 유지.
// JWT·비밀번호 저장용이 아님. 민감한 값은 별도 보안 저장소 사용.
class MoviePreferences {
  late final SharedPreferencesAsync _preferences = SharedPreferencesAsync();
  // 저장값이 없으면 ?? 뒤의 기본값 사용. 저장된 값의 유효성 검사는 화면에서 담당.
  Future<String> readGenre() async =>
      await _preferences.getString('week4.genre') ?? '전체';
  Future<String> readSort() async =>
      await _preferences.getString('week4.sort') ?? '기본순';
  Future<void> saveGenre(String value) =>
      _preferences.setString('week4.genre', value);
  Future<void> saveSort(String value) =>
      _preferences.setString('week4.sort', value);
}
