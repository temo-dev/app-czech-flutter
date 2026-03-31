import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/content.dart';
import '../../state/progress/progress_notifier.dart';

class CourseMapScreen extends ConsumerWidget {
  const CourseMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(curriculumRepositoryProvider);
    final progress = ref.watch(progressProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.white,
            title: const Text('Khóa học'),
            pinned: true,
            elevation: 0,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: AppColors.border),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final unit = repo.course.units[i];
                  final prog = ref.read(progressProvider.notifier).getUnitProgress(unit.id);
                  return _UnitSection(
                    unit: unit,
                    completed: prog.completed,
                    total: prog.total,
                    completedIds: progress.completedLessonIds,
                    lessonStars: progress.lessonStars,
                    isUnlocked: (id) => ref.read(progressProvider.notifier).isLessonUnlocked(id),
                    onTapLesson: (id) => context.push('/lesson/$id'),
                  ).animate().fadeIn(delay: (i * 80).ms).slideY(begin: 0.2);
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

class _UnitSection extends StatefulWidget {
  final Unit unit;
  final int completed;
  final int total;
  final List<String> completedIds;
  final Map<String, int> lessonStars;
  final bool Function(String) isUnlocked;
  final ValueChanged<String> onTapLesson;

  const _UnitSection({
    required this.unit,
    required this.completed,
    required this.total,
    required this.completedIds,
    required this.lessonStars,
    required this.isUnlocked,
    required this.onTapLesson,
  });

  @override
  State<_UnitSection> createState() => _UnitSectionState();
}

class _UnitSectionState extends State<_UnitSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Unit header
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.cream,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(child: Text(widget.unit.icon, style: const TextStyle(fontSize: 24))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.unit.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                        const SizedBox(height: 2),
                        Text(widget.unit.subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: widget.total > 0 ? widget.completed / widget.total : 0,
                                  backgroundColor: AppColors.cream,
                                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                                  minHeight: 4,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('${widget.completed}/${widget.total}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: AppColors.textMuted),
                ],
              ),
            ),
          ),
          // Lessons list
          if (_expanded) ...[
            const Divider(height: 1, color: AppColors.border),
            ...widget.unit.lessons.map((lesson) {
              final unlocked = widget.isUnlocked(lesson.id);
              final done = widget.completedIds.contains(lesson.id);
              final stars = widget.lessonStars[lesson.id] ?? 0;

              return _LessonRow(
                lesson: lesson,
                unlocked: unlocked,
                done: done,
                stars: stars,
                onTap: unlocked ? () => widget.onTapLesson(lesson.id) : null,
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _LessonRow extends StatelessWidget {
  final Lesson lesson;
  final bool unlocked;
  final bool done;
  final int stars;
  final VoidCallback? onTap;

  const _LessonRow({
    required this.lesson,
    required this.unlocked,
    required this.done,
    required this.stars,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: done
                    ? AppColors.successLight
                    : unlocked
                        ? AppColors.cream
                        : AppColors.border,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                done ? Icons.check_circle : unlocked ? Icons.play_circle_outline : Icons.lock_outline,
                size: 20,
                color: done ? AppColors.success : unlocked ? AppColors.primary : AppColors.textMuted,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: unlocked ? AppColors.textDark : AppColors.textMuted,
                    ),
                  ),
                  if (lesson.subtitle != null)
                    Text(lesson.subtitle!, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${lesson.xpReward} XP', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                if (done && stars > 0)
                  Row(
                    children: List.generate(3, (i) => Icon(
                      Icons.star,
                      size: 12,
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
