import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/exercise.dart';

String _normalize(String s) => s.toLowerCase().replaceAll(RegExp(r'[^a-záčďéěíňóřšťůúýž\s]'), '').trim();

int _levenshtein(String a, String b) {
  final m = a.length, n = b.length;
  final dp = List.generate(m + 1, (_) => List.filled(n + 1, 0));
  for (int i = 0; i <= m; i++) dp[i][0] = i;
  for (int j = 0; j <= n; j++) dp[0][j] = j;
  for (int i = 1; i <= m; i++) {
    for (int j = 1; j <= n; j++) {
      dp[i][j] = a[i - 1] == b[j - 1]
          ? dp[i - 1][j - 1]
          : 1 + [dp[i - 1][j], dp[i][j - 1], dp[i - 1][j - 1]].reduce(min);
    }
  }
  return dp[m][n];
}

bool _isMatch(String heard, String expected) {
  final h = _normalize(heard);
  final e = _normalize(expected);
  if (h == e) return true;
  final threshold = (e.length * 0.25).ceil();
  return _levenshtein(h, e) <= threshold;
}

class SpeakingWidget extends StatefulWidget {
  final SpeakingExercise exercise;
  final void Function(bool) onAnswer;

  const SpeakingWidget({super.key, required this.exercise, required this.onAnswer});

  @override
  State<SpeakingWidget> createState() => _SpeakingWidgetState();
}

class _SpeakingWidgetState extends State<SpeakingWidget> {
  final FlutterTts _tts = FlutterTts();
  final SpeechToText _stt = SpeechToText();
  bool _listening = false;
  String _heard = '';
  String _phase = 'idle'; // idle | listening | result

  @override
  void initState() {
    super.initState();
    _tts.setLanguage('cs-CZ');
  }

  @override
  void dispose() {
    _tts.stop();
    _stt.stop();
    super.dispose();
  }

  Future<void> _listen() async {
    final available = await _stt.initialize();
    if (!available) {
      setState(() { _heard = 'Microphone không khả dụng'; _phase = 'result'; });
      return;
    }
    setState(() { _listening = true; _phase = 'listening'; _heard = ''; });
    await _stt.listen(
      onResult: (result) {
        setState(() => _heard = result.recognizedWords);
        if (result.finalResult) setState(() { _listening = false; _phase = 'result'; });
      },
      localeId: 'cs-CZ',
    );
  }

  void _stopListening() {
    _stt.stop();
    setState(() { _listening = false; _phase = 'result'; });
  }

  @override
  Widget build(BuildContext context) {
    final matched = _phase == 'result' && _isMatch(_heard, widget.exercise.answer);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text('NÓI THEO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 1.5)),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                Text(widget.exercise.prompt, style: const TextStyle(fontSize: 14, color: AppColors.textMuted)),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    await _tts.speak(widget.exercise.answer);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.volume_up, color: AppColors.primary, size: 22),
                      const SizedBox(width: 8),
                      Text(widget.exercise.answer, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(widget.exercise.pronunciation, style: const TextStyle(fontSize: 14, color: AppColors.textMuted)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Mic button
          GestureDetector(
            onTap: _listening ? _stopListening : _listen,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _listening ? AppColors.error : AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(_listening ? Icons.stop : Icons.mic, size: 40, color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _phase == 'listening' ? 'Đang nghe...' : 'Nhấn để nói',
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          if (_phase == 'result' && _heard.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: matched ? AppColors.successLight : AppColors.errorLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    matched ? '✓ Chính xác!' : '✗ Chưa khớp',
                    style: TextStyle(fontWeight: FontWeight.w700, color: matched ? AppColors.success : AppColors.error),
                  ),
                  const SizedBox(height: 4),
                  Text('Bạn nói: "$_heard"', style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => widget.onAnswer(matched),
              child: const Text('Tiếp tục'),
            ),
          ],
          if (_phase == 'result' && _heard.isEmpty) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => widget.onAnswer(false),
              child: const Text('Bỏ qua'),
            ),
          ],
        ],
      ),
    );
  }
}
