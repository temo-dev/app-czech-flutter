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

    // Supabase chưa có schema Level/Topic mới → fallback sang assets
    await _loadCurriculumFromAssets();
  }

  Future<void> _loadFromAssets() async {
    await _loadCurriculumFromAssets();

    final vocabRaw = await rootBundle.loadString('assets/data/vocabulary.json');
    final vocabList = (jsonDecode(vocabRaw) as List<dynamic>)
        .map((e) => VocabItem.fromJson(e as Map<String, dynamic>))
        .toList();
    _vocabulary = vocabList;
    _vocabMap = {for (final v in vocabList) v.id: v};
  }

  Future<void> _loadCurriculumFromAssets() async {
    final courseRaw = await rootBundle.loadString('assets/data/curriculum.json');
    _course = Course.fromJson(jsonDecode(courseRaw) as Map<String, dynamic>);
  }

  Course get course => _course;
  List<VocabItem> get vocabulary => _vocabulary;
  Map<String, VocabItem> get vocabMap => _vocabMap;

  VocabItem? getVocab(String id) => _vocabMap[id];

  /// Tìm bài học theo id trong cấu trúc Level > Topic > Lesson
  Lesson? findLesson(String lessonId) {
    for (final level in _course.levels) {
      for (final topic in level.topics) {
        for (final lesson in topic.lessons) {
          if (lesson.id == lessonId) return lesson;
        }
      }
    }
    return null;
  }

  /// Tìm topic chứa bài học
  Topic? findTopicForLesson(String lessonId) {
    for (final level in _course.levels) {
      for (final topic in level.topics) {
        if (topic.lessons.any((l) => l.id == lessonId)) return topic;
      }
    }
    return null;
  }

  /// Tìm level chứa bài học
  Level? findLevelForLesson(String lessonId) {
    for (final level in _course.levels) {
      for (final topic in level.topics) {
        if (topic.lessons.any((l) => l.id == lessonId)) return level;
      }
    }
    return null;
  }

  /// Danh sách tất cả lessons theo thứ tự
  List<Lesson> get allLessons => [
        for (final level in _course.levels)
          for (final topic in level.topics)
            ...topic.lessons,
      ];
}
