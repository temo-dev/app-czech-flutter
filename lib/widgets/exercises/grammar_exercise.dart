import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/tts_helper.dart';
import '../../data/models/exercise.dart';

class GrammarWidget extends StatefulWidget {
  final GrammarExercise exercise;
  final void Function(bool) onAnswer;

  const GrammarWidget({super.key, required this.exercise, required this.onAnswer});

  @override
  State<GrammarWidget> createState() => _GrammarWidgetState();
}

class _GrammarWidgetState extends State<GrammarWidget> {
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
    final exampleCs = widget.exercise.example['cs'] as String? ?? '';
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rule card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEDE9FE),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFDDD6FE)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('📚 ${widget.exercise.ruleTitle}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF4C1D95))),
                const SizedBox(height: 6),
                Text(widget.exercise.ruleVi, style: const TextStyle(fontSize: 13, color: Color(0xFF5B21B6))),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      const Text('VD: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                      Expanded(child: Text('${widget.exercise.example['cs']} — ${widget.exercise.example['vi']}',
                          style: const TextStyle(fontSize: 13, color: AppColors.textDark))),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: exampleCs.isEmpty || _isPlaying ? null : () => _speak(exampleCs),
                        child: Icon(
                          _isPlaying ? Icons.volume_up : Icons.volume_up_outlined,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(widget.exercise.question, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 14),
          ...widget.exercise.options.map((opt) {
            Color bgColor = AppColors.white;
            Color borderColor = AppColors.border;
            Color textColor = AppColors.textDark;
            if (_selected != null) {
              if (opt.id == widget.exercise.correctId) { bgColor = AppColors.success; borderColor = AppColors.success; textColor = Colors.white; }
              else if (opt.id == _selected) { bgColor = AppColors.error; borderColor = AppColors.error; textColor = Colors.white; }
              else { bgColor = AppColors.cream; textColor = AppColors.textMuted; }
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => _select(opt.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor, width: 2)),
                  child: Text(opt.text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor)),
                ),
              ),
            );
          }),
          if (_selected != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(10)),
              child: Text('💡 ${widget.exercise.explanation}', style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
            ),
        ],
      ),
    );
  }
}
