import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/tts_helper.dart';
import '../../data/models/exercise.dart';

class MultipleChoiceWidget extends StatefulWidget {
  final MultipleChoiceExercise exercise;
  final void Function(bool) onAnswer;

  const MultipleChoiceWidget({super.key, required this.exercise, required this.onAnswer});

  @override
  State<MultipleChoiceWidget> createState() => _MultipleChoiceWidgetState();
}

class _MultipleChoiceWidgetState extends State<MultipleChoiceWidget> {
  String? _selected;
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
    Future.delayed(const Duration(milliseconds: 600), () {
      widget.onAnswer(id == widget.exercise.correctId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('CHỌN ĐÁP ÁN ĐÚNG', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  widget.exercise.question,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textDark),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(minimumSize: const Size(0, 40)),
                  onPressed: _isPlaying ? null : () => _speak(widget.exercise.question),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_isPlaying ? Icons.volume_up : Icons.volume_up_outlined, size: 16),
                      const SizedBox(width: 6),
                      Text(_isPlaying ? 'Đang phát...' : 'Nghe phát âm'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...widget.exercise.options.map((opt) {
            Color bgColor = AppColors.white;
            Color borderColor = AppColors.border;
            Color textColor = AppColors.textDark;

            if (_selected != null) {
              if (opt.id == widget.exercise.correctId) {
                bgColor = AppColors.success;
                borderColor = AppColors.success;
                textColor = Colors.white;
              } else if (opt.id == _selected) {
                bgColor = AppColors.error;
                borderColor = AppColors.error;
                textColor = Colors.white;
              } else {
                bgColor = AppColors.cream;
                borderColor = AppColors.border;
                textColor = AppColors.textMuted;
              }
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => _select(opt.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor, width: 2),
                  ),
                  child: Text(opt.text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor)),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
