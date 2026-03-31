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

  bool isLessonUnlocked(String lessonId) {
    final completed = state.completedLessonIds;
    for (final unit in _repo.course.units) {
      final idx = unit.lessons.indexWhere((l) => l.id == lessonId);
      if (idx == -1) continue;

      // First lesson of first unit: always unlocked
      if (idx == 0 && unit.prerequisiteUnitId == null) return true;

      // First lesson of subsequent unit: require previous unit complete
      if (idx == 0 && unit.prerequisiteUnitId != null) {
        final prevUnit = _repo.course.units
            .where((u) => u.id == unit.prerequisiteUnitId)
            .firstOrNull;
        if (prevUnit == null) return false;
        return prevUnit.lessons.every((l) => completed.contains(l.id));
      }

      // Other lessons: require previous lesson complete
      return completed.contains(unit.lessons[idx - 1].id);
    }
    return false;
  }

  ({int completed, int total}) getUnitProgress(String unitId) {
    final unit = _repo.course.units.where((u) => u.id == unitId).firstOrNull;
    if (unit == null) return (completed: 0, total: 0);
    return (
      completed: unit.lessons.where((l) => state.completedLessonIds.contains(l.id)).length,
      total: unit.lessons.length,
    );
  }
}

final progressProvider = StateNotifierProvider<ProgressNotifier, ProgressState>(
  (ref) => ProgressNotifier(ref.read(curriculumRepositoryProvider)),
);

final curriculumRepositoryProvider = Provider<CurriculumRepository>(
  (ref) => throw UnimplementedError('Override in ProviderScope'),
);
