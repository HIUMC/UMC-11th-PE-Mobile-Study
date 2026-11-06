import 'package:flutter/material.dart';

class TmdbPosterImage extends StatelessWidget { // poster_path로 이미지 주소를 만들고, 없거나 실패하면 대체 이미지를 그림
  const TmdbPosterImage({
    super.key,
    required this.posterPath, // 꼭 넘기되 null이어도 됨
    required this.width,
    required this.height,
    this.fit = BoxFit.cover, // 틀을 꽉 채우고 넘치는 부분은 잘라냄
  });

  final String? posterPath;
  final double width;
  final double height;
  final BoxFit fit;

  static const _baseUrl = 'https://image.tmdb.org/t/p'; // TMDB 이미지 서버 기본 주소
  static const _size = 'w500'; // 가로 500 크기 버전

  String? get _imageUrl { // 기본 주소 + 크기 + 파일 경로
    if (posterPath == null || posterPath!.isEmpty) return null; // 경로가 없으면 주소도 없음
    return '$_baseUrl/$_size$posterPath'; // poster_path가 /로 시작해서 사이에 / 안 넣음
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _imageUrl;

    if (imageUrl == null) return _placeholder();

    return Image.network( // 인터넷 주소의 이미지를 받아서 그림
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, _, _) => _placeholder(), // 받기 실패해도 대체 이미지. 넘겨받는 값 세 개는 안 써서 _로 둠
    );
  }

  Widget _placeholder() { // 포스터와 같은 크기의 회색 상자. 목록 크기가 들쭉날쭉하지 않음
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported_outlined),
    );
  }
}