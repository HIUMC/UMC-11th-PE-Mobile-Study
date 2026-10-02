import 'package:shared_preferences/shared_preferences.dart';

class GenrePreference { // 마지막 선택 장르를 폰에 저장하고 꺼내는 역할만 담당
  GenrePreference({SharedPreferencesAsync? preferences})
      : _preferences = preferences ?? SharedPreferencesAsync(); // 따로 안 넘기면 기본 저장소 사용

  static const _selectedGenreKey = 'selected_genre'; // 저장할 때와 읽을 때 같은 Key를 써야 해서 상수로 고정

  final SharedPreferencesAsync _preferences; // 읽기·쓰기가 모두 Future인 저장소

  Future<String> read() async { // 저장된 장르를 꺼냄
    return await _preferences.getString(_selectedGenreKey) ?? '전체'; // 처음 실행이라 저장된 값이 없으면 전체
  }

  Future<void> save(String genre) async { // 장르를 저장
    await _preferences.setString(_selectedGenreKey, genre); // await해야 저장이 끝난 뒤 다음 줄로 감
  }

  Future<void> clear() async { // 저장된 장르를 지움
    await _preferences.remove(_selectedGenreKey);
  }
}