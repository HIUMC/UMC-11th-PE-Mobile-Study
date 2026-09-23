import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class MovieRatingInput extends StatelessWidget {
  const MovieRatingInput({
    super.key,
    required this.rating,
    required this.onChanged,
    this.itemSize = 36,
  });

  final double rating;
  final ValueChanged<double> onChanged;
  final double itemSize;

  @override
  Widget build(BuildContext context) {
    return RatingBar.builder(
      initialRating: rating,
      minRating: 0.5,
      allowHalfRating: true,
      itemCount: 5,
      itemSize: itemSize,
      itemPadding: const EdgeInsets.symmetric(horizontal: 2),
      itemBuilder: (context, index) =>
          const Icon(Icons.star_rounded, color: Color(0xFFFFB547)),
      onRatingUpdate: onChanged,
    );
  }
}

class MovieRatingIndicator extends StatelessWidget {
  const MovieRatingIndicator({
    super.key,
    required this.rating,
    this.itemSize = 16,
  });

  final double rating;
  final double itemSize;

  @override
  Widget build(BuildContext context) {
    return RatingBarIndicator(
      rating: rating,
      itemCount: 5,
      itemSize: itemSize,
      itemBuilder: (context, index) =>
          const Icon(Icons.star_rounded, color: Color(0xFFFFB547)),
    );
  }
}
