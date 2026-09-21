import 'dart:io';

class Movie {
  const Movie({required this.id, required this.title});

  final int id; // final은 값 할당 후 다른 값으로 바꾸지 않겠다는 뜻
  final String title;
}

String displayName(String? nickname) {
  return nickname?.trim().isNotEmpty == true
      ? nickname!
            .trim() //null이 아님을 확신하고 !를 붙여서 사용
      : '이름 없음';
}

void main() {
  final movies = <Movie>[
    Movie(id: 1, title: '인사이드 아웃'),
    Movie(id: 2, title: '라라랜드'),
    Movie(id: 3, title: '인터스텔라'),
  ];

  for (final movie in movies) {
    stdout.writeln(movie.title);
  }
  final String? nickname = null;
  stdout.writeln(displayName(nickname));
}
