import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/tts_helper.dart';
import '../../data/models/exercise.dart';

class ReadingWidget extends StatefulWidget {
  final ReadingExercise exercise;
  final void Function(bool) onAnswer;

  const ReadingWidget({super.key, required this.exercise, required this.onAnswer});

  @override
  State<ReadingWidget> createState() => _ReadingWidgetState();
}

class _ReadingWidgetState extends State<ReadingWidget> {
  int _qIndex = 0;
  String? _selected;
  int _correct = 0;
  bool _isPlaying = false;
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

  void _select(String id) {
    if (_selected != null) return;
    setState(() => _selected = id);
    final q = widget.exercise.questions[_qIndex];
    if (id == q.correctId) setState(() => _correct++);

    Future.delayed(const Duration(milliseconds: 600), () {
      if (_qIndex + 1 >= widget.exercise.questions.length) {
        widget.onAnswer(_correct > widget.exercise.questions.length / 2);
      } else {
        setState(() { _qIndex++; _selected = null; });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.exercise.questions.isEmpty) {
      return const Center(child: Text('Không có câu hỏi'));
    }
    final q = widget.exercise.questions[_qIndex];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ĐỌC HIỂU', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(widget.exercise.passageCs, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark, height: 1.6)),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _isPlaying ? null : () => _speak(widget.exercise.passageCs),
                      child: Icon(
                        _isPlaying ? Icons.volume_up : Icons.volume_up_outlined,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 16),
                Text(widget.exercise.passageVi, style: const TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.6)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Câu ${_qIndex + 1}/${widget.exercise.questions.length}: ${q.question}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 12),
          ...q.options.map((opt) {
            Color bg = AppColors.white, border = AppColors.border, text = AppColors.textDark;
            if (_selected != null) {
              if (opt.id == q.correctId) { bg = AppColors.success; border = AppColors.success; text = Colors.white; }
              else if (opt.id == _selected) { bg = AppColors.error; border = AppColors.error; text = Colors.white; }
              else { bg = AppColors.cream; text = AppColors.textMuted; }
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => _select(opt.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: border, width: 2)),
                  child: Text(opt.text, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: text)),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
