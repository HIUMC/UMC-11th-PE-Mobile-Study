class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.genre,
    required this.year,
    required this.posterAsset,
    required this.rating,
    required this.synopsis,
    required this.director,
    required this.runtime,
  });

  final int id;
  final String title;
  final String genre;
  final int year;
  final String posterAsset;
  final double rating;
  final String synopsis;
  final String director;
  final int runtime;
}
