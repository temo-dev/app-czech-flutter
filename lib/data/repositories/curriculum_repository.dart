import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/content.dart';
import '../models/vocab_item.dart';

class CurriculumRepository {
  late Course _course;
  late Map<String, VocabItem> _vocabMap;
  late List<VocabItem> _vocabulary;

  Future<void> init() async {
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
