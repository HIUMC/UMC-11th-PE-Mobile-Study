class TmdbGenreDto { // TMDB 공식 장르 하나. id는 요청에, name은 Chip에 씀
  const TmdbGenreDto({required this.id, required this.name});
  final int id;
  final String name;

  factory TmdbGenreDto.fromJson(Map<String, dynamic> json) {
    return TmdbGenreDto(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
    );
  }
}