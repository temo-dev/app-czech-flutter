import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class LessonHeader extends StatelessWidget {
  final double progress;
  final int hearts;
  final int maxHearts;
  final VoidCallback onExit;

  const LessonHeader({
    super.key,
    required this.progress,
    required this.hearts,
    required this.maxHearts,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: onExit,
            child: const Icon(Icons.close, color: AppColors.textMuted, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
                builder: (_, value, __) => LinearProgressIndicator(
                  value: value,
                  backgroundColor: AppColors.cream,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  minHeight: 10,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Row(
            children: List.generate(maxHearts, (i) => Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Icon(
                i < hearts ? Icons.favorite : Icons.favorite_border,
                color: i < hearts ? AppColors.error : AppColors.border,
                size: 20,
              ),
            )),
          ),
        ],
      ),
    );
  }
}
