import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/content.dart';
import '../models/vocab_item.dart';

class CurriculumRepository {
  late Course _course;
  late Map<String, VocabItem> _vocabMap;
  late List<VocabItem> _vocabulary;

  /// Thử tải từ Supabase trước, nếu lỗi thì fallback sang local JSON
  Future<void> init() async {
    try {
      await _loadFromSupabase();
    } catch (_) {
      await _loadFromAssets();
    }
  }

  Future<void> _loadFromSupabase() async {
    final client = Supabase.instance.client;

    // Vocabulary
    final vocabRows = await client.from('vocabulary').select();
    final vocabList = (vocabRows as List<dynamic>)
        .map((r) => VocabItem.fromSupabase(r as Map<String, dynamic>))
        .toList();
    _vocabulary = vocabList;
    _vocabMap = {for (final v in vocabList) v.id: v};

    // Course
    final courseRow = ((await client.from('courses').select().limit(1))
        as List<dynamic>)
        .first as Map<String, dynamic>;

    // Lessons (tất cả, nhóm theo unit_id)
    final lessonRows = await client
        .from('lessons')
        .select()
        .order('sort_order', ascending: true);
    final lessonsByUnit = <String, List<Map<String, dynamic>>>{};
    for (final l in lessonRows as List<dynamic>) {
      final lesson = l as Map<String, dynamic>;
      lessonsByUnit
          .putIfAbsent(lesson['unit_id'] as String, () => [])
          .add(lesson);
    }

    // Units
    final unitRows = await client
        .from('units')
        .select()
        .eq('course_id', courseRow['id'] as String)
        .order('sort_order', ascending: true);
    final units = (unitRows as List<dynamic>).map((u) {
      final r = u as Map<String, dynamic>;
      final lessons = (lessonsByUnit[r['id']] ?? []).map((l) {
        return Lesson(
          id: l['id'] as String,
          title: l['title'] as String,
          subtitle: l['subtitle'] as String?,
          xpReward: (l['xp_reward'] as num).toInt(),
          exercises: (l['exercises'] as List<dynamic>)
              .map((e) => ExerciseDef.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
      }).toList();
      return Unit(
        id: r['id'] as String,
        title: r['title'] as String,
        subtitle: r['subtitle'] as String,
        color: r['color'] as String,
        darkColor: r['dark_color'] as String,
        icon: r['icon'] as String,
        lessons: lessons,
        prerequisiteUnitId: r['prerequisite_unit_id'] as String?,
      );
    }).toList();

    _course = Course(
      id: courseRow['id'] as String,
      title: courseRow['title'] as String,
      level: courseRow['level'] as String,
      units: units,
    );
  }

  Future<void> _loadFromAssets() async {
    final courseRaw = await rootBundle.loadString('assets/data/curriculum.json');
    _course = Course.fromJson(jsonDecode(courseRaw) as Map<String, dynamic>);

    final vocabRaw = await rootBundle.loadString('assets/data/vocabulary.json');
    final vocabList = (jsonDecode(vocabRaw) as List<dynamic>)
        .map((e) => VocabItem.fromJson(e as Map<String, dynamic>))
        .toList();
    _vocabulary = vocabList;
    _vocabMap = {for (final v in vocabList) v.id: v};
  }

  Course get course => _course;
  List<VocabItem> get vocabulary => _vocabulary;
  Map<String, VocabItem> get vocabMap => _vocabMap;

  VocabItem? getVocab(String id) => _vocabMap[id];

  Lesson? findLesson(String lessonId) {
    for (final unit in _course.units) {
      for (final lesson in unit.lessons) {
        if (lesson.id == lessonId) return lesson;
      }
    }
    return null;
  }

  Unit? findUnitForLesson(String lessonId) {
    for (final unit in _course.units) {
      if (unit.lessons.any((l) => l.id == lessonId)) return unit;
    }
    return null;
  }
}
