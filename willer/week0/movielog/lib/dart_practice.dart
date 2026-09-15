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
    const Movie(id: 1, title: '오디세이'),
    const Movie(id: 2, title: '왕사남'),
    const Movie(id: 3, title: '어벤져스'),
  ]; 

  for (final movie in movies) {
    print(movie.title);
  }

  print(displayName('무비러버'));
  print(displayName(null));
  print(displayName(' '));
}
