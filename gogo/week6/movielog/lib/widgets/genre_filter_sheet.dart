import 'package:flutter/material.dart';

const movieGenres = ['드라마', 'SF', '애니메이션', '스릴러', '액션', '로맨스', '다큐멘터리'];

class GenreFilterSheet extends StatefulWidget {
  const GenreFilterSheet({super.key, required this.selectedGenres});

  final Set<String> selectedGenres;

  @override
  State<GenreFilterSheet> createState() => _GenreFilterSheetState();
}

class _GenreFilterSheetState extends State<GenreFilterSheet> {
  late final Set<String> _draft = {...widget.selectedGenres};

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.9,
      builder: (context, controller) => Column(
        children: [
          Expanded(
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '장르 필터',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(_draft.clear),
                      child: const Text('초기화'),
                    ),
                  ],
                ),
                const Text('여러 장르를 선택할 수 있어요. 선택하지 않으면 전체를 보여줘요.'),
                const SizedBox(height: 8),
                for (final genre in movieGenres)
                  CheckboxListTile(
                    title: Text(genre),
                    value: _draft.contains(genre),
                    onChanged: (selected) => setState(() {
                      if (selected == true) {
                        _draft.add(genre);
                      } else {
                        _draft.remove(genre);
                      }
                    }),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.pop(context, Set<String>.of(_draft)),
                  child: Text(
                    _draft.isEmpty
                        ? '전체 영화 보기 · 확인'
                        : '${_draft.length}개 장르 적용 · 확인',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
