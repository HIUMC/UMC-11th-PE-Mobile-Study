import 'package:shared_preferences/shared_preferences.dart';

import '../data/movies.dart';

/// 영화 목록 화면의 단순 설정값(마지막 장르, 정렬 방식)만 저장합니다.
/// JWT·비밀번호·개인정보는 여기에 저장하지 않습니다.
class MovieListPreference {
  MovieListPreference({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const allGenre = '전체';
  static const _selectedGenreKey = 'selected_genre';
  static const _sortOrderKey = 'movie_sort_order';

  final SharedPreferencesAsync _preferences;

  Future<String> readGenre() async {
    return await _preferences.getString(_selectedGenreKey) ?? allGenre;
  }

  Future<void> saveGenre(String genre) async {
    await _preferences.setString(_selectedGenreKey, genre);
  }

  Future<MovieSortOrder> readSortOrder() async {
    final name = await _preferences.getString(_sortOrderKey);
    return MovieSortOrder.values.firstWhere(
      (order) => order.name == name,
      orElse: () => MovieSortOrder.latest,
    );
  }

  Future<void> saveSortOrder(MovieSortOrder order) async {
    // enum 자체가 아니라 이름(String)만 저장합니다.
    await _preferences.setString(_sortOrderKey, order.name);
  }

  Future<void> clear() async {
    await _preferences.remove(_selectedGenreKey);
    await _preferences.remove(_sortOrderKey);
  }
}

enum MovieSortOrder {
  latest('최신순'),
  rating('평점순'),
  title('제목순');

  const MovieSortOrder(this.label);

  final String label;

  List<Movie> apply(Iterable<Movie> source) {
    final sorted = source.toList();
    switch (this) {
      case MovieSortOrder.latest:
        sorted.sort((a, b) => b.year.compareTo(a.year));
      case MovieSortOrder.rating:
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
      case MovieSortOrder.title:
        sorted.sort((a, b) => a.title.compareTo(b.title));
    }
    return sorted;
  }
}
