import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class MediaFeedScreen extends StatelessWidget {
  const MediaFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Nội dung'), backgroundColor: AppColors.white),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🎬', style: TextStyle(fontSize: 48)),
            SizedBox(height: 16),
            Text('Nội dung sắp ra mắt', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            SizedBox(height: 8),
            Text('Video và podcast tiếng Séc đang được cập nhật.', style: TextStyle(color: AppColors.textMuted), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
