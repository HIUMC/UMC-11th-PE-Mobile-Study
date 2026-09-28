import 'package:flutter/foundation.dart';

/// 즐겨찾기한 영화 id 목록 (앱 실행 중에만 유지)
final favoriteMovieIds = ValueNotifier<Set<String>>({});

bool isFavorite(String movieId) => favoriteMovieIds.value.contains(movieId);

/// 즐겨찾기를 추가/삭제하고, 추가됐으면 true를 반환
bool toggleFavorite(String movieId) {
  final ids = {...favoriteMovieIds.value};
  final added = ids.add(movieId);
  if (!added) ids.remove(movieId);
  favoriteMovieIds.value = ids;
  return added;
}
