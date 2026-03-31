import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';

class LessonCompleteScreen extends StatelessWidget {
  final String lessonTitle;
  final int xpEarned;
  final int correct;
  final int total;
  final int stars;
  final VoidCallback onContinue;

  const LessonCompleteScreen({
    super.key,
    required this.lessonTitle,
    required this.xpEarned,
    required this.correct,
    required this.total,
    required this.stars,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final accuracy = total > 0 ? (correct / total * 100).round() : 0;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 80))
                      .animate()
                      .scale(delay: 100.ms, duration: 600.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 16),
                  const Text('Hoàn thành!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textDark))
                      .animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 8),
                  Text(lessonTitle, style: const TextStyle(fontSize: 16, color: AppColors.textMuted))
                      .animate().fadeIn(delay: 400.ms),
                  const SizedBox(height: 32),
                  // Stars
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        Icons.star,
                        size: i < stars ? 44 : 36,
                        color: i < stars ? AppColors.star : AppColors.starEmpty,
                      ).animate(delay: (400 + i * 150).ms).scale(curve: Curves.elasticOut),
                    )),
                  ),
                  const SizedBox(height: 32),
                  // Stats
                  Row(
                    children: [
                      Expanded(child: _StatCard(label: 'XP kiếm được', value: '+$xpEarned', color: AppColors.primary)),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(label: 'Độ chính xác', value: '$accuracy%', color: AppColors.success)),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(label: 'Câu đúng', value: '$correct/$total', color: AppColors.textDark)),
                    ],
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: onContinue,
                    child: const Text('Tiếp tục'),
                  ).animate().fadeIn(delay: 800.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
