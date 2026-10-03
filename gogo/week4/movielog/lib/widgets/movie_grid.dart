import 'package:flutter/material.dart';

import '../models/movie.dart';
import 'movie_card.dart';

// [학습 · 위젯 분리] 성공 화면의 배치만 담당. 조회·저장은 화면/서비스가 담당.
// builder로 필요한 카드부터 생성하고 기존 MovieCard 재사용.
class MovieGrid extends StatelessWidget {
  const MovieGrid({super.key, required this.movies});
  final List<Movie> movies;
  @override
  Widget build(BuildContext context) => GridView.builder(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
    itemCount: movies.length,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 18,
      mainAxisSpacing: 20,
      mainAxisExtent: (MediaQuery.sizeOf(context).width - 58) / 2 / 0.69 + 82,
    ),
    itemBuilder: (context, index) => MovieCard(
      movie: movies[index],
      showScoreBadge: true,
      showMetadata: true,
    ),
  );
}
