import 'package:flutter/foundation.dart';

import '../core/network/tmdb_error_message.dart';
import '../data/movies.dart';
import '../data/tmdb/tmdb_dto.dart';
import '../services/movie_list_preference.dart';
import '../services/tmdb_movie_service.dart';

enum MovieListLoadStatus { idle, loading, success, empty, error }

class MovieListViewModel extends ChangeNotifier {
  MovieListViewModel(this._service, {MovieListPreference? preference})
    : _preference = preference ?? MovieListPreference();

  final TmdbMovieService _service;
  final MovieListPreference _preference;

  MovieListLoadStatus status = MovieListLoadStatus.idle;
  String message = '';

  /// Chip으로 보여줄 장르. '전체'는 API에 없으므로 화면에서 앞에 붙입니다.
  List<TmdbGenreDto> genres = const [];

  /// null이면 '전체'
  int? selectedGenreId;
  MovieSortOrder sortOrder = MovieSortOrder.latest;

  List<Movie> _loaded = const [];

  /// 현재 정렬 기준을 적용한 목록
  List<Movie> get movies => sortOrder.apply(_loaded);

  bool get isFiltered => selectedGenreId != null;

  /// 영화 목록 요청이 진행 중인지. 이 동안에는 장르를 바꿀 수 없습니다.
  /// 첫 로딩, 장르 변경, 새로고침, 재시도 모두 해당됩니다.
  bool get isFetching => _isFetching;
  bool _isFetching = false;
  bool _disposed = false;

  /// 저장된 설정 → 장르 목록 → 영화 목록 순서로 불러옵니다.
  Future<void> loadInitial() => _runExclusive(() async {
    status = MovieListLoadStatus.loading;
    _notify();

    try {
      final (savedGenre, savedSort) = await (
        _preference.readGenre(),
        _preference.readSortOrder(),
      ).wait;
      sortOrder = savedSort;

      genres = await _service.fetchGenres();
      // 저장된 장르가 현재 목록에 없으면 '전체'로 되돌립니다.
      final savedId = int.tryParse(savedGenre);
      selectedGenreId = genres.any((g) => g.id == savedId) ? savedId : null;
      // 영화 목록을 기다리는 동안에도 장르 Chip이 먼저 보이도록 알립니다.
      _notify();
    } catch (error) {
      _setError(error);
      return;
    }

    await _loadMovies();
  });

  /// 요청 중이면 무시합니다. 화면에서도 Chip을 비활성화하지만 ViewModel에서 한 번 더 막습니다.
  Future<void> selectGenre(int? genreId) async {
    if (_isFetching || genreId == selectedGenreId) return;

    await _runExclusive(() async {
      selectedGenreId = genreId;
      _preference.saveGenre(
        genreId == null ? MovieListPreference.allGenre : '$genreId',
      );
      status = MovieListLoadStatus.loading;
      _notify();
      await _loadMovies();
    });
  }

  /// 정렬은 이미 받은 목록에만 적용하므로 다시 요청하지 않습니다.
  void selectSortOrder(MovieSortOrder order) {
    sortOrder = order;
    _preference.saveSortOrder(order);
    _notify();
  }

  /// 당겨서 새로고침. 기존 목록을 유지한 채 다시 받습니다.
  Future<void> refresh() => _runExclusive(_loadMovies);

  /// 장르 목록부터 실패했을 수 있으므로 처음부터 다시 시도합니다.
  Future<void> retry() => genres.isEmpty
      ? loadInitial()
      : _runExclusive(() async {
          status = MovieListLoadStatus.loading;
          _notify();
          await _loadMovies();
        });

  /// 요청을 한 번에 하나만 실행합니다. 이미 진행 중이면 [task]를 실행하지 않습니다.
  Future<void> _runExclusive(Future<void> Function() task) async {
    if (_isFetching) return;
    _isFetching = true;
    _notify();
    try {
      await task();
    } finally {
      _isFetching = false;
      _notify();
    }
  }

  Future<void> _loadMovies() async {
    try {
      final page = await _service.discoverMovies(genreId: selectedGenreId);
      final genreNames = {for (final g in genres) g.id: g.name};
      _loaded = [for (final dto in page.results) dto.toMovie(genreNames)];
      status = _loaded.isEmpty
          ? MovieListLoadStatus.empty
          : MovieListLoadStatus.success;
    } catch (error) {
      _setError(error);
    }
  }

  void _setError(Object error) {
    status = MovieListLoadStatus.error;
    message = tmdbErrorMessage(
      error,
      fallback: '영화를 불러오지 못했습니다.\n잠시 후 다시 시도해 주세요.',
    );
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
