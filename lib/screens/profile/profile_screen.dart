import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/content.dart';
import '../../state/auth/auth_notifier.dart';
import '../../state/progress/progress_notifier.dart';
import '../../state/review/review_notifier.dart';
import '../../state/user/user_notifier.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final auth = ref.watch(authProvider);
    final progress = ref.watch(progressProvider);
    final reviewState = ref.watch(reviewProvider);
    final dueCount = reviewState.getDueCount();
    final level = (user.xp / 100).floor() + 1;
    final xpInLevel = user.xp % 100;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.white,
            title: const Text('Hồ sơ'),
            pinned: true,
            bottom: const PreferredSize(preferredSize: Size.fromHeight(1), child: Divider(height: 1)),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Avatar & name
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            (auth.nickname ?? user.name).isNotEmpty
                                ? (auth.nickname ?? user.name)[0].toUpperCase()
                                : '?',
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(auth.nickname ?? user.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                        if (auth.isLoggedIn && auth.email != null) ...[
                          const SizedBox(height: 2),
                          Text(auth.email!, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        ],
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                          child: Text('Cấp ${user.cefrLevel.display}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                        ),
                        const SizedBox(height: 16),
                        // XP Level bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Cấp $level', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                            Text('$xpInLevel/100 XP', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: xpInLevel / 100,
                            backgroundColor: AppColors.cream,
                            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Stats grid
                  Row(
                    children: [
                      Expanded(child: _StatCard(value: '${user.xp}', label: 'Tổng XP', icon: '⚡')),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(value: '${user.streak}', label: 'Chuỗi ngày', icon: '🔥')),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(value: '${progress.completedLessonIds.length}', label: 'Bài học', icon: '📚')),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(value: '$dueCount', label: 'Ôn tập', icon: '🔄')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Notifications (mobile only)
                  if (!kIsWeb) Container(
                    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text('Nhắc nhở học hàng ngày', style: TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: const Text('Nhận thông báo để không quên học'),
                          value: user.notificationsEnabled,
                          activeColor: AppColors.primary,
                          onChanged: (v) => ref.read(userProvider.notifier).setNotifications(v),
                        ),
                        if (user.notificationsEnabled) ...[
                          const Divider(height: 1),
                          ListTile(
                            title: const Text('Giờ nhắc nhở'),
                            trailing: Text('${user.notificationHour}:00', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
                            onTap: () async {
                              final t = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay(hour: user.notificationHour, minute: 0),
                              );
                              if (t != null) ref.read(userProvider.notifier).setNotifications(true, hour: t.hour);
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Auth actions
                  if (auth.isLoggedIn) ...[
                    Container(
                      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.edit_outlined, color: AppColors.primary),
                            title: const Text('Đổi biệt danh', style: TextStyle(fontWeight: FontWeight.w600)),
                            trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
                            onTap: () => _showNicknameDialog(context, ref, auth.nickname ?? ''),
                          ),
                          const Divider(height: 1, color: AppColors.border),
                          ListTile(
                            leading: const Icon(Icons.logout, color: AppColors.error),
                            title: const Text('Đăng xuất', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.error)),
                            onTap: () async {
                              await ref.read(authProvider.notifier).signOut();
                            },
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
                      onPressed: () => context.push('/login'),
                      icon: const Icon(Icons.login),
                      label: const Text('Đăng nhập để tham gia cộng đồng'),
                    ),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _showNicknameDialog(BuildContext context, WidgetRef ref, String current) async {
  final controller = TextEditingController(text: current);
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Đổi biệt danh'),
      content: TextField(
        controller: controller,
        maxLength: 20,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Biệt danh mới'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Huỷ')),
        TextButton(
          onPressed: () async {
            final nickname = controller.text.trim();
            if (nickname.isEmpty) return;
            Navigator.pop(ctx);
            await ref.read(authProvider.notifier).setNickname(nickname);
          },
          child: const Text('Lưu'),
        ),
      ],
    ),
  );
  controller.dispose();
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final String icon;

  const _StatCard({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
