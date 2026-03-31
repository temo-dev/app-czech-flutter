import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/tts_helper.dart';
import '../../data/models/sm2_record.dart';
import '../../state/progress/progress_notifier.dart';
import '../../state/review/review_notifier.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  late List<Sm2Record> _dueItems;
  int _index = 0;
  bool _flipped = false;
  bool _isPlaying = false;
  int _reviewed = 0;
  final GlobalKey<FlipCardState> _cardKey = GlobalKey<FlipCardState>();
  final TtsHelper _tts = TtsHelper();

  @override
  void initState() {
    super.initState();
    _dueItems = ref.read(reviewProvider).getDueItems();
  }

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

  void _rate(int quality) {
    final item = _dueItems[_index];
    ref.read(reviewProvider.notifier).updateRecord(item.vocabId, quality);
    setState(() {
      _reviewed++;
      _flipped = false;
      if (_index + 1 < _dueItems.length) {
        _index++;
      } else {
        _index = _dueItems.length; // done
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_dueItems.isEmpty) {
      return _buildEmpty();
    }

    if (_index >= _dueItems.length) {
      return _buildComplete();
    }

    final item = _dueItems[_index];
    final repo = ref.read(curriculumRepositoryProvider);
    final vocab = repo.getVocab(item.vocabId);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text('Ôn tập ${_index + 1}/${_dueItems.length}'),
        backgroundColor: AppColors.white,
      ),
      body: SafeArea(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Progress
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _index / _dueItems.length,
                    backgroundColor: AppColors.cream,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 20),
                // Card
                Expanded(
                  child: FlipCard(
                    key: _cardKey,
                    flipOnTouch: true,
                    onFlip: () => setState(() => _flipped = true),
                    front: _buildCardFace(
                      content: vocab?.czech ?? item.vocabId,
                      sub: vocab?.pronunciation ?? '',
                      label: 'Tiếng Séc',
                      bg: AppColors.primary,
                      textColor: Colors.white,
                      hint: 'Nhấn để xem nghĩa',
                    ),
                    back: _buildCardFace(
                      content: vocab?.vietnamese ?? item.vocabId,
                      sub: vocab?.example?.vietnamese,
                      label: 'Tiếng Việt',
                      bg: AppColors.white,
                      textColor: AppColors.textDark,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
                      onPressed: _isPlaying ? null : () => _speak(vocab?.czech ?? item.vocabId),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_isPlaying ? Icons.volume_up : Icons.volume_up_outlined, size: 18),
                          const SizedBox(width: 6),
                          Text(_isPlaying ? 'Đang phát...' : 'Nghe phát âm'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (!_flipped)
                  const Text('Nhấn thẻ để xem nghĩa', style: TextStyle(color: AppColors.textMuted))
                else
                  Column(
                    children: [
                      const Text('Bạn nhớ tốt không?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _RateButton(label: 'Không nhớ', color: AppColors.error, onTap: () => _rate(1))),
                          const SizedBox(width: 8),
                          Expanded(child: _RateButton(label: 'Khó', color: AppColors.star, onTap: () => _rate(3))),
                          const SizedBox(width: 8),
                          Expanded(child: _RateButton(label: 'Dễ', color: AppColors.success, onTap: () => _rate(5))),
                        ],
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardFace({
    required String content,
    String? sub,
    required String label,
    required Color bg,
    required Color textColor,
    String? hint,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textColor.withOpacity(0.6), letterSpacing: 1)),
          const SizedBox(height: 20),
          Text(content, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: textColor), textAlign: TextAlign.center),
          if (sub != null && sub.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(sub, style: TextStyle(fontSize: 16, color: textColor.withOpacity(0.7))),
          ],
          if (hint != null) ...[
            const SizedBox(height: 24),
            Text(hint, style: TextStyle(fontSize: 13, color: textColor.withOpacity(0.5))),
          ],
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Ôn tập'), backgroundColor: AppColors.white),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 64)).animate().scale(curve: Curves.elasticOut),
            const SizedBox(height: 16),
            const Text('Không có gì để ôn tập!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(height: 8),
            const Text('Hãy học thêm bài mới để có từ vựng ôn tập.', style: TextStyle(color: AppColors.textMuted), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildComplete() {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('✅', style: TextStyle(fontSize: 72)).animate().scale(delay: 100.ms, curve: Curves.elasticOut),
              const SizedBox(height: 16),
              const Text('Ôn tập xong!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textDark)),
              const SizedBox(height: 8),
              Text('Đã ôn $_reviewed từ vựng', style: const TextStyle(color: AppColors.textMuted, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RateButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _RateButton({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onTap,
      child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }
}
