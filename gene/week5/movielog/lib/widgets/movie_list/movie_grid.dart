import 'package:flutter/material.dart';

import '../../data/movies.dart';
import 'movie_card.dart';

const movieGridPadding = EdgeInsets.fromLTRB(16, 0, 16, 16);

/// 영화 카드와 Skeleton 카드가 같은 배치를 쓰도록 공유합니다.
const movieGridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 2,
  crossAxisSpacing: 16,
  mainAxisSpacing: 24,
  mainAxisExtent: 316.5,
);

class MovieGrid extends StatelessWidget {
  const MovieGrid({super.key, required this.movies});

  final List<Movie> movies;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      // 항목이 적어도 당겨서 새로고침이 동작하도록 항상 스크롤 가능하게 둡니다.
      physics: const AlwaysScrollableScrollPhysics(),
      padding: movieGridPadding,
      gridDelegate: movieGridDelegate,
      itemCount: movies.length,
      itemBuilder: (context, index) => MovieCard(movie: movies[index]),
    );
  }
}
