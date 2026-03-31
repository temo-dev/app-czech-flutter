import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ClassroomScreen extends StatelessWidget {
  const ClassroomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Lớp học'), backgroundColor: AppColors.white),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🏫', style: TextStyle(fontSize: 48)),
            SizedBox(height: 16),
            Text('Lớp học sắp ra mắt', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            SizedBox(height: 8),
            Text('Học nhóm và với giáo viên tiếng Séc.', style: TextStyle(color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
