import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/exercise.dart';
import '../../state/progress/progress_notifier.dart';

class ListeningWidget extends ConsumerStatefulWidget {
  final ListeningExercise exercise;
  final void Function(bool) onAnswer;

  const ListeningWidget({super.key, required this.exercise, required this.onAnswer});

  @override
  ConsumerState<ListeningWidget> createState() => _ListeningWidgetState();
}

class _ListeningWidgetState extends ConsumerState<ListeningWidget> {
  final FlutterTts _tts = FlutterTts();
  String? _selected;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _tts.setLanguage('cs-CZ');
    _speak();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _speak() async {
    final repo = ref.read(curriculumRepositoryProvider);
    final item = repo.getVocab(widget.exercise.vocabId);
    if (item == null) return;
    setState(() => _isPlaying = true);
    await _tts.speak(item.czech);
    setState(() => _isPlaying = false);
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
        children: [
          const Text('NGHE VÀ CHỌN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 1.5)),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _speak,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _isPlaying ? AppColors.primary : AppColors.cream,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: Icon(
                _isPlaying ? Icons.volume_up : Icons.play_circle_fill,
                size: 40,
                color: _isPlaying ? Colors.white : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(_isPlaying ? 'Đang phát...' : 'Nhấn để nghe lại',
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
          const SizedBox(height: 28),
          ...widget.exercise.options.map((opt) {
            Color bgColor = AppColors.white;
            Color borderColor = AppColors.border;
            Color textColor = AppColors.textDark;
            if (_selected != null) {
              if (opt.id == widget.exercise.correctId) {
                bgColor = AppColors.success; borderColor = AppColors.success; textColor = Colors.white;
              } else if (opt.id == _selected) {
                bgColor = AppColors.error; borderColor = AppColors.error; textColor = Colors.white;
              } else {
                bgColor = AppColors.cream; textColor = AppColors.textMuted;
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
