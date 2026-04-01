import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/repositories/curriculum_repository.dart';
import 'progress_state.dart';

const _kProgressBox = 'progress-store';
const _kProgressKey = 'state';

class ProgressNotifier extends StateNotifier<ProgressState> {
  final CurriculumRepository _repo;

  ProgressNotifier(this._repo) : super(const ProgressState()) {
    _load();
  }

  void _load() {
    final box = Hive.box(_kProgressBox);
    final raw = box.get(_kProgressKey);
    if (raw != null) {
      state = ProgressState.fromJson(jsonDecode(raw as String) as Map<String, dynamic>);
    }
  }

  void _save() {
    final box = Hive.box(_kProgressBox);
    box.put(_kProgressKey, jsonEncode(state.toJson()));
  }

  void completeLesson(String lessonId, int stars) {
    final ids = state.completedLessonIds;
    final newIds = ids.contains(lessonId) ? ids : [...ids, lessonId];
    final newStars = Map<String, int>.from(state.lessonStars);
    newStars[lessonId] = stars > (newStars[lessonId] ?? 0) ? stars : (newStars[lessonId] ?? stars);

    state = state.copyWith(
      completedLessonIds: newIds,
      lessonStars: newStars,
      lastLessonId: lessonId,
    );
    _save();
  }

  bool isLessonComplete(String lessonId) =>
      state.completedLessonIds.contains(lessonId);

  /// Unlock logic: Level > Topic > Lesson
  /// - Bài đầu tiên của topic đầu tiên của level đầu tiên: luôn mở
  /// - Bài tiếp theo trong topic: mở khi bài trước xong
  /// - Topic tiếp theo: mở khi tất cả bài của topic trước xong
  /// - Level tiếp theo: mở khi tất cả topic của level trước xong
  bool isLessonUnlocked(String lessonId) {
    final completed = state.completedLessonIds;
    final levels = _repo.course.levels;

    for (int li = 0; li < levels.length; li++) {
      final level = levels[li];
      for (int ti = 0; ti < level.topics.length; ti++) {
        final topic = level.topics[ti];
        final idx = topic.lessons.indexWhere((l) => l.id == lessonId);
        if (idx == -1) continue;

        // Bài đầu tiên của topic đầu tiên của level đầu tiên
        if (li == 0 && ti == 0 && idx == 0) return true;

        // Bài tiếp theo trong cùng topic
        if (idx > 0) {
          return completed.contains(topic.lessons[idx - 1].id);
        }

        // Bài đầu tiên của topic (idx == 0): cần topic trước xong
        if (ti > 0) {
          final prevTopic = level.topics[ti - 1];
          return prevTopic.lessons.every((l) => completed.contains(l.id));
        }

        // Bài đầu tiên của topic đầu tiên của level (ti == 0, idx == 0):
        // cần level trước xong
        if (li > 0) {
          final prevLevel = levels[li - 1];
          return prevLevel.topics.every(
            (t) => t.lessons.every((l) => completed.contains(l.id)),
          );
        }
      }
    }
    return false;
  }

  ({int completed, int total}) getTopicProgress(String topicId) {
    for (final level in _repo.course.levels) {
      for (final topic in level.topics) {
        if (topic.id == topicId) {
          return (
            completed: topic.lessons.where((l) => state.completedLessonIds.contains(l.id)).length,
            total: topic.lessons.length,
          );
        }
      }
    }
    return (completed: 0, total: 0);
  }

  ({int completed, int total}) getLevelProgress(String levelId) {
    for (final level in _repo.course.levels) {
      if (level.id == levelId) {
        int completed = 0;
        int total = 0;
        for (final topic in level.topics) {
          total += topic.lessons.length;
          completed += topic.lessons.where((l) => state.completedLessonIds.contains(l.id)).length;
        }
        return (completed: completed, total: total);
      }
    }
    return (completed: 0, total: 0);
  }
}

final progressProvider = StateNotifierProvider<ProgressNotifier, ProgressState>(
  (ref) => ProgressNotifier(ref.read(curriculumRepositoryProvider)),
);

final curriculumRepositoryProvider = Provider<CurriculumRepository>(
  (ref) => throw UnimplementedError('Override in ProviderScope'),
);
