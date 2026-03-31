import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';

class FeedbackOverlay extends StatelessWidget {
  final bool correct;
  final VoidCallback onNext;

  const FeedbackOverlay({super.key, required this.correct, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: correct ? AppColors.successLight : AppColors.errorLight,
        border: Border(
          top: BorderSide(
            color: correct ? AppColors.success : AppColors.error,
            width: 2,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            correct ? Icons.check_circle : Icons.cancel,
            color: correct ? AppColors.success : AppColors.error,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  correct ? 'Chính xác! 🎉' : 'Sai rồi!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: correct ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: correct ? AppColors.success : AppColors.error,
              minimumSize: const Size(100, 44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: onNext,
            child: const Text('Tiếp', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    ).animate().slideY(begin: 1, duration: 250.ms, curve: Curves.easeOut);
  }
}
