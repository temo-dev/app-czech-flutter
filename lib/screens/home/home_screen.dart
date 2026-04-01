import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/content.dart';
import '../../state/user/user_notifier.dart';
import '../../state/progress/progress_notifier.dart';

const _cardColors = [
  (bg: Color(0xFFF2EDE4), text: AppColors.textDark, sub: AppColors.textMuted),
  (bg: Color(0xFFEDE9FE), text: Color(0xFF3B0764), sub: Color(0xFF7C3AED)),
  (bg: Color(0xFFFEF3C7), text: Color(0xFF451A03), sub: Color(0xFFD97706)),
  (bg: Color(0xFFE0F2FE), text: Color(0xFF0C4A6E), sub: Color(0xFF0284C7)),
];

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  ScrollController? _carouselController;

  @override
  void dispose() {
    _carouselController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final progress = ref.watch(progressProvider);
    final repo = ref.read(curriculumRepositoryProvider);
    final notifier = ref.read(progressProvider.notifier);
    final goalPct = (user.todayXP / user.dailyGoalXP).clamp(0.0, 1.0);

    final allLessons = <({Lesson lesson, Unit unit, int unitIndex})>[];
    for (int ui = 0; ui < repo.course.units.length; ui++) {
      final unit = repo.course.units[ui];
      for (final lesson in unit.lessons) {
        allLessons.add((lesson: lesson, unit: unit, unitIndex: ui));
      }
    }

    if (_carouselController == null) {
      int idx = allLessons.indexWhere((item) =>
          notifier.isLessonUnlocked(item.lesson.id) &&
          !progress.completedLessonIds.contains(item.lesson.id));
      if (idx == -1 && progress.lastLessonId != null) {
        idx = allLessons.indexWhere((item) => item.lesson.id == progress.lastLessonId);
      }
      if (idx < 0) idx = 0;
      const cardWidth = 164.0;
      _carouselController = ScrollController(initialScrollOffset: idx * cardWidth);
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          // Top bar
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.white,
              padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 12, 20, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Chào mừng trở lại,', style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
                            Text('${user.name} 👋', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                          ],
                        ),
                      ),
                      // Streak
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1EB),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Text('🔥', style: TextStyle(fontSize: 15)),
                            const SizedBox(width: 4),
                            Text(
                              '${user.streak}',
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // XP badge
                      GestureDetector(
                        onTap: () => context.go('/profile'),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.cream,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(Icons.person_outline, size: 20, color: AppColors.textMuted),
                        ),
                      ),
                    ],
                  ),
                  // Daily goal bar
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Mục tiêu hôm nay', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                      Text('${user.todayXP}/${user.dailyGoalXP} XP', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: goalPct),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOut,
                      builder: (_, value, __) => LinearProgressIndicator(
                        value: value,
                        backgroundColor: AppColors.cream,
                        valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: AppColors.border),
                ],
              ),
            ),
          ),

          // Lesson cards carousel
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text('BÀI HỌC CỦA BẠN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 1.5)),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 176,
                    child: ListView.builder(
                      controller: _carouselController,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: allLessons.length,
                      itemBuilder: (context, i) {
                        final item = allLessons[i];
                        final unlocked = ref.read(progressProvider.notifier).isLessonUnlocked(item.lesson.id);
                        final done = progress.completedLessonIds.contains(item.lesson.id);
                        final stars = progress.lessonStars[item.lesson.id] ?? 0;
                        final colors = _cardColors[item.unitIndex % _cardColors.length];

                        return _LessonCard(
                          lesson: item.lesson,
                          unit: item.unit,
                          unlocked: unlocked,
                          done: done,
                          stars: stars,
                          bgColor: colors.bg,
                          textColor: colors.text,
                          subColor: colors.sub,
                          onTap: unlocked ? () => context.push('/lesson/${item.lesson.id}') : null,
                        ).animate().fadeIn(delay: (i * 60).ms).slideX(begin: 0.3);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Units grid
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: const Text('ĐƠN VỊ HỌC', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 1.5)),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final unit = repo.course.units[i];
                  final prog = ref.read(progressProvider.notifier).getUnitProgress(unit.id);
                  return _UnitCard(unit: unit, completed: prog.completed, total: prog.total)
                      .animate().fadeIn(delay: (i * 80).ms).scale(begin: const Offset(0.9, 0.9));
                },
                childCount: repo.course.units.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final Lesson lesson;
  final Unit unit;
  final bool unlocked;
  final bool done;
  final int stars;
  final Color bgColor;
  final Color textColor;
  final Color subColor;
  final VoidCallback? onTap;

  const _LessonCard({
    required this.lesson,
    required this.unit,
    required this.unlocked,
    required this.done,
    required this.stars,
    required this.bgColor,
    required this.textColor,
    required this.subColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 152,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: unlocked ? bgColor : AppColors.cream.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(unit.icon, style: const TextStyle(fontSize: 24)),
                if (!unlocked)
                  const Icon(Icons.lock_outline, size: 16, color: AppColors.textMuted)
                else if (done)
                  const Icon(Icons.check_circle, size: 16, color: AppColors.success),
              ],
            ),
            const Spacer(),
            Text(
              lesson.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: unlocked ? textColor : AppColors.textMuted,
              ),
            ),
            if (lesson.subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                lesson.subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: unlocked ? subColor : AppColors.textLight),
              ),
            ],
            const SizedBox(height: 6),
            Row(
              children: [
                Text('${lesson.xpReward} XP', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
                const Spacer(),
                if (done)
                  Row(
                    children: List.generate(3, (i) => Icon(
                      Icons.star,
                      size: 10,
                      color: i < stars ? AppColors.star : AppColors.starEmpty,
                    )),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _UnitCard extends StatelessWidget {
  final Unit unit;
  final int completed;
  final int total;

  const _UnitCard({required this.unit, required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/course'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(unit.icon, style: const TextStyle(fontSize: 24)),
            const Spacer(),
            Text(unit.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: total > 0 ? completed / total : 0,
                backgroundColor: AppColors.cream,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 2),
            Text('$completed/$total bài', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
