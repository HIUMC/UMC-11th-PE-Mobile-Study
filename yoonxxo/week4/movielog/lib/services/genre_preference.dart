import 'package:shared_preferences/shared_preferences.dart';

// 마지막으로 선택한 장르를 저장하고 불러오는 클래스
class GenrePreference {
  GenrePreference({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  // SharedPreferences에 저장할 때 사용할 키
  static const _selectedGenreKey = 'selected_genre';

  // 실제로 장르 값을 저장하고 불러오는 객체
  final SharedPreferencesAsync _preferences;

  // 저장되어 있는 장르를 불러옴.
  // 저장된 값이 없다면 기본값으로 '전체'를 사용함.
  Future<String> read() async {
    return await _preferences.getString(_selectedGenreKey) ?? '전체';
  }

  // 선택한 장르를 저장함.
  Future<void> save(String genre) async {
    await _preferences.setString(_selectedGenreKey, genre);
  }

  // 저장되어 있는 장르를 삭제함.
  Future<void> clear() async {
    await _preferences.remove(_selectedGenreKey);
  }
}
