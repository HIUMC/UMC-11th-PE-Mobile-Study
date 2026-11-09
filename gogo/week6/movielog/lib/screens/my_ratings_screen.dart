import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/rating_dto.dart';
import '../theme/app_colors.dart';
import '../view_models/my_ratings_view_model.dart';
import '../widgets/movielog_button.dart';

class MyRatingsScreen extends StatelessWidget {
  const MyRatingsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('내가 등록한 평점'), centerTitle: true),
    body: SafeArea(
      child: Consumer<MyRatingsViewModel>(
        builder: (context, vm, _) {
          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '학습용 회원 1의 공개 평점입니다.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              Expanded(
                child: switch (vm.status) {
                  MyRatingsLoadStatus.idle || MyRatingsLoadStatus.loading =>
                    const Center(child: CircularProgressIndicator()),
                  MyRatingsLoadStatus.empty => _StatusPanel(
                    message: '등록된 평점이 없습니다.',
                    onRetry: vm.load,
                  ),
                  MyRatingsLoadStatus.error => _StatusPanel(
                    message: vm.message!,
                    onRetry: vm.load,
                  ),
                  MyRatingsLoadStatus.success => RefreshIndicator(
                    onRefresh: vm.load,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      children: [
                        if (vm.message != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(vm.message!),
                          ),
                        for (final entry in vm.ratings)
                          _RatingCard(entry: entry),
                      ],
                    ),
                  ),
                },
              ),
            ],
          );
        },
      ),
    ),
  );
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          MovieLogButton(label: '다시 시도', width: 140, onPressed: onRetry),
        ],
      ),
    ),
  );
}

class _RatingCard extends StatelessWidget {
  const _RatingCard({required this.entry});
  final RatingWithMovie entry;
  @override
  Widget build(BuildContext context) {
    final rating = entry.rating;
    final path = entry.movie?.posterPath;
    final date = rating.createdAt.toLocal();
    final placeholder = Container(
      color: AppColors.primaryTint,
      child: const Center(
        child: Icon(Icons.movie_outlined, color: AppColors.primary),
      ),
    );
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 76,
                height: 114,
                child: path == null
                    ? placeholder
                    : Image.network(
                        'https://image.tmdb.org/t/p/w185$path',
                        fit: BoxFit.cover,
                        errorBuilder: (_, error, stack) => placeholder,
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.movie?.title ?? '영화 정보를 불러올 수 없습니다',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '영화 ID ${rating.movieId}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '★ ${rating.score} / 5',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (rating.comment != null && rating.comment!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(rating.comment!),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
