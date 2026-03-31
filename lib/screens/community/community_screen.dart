import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Cộng đồng'), backgroundColor: AppColors.white),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('👥', style: TextStyle(fontSize: 48)),
            SizedBox(height: 16),
            Text('Cộng đồng sắp ra mắt', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            SizedBox(height: 8),
            Text('Kết nối với người học tiếng Séc khác.', style: TextStyle(color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
