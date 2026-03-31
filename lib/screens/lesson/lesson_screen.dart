import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/exercise.dart';
import '../../engine/lesson_runner.dart';
import '../../state/progress/progress_notifier.dart';
import '../../state/review/review_notifier.dart';
import '../../state/user/user_notifier.dart';
import 'widgets/lesson_header.dart';
import 'widgets/feedback_overlay.dart';
import 'widgets/lesson_complete.dart';
import '../../widgets/exercises/flash_card_exercise.dart';
import '../../widgets/exercises/multiple_choice_exercise.dart';
import '../../widgets/exercises/matching_pairs_exercise.dart';
import '../../widgets/exercises/fill_in_blank_exercise.dart';
import '../../widgets/exercises/listening_exercise.dart';
import '../../widgets/exercises/speaking_exercise.dart';
import '../../widgets/exercises/grammar_exercise.dart';
import '../../widgets/exercises/reading_exercise.dart';
import '../../widgets/exercises/writing_exercise.dart';
import '../../widgets/exercises/video_exercise.dart';

const _maxHearts = 3;

class LessonScreen extends ConsumerStatefulWidget {
  final String lessonId;
  const LessonScreen({super.key, required this.lessonId});

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  late List<Exercise> _exercises;
  int _index = 0;
  int _hearts = _maxHearts;
  int _correct = 0;
  String _phase = 'exercise'; // exercise | feedback | complete
  bool? _lastCorrect;

  @override
  void initState() {
    super.initState();
    final repo = ref.read(curriculumRepositoryProvider);
    final lesson = repo.findLesson(widget.lessonId);
    if (lesson != null) {
      _exercises = buildExercises(lesson, repo.vocabulary, repo.vocabMap);
    } else {
      _exercises = [];
    }
  }

  double get _progress => _exercises.isEmpty ? 0 : _index / _exercises.length;
  int get _total => _exercises.length;
  int get _stars => _hearts == 3 ? 3 : _hearts == 2 ? 2 : 1;

  void _submitAnswer(bool isCorrect) {
    final ex = _exercises[_index];
    final reviewNotifier = ref.read(reviewProvider.notifier);

    // Add vocab to SRS
    if (ex is FlashCardExercise) reviewNotifier.addVocabToReview(ex.vocabId);
    if (ex is MultipleChoiceExercise) reviewNotifier.addVocabToReview(ex.vocabId);
    if (ex is ListeningExercise) reviewNotifier.addVocabToReview(ex.vocabId);
    if (ex is SpeakingExercise) reviewNotifier.addVocabToReview(ex.vocabId);
    if (ex is MatchingExercise) {
      for (final p in ex.pairs) reviewNotifier.addVocabToReview(p.id);
    }

    if (!isCorrect) setState(() => _hearts = (_hearts - 1).clamp(0, _maxHearts));
    if (isCorrect) setState(() => _correct++);

    setState(() {
      _lastCorrect = isCorrect;
      _phase = 'feedback';
    });
  }

  void _advance() {
    if (_index + 1 >= _exercises.length) {
      setState(() => _phase = 'complete');
    } else {
      setState(() {
        _index++;
        _phase = 'exercise';
        _lastCorrect = null;
      });
    }
  }

  void _onComplete() {
    final repo = ref.read(curriculumRepositoryProvider);
    final lesson = repo.findLesson(widget.lessonId);
    if (lesson != null) {
      ref.read(progressProvider.notifier).completeLesson(widget.lessonId, _stars);
      ref.read(userProvider.notifier).addXP(lesson.xpReward);
    }
    context.go('/course');
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(curriculumRepositoryProvider);
    final lesson = repo.findLesson(widget.lessonId);

    if (lesson == null) {
      return Scaffold(
        body: Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Không tìm thấy bài học'),
            TextButton(onPressed: () => context.go('/course'), child: const Text('Quay lại')),
          ],
        )),
      );
    }

    if (_phase == 'complete') {
      return LessonCompleteScreen(
        lessonTitle: lesson.title,
        xpEarned: lesson.xpReward,
        correct: _correct,
        total: _total,
        stars: _stars,
        onContinue: _onComplete,
      );
    }

    final exercise = _exercises.isEmpty ? null : _exercises[_index];

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            children: [
              LessonHeader(
                progress: _progress,
                hearts: _hearts,
                maxHearts: _maxHearts,
                onExit: () => _showExitDialog(context),
              ),
              Expanded(
                child: exercise == null
                    ? const Center(child: CircularProgressIndicator())
                    : AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween<Offset>(begin: const Offset(0.1, 0), end: Offset.zero).animate(anim),
                            child: child,
                          ),
                        ),
                        child: _buildExercise(exercise),
                      ),
              ),
              if (_phase == 'feedback' && _lastCorrect != null)
                FeedbackOverlay(
                  correct: _lastCorrect!,
                  onNext: _advance,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExercise(Exercise exercise) {
    return switch (exercise) {
      FlashCardExercise e => FlashCardExerciseWidget(key: ValueKey(_index), exercise: e, onAnswer: _submitAnswer),
      MultipleChoiceExercise e => MultipleChoiceWidget(key: ValueKey(_index), exercise: e, onAnswer: _submitAnswer),
      FillBlankExercise e => FillInBlankWidget(key: ValueKey(_index), exercise: e, onAnswer: _submitAnswer),
      MatchingExercise e => MatchingPairsWidget(key: ValueKey(_index), exercise: e, onAnswer: _submitAnswer),
      ListeningExercise e => ListeningWidget(key: ValueKey(_index), exercise: e, onAnswer: _submitAnswer),
      SpeakingExercise e => SpeakingWidget(key: ValueKey(_index), exercise: e, onAnswer: _submitAnswer),
      GrammarExercise e => GrammarWidget(key: ValueKey(_index), exercise: e, onAnswer: _submitAnswer),
      ReadingExercise e => ReadingWidget(key: ValueKey(_index), exercise: e, onAnswer: _submitAnswer),
      WritingExercise e => WritingWidget(key: ValueKey(_index), exercise: e, onAnswer: _submitAnswer),
      VideoExercise e => VideoWidget(key: ValueKey(_index), exercise: e, onAnswer: _submitAnswer),
    };
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Thoát bài học?'),
        content: const Text('Tiến độ sẽ không được lưu.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tiếp tục học')),
          TextButton(
            onPressed: () { Navigator.pop(context); context.go('/course'); },
            child: const Text('Thoát', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
