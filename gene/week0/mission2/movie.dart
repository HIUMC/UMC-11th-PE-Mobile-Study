class Movie {
  final String title;
  final String? nickname;

  Movie(this.title, {this.nickname});
}

void main() {
  List<Movie> movies = [
    Movie('기생충'),
    Movie('인터스텔라', nickname: ' 놀란명작'),
    Movie('인셉션'),
  ];

  for (var movie in movies) {
    print(movie.title);
  }

  for (var movie in movies) {
    String safeName = movie.nickname ?? '별명 없음';
    print(safeName);
  }

}
