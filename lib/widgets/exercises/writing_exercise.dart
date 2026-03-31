import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/tts_helper.dart';
import '../../data/models/exercise.dart';

String _normalize(String s) => s.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
int _levenshtein(String a, String b) {
  final m = a.length, n = b.length;
  final dp = List.generate(m + 1, (_) => List.filled(n + 1, 0));
  for (int i = 0; i <= m; i++) dp[i][0] = i;
  for (int j = 0; j <= n; j++) dp[0][j] = j;
  for (int i = 1; i <= m; i++) {
    for (int j = 1; j <= n; j++) {
      dp[i][j] = a[i - 1] == b[j - 1] ? dp[i - 1][j - 1] : 1 + [dp[i - 1][j], dp[i][j - 1], dp[i - 1][j - 1]].reduce(min);
    }
  }
  return dp[m][n];
}

class WritingWidget extends StatefulWidget {
  final WritingExercise exercise;
  final void Function(bool) onAnswer;

  const WritingWidget({super.key, required this.exercise, required this.onAnswer});

  @override
  State<WritingWidget> createState() => _WritingWidgetState();
}

class _WritingWidgetState extends State<WritingWidget> {
  final _controller = TextEditingController();
  bool _submitted = false;
  bool? _correct;
  bool _isPlaying = false;
  final TtsHelper _tts = TtsHelper();

  @override
  void dispose() {
    _controller.dispose();
    _tts.dispose();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    setState(() => _isPlaying = true);
    await _tts.speak(text);
    if (mounted) setState(() => _isPlaying = false);
  }

  void _submit() {
    final input = _normalize(_controller.text);
    final answer = _normalize(widget.exercise.answer);
    final threshold = (answer.length * 0.2).ceil();
    final ok = _levenshtein(input, answer) <= threshold;
    setState(() { _submitted = true; _correct = ok; });
    Future.delayed(const Duration(milliseconds: 800), () => widget.onAnswer(ok));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('VIẾT BẰNG TIẾNG SÉC', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(16)),
            child: Text(widget.exercise.promptVi, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          ),
          if (widget.exercise.hint != null) ...[
            const SizedBox(height: 8),
            Text('💡 Gợi ý: ${widget.exercise.hint}', style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
          ],
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            enabled: !_submitted,
            style: const TextStyle(fontSize: 18, color: AppColors.textDark),
            decoration: InputDecoration(
              hintText: 'Viết câu trả lời...',
              suffixIcon: _submitted
                  ? Icon(_correct! ? Icons.check_circle : Icons.cancel,
                      color: _correct! ? AppColors.success : AppColors.error)
                  : null,
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
          if (_submitted) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _correct! ? AppColors.successLight : AppColors.errorLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(_correct! ? Icons.check_circle : Icons.info_outline,
                      color: _correct! ? AppColors.success : AppColors.error, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Đáp án: ${widget.exercise.answer}',
                      style: TextStyle(fontSize: 14, color: _correct! ? AppColors.success : AppColors.error, fontWeight: FontWeight.w600))),
                  GestureDetector(
                    onTap: _isPlaying ? null : () => _speak(widget.exercise.answer),
                    child: Icon(
                      _isPlaying ? Icons.volume_up : Icons.volume_up_outlined,
                      size: 20,
                      color: _correct! ? AppColors.success : AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: !_submitted && _controller.text.trim().isNotEmpty ? _submit : null,
            child: const Text('Kiểm tra'),
          ),
        ],
      ),
    );
  }
}
