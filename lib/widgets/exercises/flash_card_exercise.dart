import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/tts_helper.dart';
import '../../data/models/exercise.dart';
import '../../state/progress/progress_notifier.dart';
import '../common/vocab_image.dart';

class FlashCardExerciseWidget extends ConsumerStatefulWidget {
  final FlashCardExercise exercise;
  final void Function(bool) onAnswer;

  const FlashCardExerciseWidget({super.key, required this.exercise, required this.onAnswer});

  @override
  ConsumerState<FlashCardExerciseWidget> createState() => _FlashCardExerciseWidgetState();
}

class _FlashCardExerciseWidgetState extends ConsumerState<FlashCardExerciseWidget> {
  bool _answered = false;
  bool _isPlaying = false;
  final GlobalKey<FlipCardState> _cardKey = GlobalKey<FlipCardState>();
  final TtsHelper _tts = TtsHelper();

  @override
  void dispose() {
    _tts.dispose();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    setState(() => _isPlaying = true);
    await _tts.speak(text);
    if (mounted) setState(() => _isPlaying = false);
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(curriculumRepositoryProvider);
    final item = repo.getVocab(widget.exercise.vocabId);

    if (item == null) {
      return const Center(child: Text('Không tìm thấy từ vựng'));
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text('THẺ TỪ VỰNG', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 1.5)),
          ),
          Expanded(
            child: FlipCard(
              key: _cardKey,
              flipOnTouch: true,
              onFlip: () {
                if (!_answered) setState(() => _answered = true);
              },
              front: _CardFace(
                content: item.czech,
                subContent: item.pronunciation,
                label: 'Tiếng Séc',
                bgColor: AppColors.primary,
                textColor: Colors.white,
                hint: item.imageUrl != null ? null : 'Nhấn để xem nghĩa',
                imageUrl: item.imageUrl,
              ),
              back: _CardFace(
                content: item.vietnamese,
                subContent: item.example?.vietnamese,
                label: 'Tiếng Việt',
                bgColor: AppColors.white,
                textColor: AppColors.textDark,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_answered) ...[
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
                  onPressed: () => _cardKey.currentState?.toggleCard(),
                  icon: const Icon(Icons.flip),
                  label: const Text('Lật thẻ'),
                ),
                const SizedBox(width: 12),
              ],
              OutlinedButton(
                style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48)),
                onPressed: _isPlaying ? null : () => _speak(item.czech),
                child: Icon(
                  _isPlaying ? Icons.volume_up : Icons.volume_up_outlined,
                  size: 20,
                ),
              ),
            ],
          ),
          if (_answered) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error, width: 2),
                    ),
                    onPressed: () => widget.onAnswer(false),
                    child: const Text('Chưa thuộc'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                    onPressed: () => widget.onAnswer(true),
                    child: const Text('Đã thuộc!'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  final String content;
  final String? subContent;
  final String label;
  final Color bgColor;
  final Color textColor;
  final String? hint;
  final String? imageUrl;

  const _CardFace({
    required this.content,
    this.subContent,
    required this.label,
    required this.bgColor,
    required this.textColor,
    this.hint,
    this.imageUrl,
  });

  Widget _buildContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: textColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textColor.withOpacity(0.7), letterSpacing: 1)),
        ),
        if (imageUrl != null) ...[
          const SizedBox(height: 12),
          VocabImage(imageUrl: imageUrl!, height: 140),
          const SizedBox(height: 12),
        ] else
          const SizedBox(height: 20),
        Text(content, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: textColor), textAlign: TextAlign.center),
        if (subContent != null) ...[
          const SizedBox(height: 8),
          Text(subContent!, style: TextStyle(fontSize: 16, color: textColor.withOpacity(0.7)), textAlign: TextAlign.center),
        ],
        if (hint != null) ...[
          const SizedBox(height: 24),
          Text(hint!, style: TextStyle(fontSize: 13, color: textColor.withOpacity(0.5))),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: imageUrl != null
          ? SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: _buildContent(),
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildContent(),
              ),
            ),
    );
  }
}
