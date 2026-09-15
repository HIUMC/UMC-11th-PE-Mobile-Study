class Movie {
  const Movie({required this.id, required this.title});

  final int id;
  final String title;
}

String displayName(String? nickname) {
  return nickname?.trim().isNotEmpty == true ? nickname! : '이름 없음';
}

void main() {
  final movies = <Movie>[
    const Movie(id: 1, title: '더드라마'),
    const Movie(id: 2, title: '악마는 프라다를 입는다2'),
    const Movie(id: 3, title: '어벤져스'),
  ]; 

  for (final movie in movies) {
    print(movie.title);
  }

  print(displayName('이동진평론가'));
  print(displayName(null));
  print(displayName(' '));
}