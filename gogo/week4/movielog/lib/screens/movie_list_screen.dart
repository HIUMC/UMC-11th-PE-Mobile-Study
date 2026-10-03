import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../services/fake_movie_service.dart';
import '../services/movie_preferences.dart';
import '../theme/app_colors.dart';
import '../widgets/genre_filter_sheet.dart';
import '../widgets/movie_grid.dart';
import '../widgets/movie_states.dart';

// === [학습 · 4주차] Future 결과 + 화면 상태 + 로컬 설정을 연결하는 화면 ===
// service/preferences를 외부에서 주입하면 테스트에서 실제 저장소 없이도 검증 가능.
class MovieListScreen extends StatefulWidget {
  const MovieListScreen({
    super.key,
    this.initialQuery = '',
    this.initialGenres = const [],
    this.service = const FakeMovieService(),
    this.preferences,
  });
  final String initialQuery;
  final List<String> initialGenres;
  final FakeMovieService service;
  final MoviePreferences? preferences;
  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  late final TextEditingController _search;
  late final MoviePreferences _preferences;
  late Future<List<Movie>> _moviesFuture;
  Future<void> _saveQueue = Future.value();
  String _genre = '전체', _sort = '기본순';
  bool _ready = false, _searching = false;
  MovieResponse _mode = MovieResponse.success;
  static const _sorts = ['기본순', '평점순', '최신순'];

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: widget.initialQuery);
    _searching = widget.initialQuery.isNotEmpty;
    _preferences = widget.preferences ?? MoviePreferences();
    // [핵심 1 · Future 수명] State 생성 시 한 번 시작하고 같은 Future 재사용.
    // build에서 생성하면 검색·장르 변경으로 다시 그릴 때마다 조회가 반복됨.
    _moviesFuture = _initialize();
  }

  Future<List<Movie>> _initialize() async {
    // [핵심 2 · Future.wait] 독립 작업을 함께 시작하고 모두 끝날 때까지 대기.
    // results 순서는 완료 순서가 아닌 전달한 Future 순서. 하나라도 실패하면 오류 전달.
    final results = await Future.wait<Object>([_restore(), _fetch()]);
    return results[1] as List<Movie>;
  }

  Future<bool> _restore() async {
    try {
      final settings = await Future.wait([
        _preferences.readGenre(),
        _preferences.readSort(),
      ]);
      // [핵심 3 · mounted] await 중 화면이 제거됐을 수 있으므로 setState 전에 확인.
      if (!mounted) return false;
      final genre = widget.initialGenres.isNotEmpty
          ? widget.initialGenres.first
          : settings[0];
      setState(() {
        _genre = movieGenres.contains(genre) ? genre : '전체';
        _sort = _sorts.contains(settings[1]) ? settings[1] : '기본순';
      });
    } catch (_) {
      _notify('저장된 설정을 읽지 못해 기본 설정으로 시작합니다.');
    } finally {
      // 성공·실패 모두 설정 로딩 종료. 복원 중 선택을 막아 늦게 온 값의 덮어쓰기 방지.
      if (mounted) setState(() => _ready = true);
    }
    return true;
  }

  // [도전 · timeout] 3초가 지나면 TimeoutException 전달. 원래 작업 자체는 취소되지 않음.
  Future<List<Movie>> _fetch() => widget.service
      .fetchMovies(mode: _mode)
      .timeout(const Duration(seconds: 3));

  Future<void> _reload({MovieResponse? mode}) async {
    if (mode != null) _mode = mode;
    // [핵심 4 · 재시도] 새 Future로 교체해야 FutureBuilder가 다시 waiting부터 시작.
    // setState 안에서는 값만 바꾸고, 비동기 대기는 바깥에서 수행.
    final next = _fetch();
    setState(() {
      _moviesFuture = next;
    });
    try {
      await next;
    } catch (_) {
      // 오류 UI는 FutureBuilder가 담당. 여기서는 새로고침 Future의 예외 전파만 처리.
    }
  }

  void _notify(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _save({String? genre, String? sort}) {
    // [핵심 5 · 저장 순서] then으로 직전 저장 뒤에 다음 저장 연결.
    // 빠르게 연속 선택해도 오래된 값이 나중에 저장되는 역전 방지.
    _saveQueue = _saveQueue.then((_) async {
      try {
        if (genre != null) await _preferences.saveGenre(genre);
        if (sort != null) await _preferences.saveSort(sort);
      } catch (_) {
        _notify('설정을 저장하지 못했어요. 다시 선택해 주세요.');
      }
    });
  }

  @override
  void didUpdateWidget(covariant MovieListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialQuery != widget.initialQuery) {
      _search.text = widget.initialQuery;
      _searching = widget.initialQuery.isNotEmpty;
    }
    if (oldWidget.initialGenres.join(',') != widget.initialGenres.join(',')) {
      _genre =
          widget.initialGenres.where(movieGenres.contains).firstOrNull ?? '전체';
      _save(genre: _genre);
    }
  }

  // [핵심 6 · 로컬 필터] 이미 받은 목록만 가공. 필터·정렬 변경에는 추가 조회 불필요.
  // toList로 새 목록을 만들어 sort가 원본 응답 순서를 바꾸지 않도록 처리.
  List<Movie> _filter(List<Movie> movies) {
    final query = _search.text.trim().toLowerCase();
    final filtered = movies
        .where(
          (m) =>
              (_genre == '전체' || m.genre == _genre) &&
              (m.title.toLowerCase().contains(query) ||
                  m.genre.toLowerCase().contains(query)),
        )
        .toList();
    if (_sort == '평점순') filtered.sort((a, b) => b.rating.compareTo(a.rating));
    if (_sort == '최신순') filtered.sort((a, b) => b.year.compareTo(a.year));
    return filtered;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      titleSpacing: 20,
      centerTitle: false,
      title: const Text(
        '영화',
        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
      ),
      actions: [
        IconButton(
          tooltip: '영화 검색',
          icon: const Icon(Icons.search),
          onPressed: () => setState(() {
            _searching = !_searching;
            if (!_searching) _search.clear();
          }),
        ),
        if (kDebugMode)
          PopupMenuButton<MovieResponse>(
            tooltip: '실습 상태',
            icon: const Icon(Icons.science_outlined),
            onSelected: (mode) => _reload(mode: mode),
            itemBuilder: (_) => const [
              PopupMenuItem(value: MovieResponse.success, child: Text('성공')),
              PopupMenuItem(value: MovieResponse.empty, child: Text('빈 결과')),
              PopupMenuItem(
                value: MovieResponse.failure,
                child: Text('오류 (1회)'),
              ),
              PopupMenuItem(
                value: MovieResponse.slow,
                child: Text('시간 초과 (1회)'),
              ),
            ],
          ),
      ],
    ),
    body: Column(
      children: [
        if (_searching)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: '영화 제목 검색',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        SizedBox(
          height: 52,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: movieGenres.length + 1,
            separatorBuilder: (_, index) => const SizedBox(width: 8),
            itemBuilder: (_, index) {
              final genre = ['전체', ...movieGenres][index];
              return ChoiceChip(
                label: Text(genre),
                selected: _genre == genre,
                onSelected: !_ready
                    ? null
                    : (_) {
                        setState(() => _genre = genre);
                        _save(genre: genre);
                      },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$_genre 영화'),
              DropdownButton<String>(
                value: _sort,
                underline: const SizedBox(),
                onChanged: !_ready
                    ? null
                    : (value) {
                        if (value == null) return;
                        setState(() => _sort = value);
                        _save(sort: value);
                      },
                items: _sorts
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
              ),
            ],
          ),
        ),
        Expanded(
          // [핵심 7 · 네 가지 상태] waiting → error → empty/success 순서로 분기.
          // 재조회 중 이전 data가 남을 수 있으므로 waiting을 먼저 확인.
          child: FutureBuilder<List<Movie>>(
            future: _moviesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const MovieLoading();
              }
              Widget content;
              if (snapshot.hasError) {
                content = MovieError(
                  timedOut: snapshot.error is TimeoutException,
                  onRetry: () => _reload(mode: MovieResponse.success),
                );
              } else {
                final movies = _filter(snapshot.data ?? []);
                content = movies.isEmpty
                    ? MovieEmpty(
                        onReset: () {
                          setState(() {
                            _genre = '전체';
                            _search.clear();
                          });
                          _save(genre: '전체');
                          _reload(mode: MovieResponse.success);
                        },
                      )
                    : MovieGrid(movies: movies);
              }
              // [도전 · 새로고침] onRefresh의 Future가 끝나면 새로고침 표시도 종료.
              return RefreshIndicator(
                onRefresh: () => _reload(mode: MovieResponse.success),
                child: content,
              );
            },
          ),
        ),
      ],
    ),
  );
}
