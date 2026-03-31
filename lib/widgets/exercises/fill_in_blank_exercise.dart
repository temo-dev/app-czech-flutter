import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/tts_helper.dart';
import '../../data/models/exercise.dart';

class FillInBlankWidget extends StatefulWidget {
  final FillBlankExercise exercise;
  final void Function(bool) onAnswer;

  const FillInBlankWidget({super.key, required this.exercise, required this.onAnswer});

  @override
  State<FillInBlankWidget> createState() => _FillInBlankWidgetState();
}

class _FillInBlankWidgetState extends State<FillInBlankWidget> {
  String? _selected;
  bool _submitted = false;
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

  void _submit() {
    if (_selected == null) return;
    setState(() => _submitted = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      widget.onAnswer(_selected == widget.exercise.answer);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ĐIỀN VÀO CHỖ TRỐNG', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(16)),
            child: Text(widget.exercise.sentenceVi, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          ),
          const SizedBox(height: 16),
          // Answer slot
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: _selected != null ? AppColors.primary.withOpacity(0.08) : AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _submitted
                    ? (_selected == widget.exercise.answer ? AppColors.success : AppColors.error)
                    : _selected != null
                        ? AppColors.primary
                        : AppColors.border,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selected ?? '___',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: _selected != null ? AppColors.primary : AppColors.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (_selected != null)
                  GestureDetector(
                    onTap: _isPlaying ? null : () => _speak(_selected!),
                    child: Icon(
                      _isPlaying ? Icons.volume_up : Icons.volume_up_outlined,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('TỪ GỢI Ý:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.exercise.wordBank.map((word) {
              final isSelected = _selected == word;
              return GestureDetector(
                onTap: _submitted ? null : () => setState(() => _selected = isSelected ? null : word),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: 2),
                  ),
                  child: Text(
                    word,
                    style: TextStyle(fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.textDark),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _selected != null && !_submitted ? _submit : null,
            child: const Text('Kiểm tra'),
          ),
        ],
      ),
    );
  }
}
