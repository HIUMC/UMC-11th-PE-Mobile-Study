import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/data/movies.dart';
import 'package:movielog/widgets/movie_list/movie_card.dart';
import 'package:movielog/widgets/movie_list/movie_grid.dart';
import 'package:movielog/widgets/movie_list/movie_list_empty.dart';
import 'package:movielog/widgets/movie_list/movie_list_error.dart';
import 'package:movielog/widgets/movie_list/movie_list_loading.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('Loading: 영화 카드 형태의 Skeleton을 표시한다', (tester) async {
    await tester.pumpWidget(_wrap(const MovieListLoading()));

    expect(find.byType(MovieCardSkeleton), findsWidgets);
    expect(find.byType(MovieCard), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('Empty: 안내 문구를 표시하고 콜백이 있으면 버튼을 제공한다', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      _wrap(MovieListEmpty(onShowAll: () => tapped = true)),
    );

    expect(find.text('조건에 맞는 영화가 없습니다.'), findsOneWidget);
    await tester.tap(find.text('전체 장르 보기'));
    expect(tapped, isTrue);
  });

  testWidgets('Empty: 콜백이 없으면 버튼을 표시하지 않는다', (tester) async {
    await tester.pumpWidget(_wrap(const MovieListEmpty()));

    expect(find.text('전체 장르 보기'), findsNothing);
  });

  testWidgets('Error: 안내 문구와 다시 시도 버튼을 표시한다', (tester) async {
    var retried = 0;
    await tester.pumpWidget(_wrap(MovieListError(onRetry: () => retried++)));

    expect(find.text('영화를 불러오지 못했습니다.'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, '다시 시도'));
    expect(retried, 1);
  });

  testWidgets('Success: MovieGrid가 영화 카드를 표시한다', (tester) async {
    await tester.pumpWidget(_wrap(MovieGrid(movies: movies.take(2).toList())));

    expect(find.byType(MovieCard), findsNWidgets(2));
    expect(find.text('별빛 아래 우리'), findsOneWidget);
    expect(find.text('우주의 끝에서'), findsOneWidget);
  });
}
