import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/content.dart';
import '../../state/progress/progress_notifier.dart';

const _skillColors = {
  SkillType.vocabulary: Color(0xFFDC2626),
  SkillType.grammar:    Color(0xFF0891B2),
  SkillType.listening:  Color(0xFF0284C7),
  SkillType.speaking:   Color(0xFF7C3AED),
  SkillType.reading:    Color(0xFF059669),
  SkillType.writing:    Color(0xFFD97706),
};

const _skillBgColors = {
  SkillType.vocabulary: Color(0xFFFEE2E2),
  SkillType.grammar:    Color(0xFFCFFAFE),
  SkillType.listening:  Color(0xFFE0F2FE),
  SkillType.speaking:   Color(0xFFEDE9FE),
  SkillType.reading:    Color(0xFFD1FAE5),
  SkillType.writing:    Color(0xFFFEF3C7),
};

class CourseMapScreen extends ConsumerStatefulWidget {
  const CourseMapScreen({super.key});

  @override
  ConsumerState<CourseMapScreen> createState() => _CourseMapScreenState();
}

class _CourseMapScreenState extends ConsumerState<CourseMapScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final repo = ref.read(curriculumRepositoryProvider);
    _tabController = TabController(
      length: repo.course.levels.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(curriculumRepositoryProvider);
    final levels = repo.course.levels;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            backgroundColor: AppColors.white,
            title: const Text('Khóa học'),
            pinned: true,
            elevation: 0,
            forceElevated: innerBoxIsScrolled,
            bottom: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textMuted,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              tabs: levels.map((l) => Tab(text: l.name)).toList(),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: levels.map((level) => _LevelTab(level: level)).toList(),
        ),
      ),
    );
  }
}

class _LevelTab extends ConsumerWidget {
  final Level level;

  const _LevelTab({required this.level});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final notifier = ref.read(progressProvider.notifier);
    final levelProg = notifier.getLevelProgress(level.id);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
      children: [
        // Level header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${level.name} — ${level.title}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${levelProg.completed}/${levelProg.total} bài hoàn thành',
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: levelProg.total > 0 ? levelProg.completed / levelProg.total : 0,
                        backgroundColor: AppColors.cream,
                        valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(),
        const SizedBox(height: 16),

        // Topics
        ...level.topics.asMap().entries.map((entry) {
          final i = entry.key;
          final topic = entry.value;
          final topicProg = notifier.getTopicProgress(topic.id);
          return _TopicCard(
            topic: topic,
            completed: topicProg.completed,
            total: topicProg.total,
            completedIds: progress.completedLessonIds,
            lessonStars: progress.lessonStars,
            isUnlocked: notifier.isLessonUnlocked,
            onTapLesson: (id) => context.push('/lesson/$id'),
          ).animate().fadeIn(delay: (i * 80).ms).slideY(begin: 0.2);
        }),
      ],
    );
  }
}

class _TopicCard extends StatefulWidget {
  final Topic topic;
  final int completed;
  final int total;
  final List<String> completedIds;
  final Map<String, int> lessonStars;
  final bool Function(String) isUnlocked;
  final ValueChanged<String> onTapLesson;

  const _TopicCard({
    required this.topic,
    required this.completed,
    required this.total,
    required this.completedIds,
    required this.lessonStars,
    required this.isUnlocked,
    required this.onTapLesson,
  });

  @override
  State<_TopicCard> createState() => _TopicCardState();
}

class _TopicCardState extends State<_TopicCard> {
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
          // Topic header
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
                    child: Center(child: Text(widget.topic.icon, style: const TextStyle(fontSize: 24))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.topic.title,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
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
                            Text('${widget.completed}/${widget.total}',
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
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

          // 4 kỹ năng
          if (_expanded) ...[
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.all(12),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final tileWidth = (constraints.maxWidth - 12) / 3;
                  return Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: widget.topic.lessons.map((lesson) {
                      final unlocked = widget.isUnlocked(lesson.id);
                      final done = widget.completedIds.contains(lesson.id);
                      final stars = widget.lessonStars[lesson.id] ?? 0;
                      return SizedBox(
                        width: tileWidth,
                        child: _SkillTile(
                          lesson: lesson,
                          unlocked: unlocked,
                          done: done,
                          stars: stars,
                          onTap: unlocked ? () => widget.onTapLesson(lesson.id) : null,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SkillTile extends StatelessWidget {
  final Lesson lesson;
  final bool unlocked;
  final bool done;
  final int stars;
  final VoidCallback? onTap;

  const _SkillTile({
    required this.lesson,
    required this.unlocked,
    required this.done,
    required this.stars,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = unlocked
        ? (_skillColors[lesson.skill] ?? AppColors.primary)
        : AppColors.textLight;
    final bgColor = unlocked
        ? (_skillBgColors[lesson.skill] ?? AppColors.cream)
        : AppColors.cream.withOpacity(0.5);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: done ? bgColor : (unlocked ? bgColor.withOpacity(0.6) : AppColors.cream.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: done ? color : (unlocked ? color.withOpacity(0.4) : AppColors.border),
            width: done ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              done
                  ? Icons.check_circle
                  : unlocked
                      ? _skillIcon(lesson.skill)
                      : Icons.lock_outline,
              size: 20,
              color: done ? color : unlocked ? color : AppColors.textLight,
            ),
            const SizedBox(height: 4),
            Text(
              lesson.skill.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: unlocked ? color : AppColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),
            if (done && stars > 0) ...[
              const SizedBox(height: 3),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) => Icon(
                  Icons.star,
                  size: 8,
                  color: i < stars ? AppColors.star : AppColors.starEmpty,
                )),
              ),
            ],
            Text(
              '${lesson.xpReward} XP',
              style: TextStyle(fontSize: 9, color: unlocked ? color.withOpacity(0.7) : AppColors.textLight),
            ),
          ],
        ),
      ),
    );
  }

  IconData _skillIcon(SkillType skill) {
    switch (skill) {
      case SkillType.vocabulary: return Icons.style_outlined;
      case SkillType.grammar:    return Icons.account_tree_outlined;
      case SkillType.listening:  return Icons.headphones_outlined;
      case SkillType.speaking:   return Icons.mic_outlined;
      case SkillType.reading:    return Icons.menu_book_outlined;
      case SkillType.writing:    return Icons.edit_outlined;
    }
  }
}
