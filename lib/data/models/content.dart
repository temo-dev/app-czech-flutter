enum CefrLevel { a1, a2, b1 }

extension CefrLevelExt on CefrLevel {
  String get display {
    switch (this) {
      case CefrLevel.a1: return 'A1';
      case CefrLevel.a2: return 'A2';
      case CefrLevel.b1: return 'B1';
    }
  }

  static CefrLevel fromString(String s) {
    switch (s.toUpperCase()) {
      case 'A2': return CefrLevel.a2;
      case 'B1': return CefrLevel.b1;
      default:   return CefrLevel.a1;
    }
  }
}

enum SkillType { vocabulary, grammar, listening, speaking, reading, writing }

extension SkillTypeExt on SkillType {
  String get label {
    switch (this) {
      case SkillType.vocabulary: return 'Từ Vựng';
      case SkillType.grammar:    return 'Ngữ Pháp';
      case SkillType.listening:  return 'Nghe';
      case SkillType.speaking:   return 'Nói';
      case SkillType.reading:    return 'Đọc';
      case SkillType.writing:    return 'Viết';
    }
  }

  static SkillType fromString(String s) {
    switch (s) {
      case 'vocabulary': return SkillType.vocabulary;
      case 'grammar':    return SkillType.grammar;
      case 'speaking':   return SkillType.speaking;
      case 'reading':    return SkillType.reading;
      case 'writing':    return SkillType.writing;
      default:           return SkillType.listening;
    }
  }
}

class ExerciseDef {
  final String type;
  final List<String> vocabIds;
  final Map<String, dynamic>? data;

  const ExerciseDef({required this.type, required this.vocabIds, this.data});

  factory ExerciseDef.fromJson(Map<String, dynamic> json) => ExerciseDef(
        type: json['type'] as String,
        vocabIds: (json['vocabIds'] as List<dynamic>?)?.cast<String>() ?? [],
        data: json['data'] as Map<String, dynamic>?,
      );
}

class Lesson {
  final String id;
  final String title;
  final String? subtitle;
  final int xpReward;
  final SkillType skill;
  final List<ExerciseDef> exercises;

  const Lesson({
    required this.id,
    required this.title,
    this.subtitle,
    required this.xpReward,
    required this.skill,
    required this.exercises,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
        id: json['id'] as String,
        title: json['title'] as String,
        subtitle: json['subtitle'] as String?,
        xpReward: (json['xpReward'] as num).toInt(),
        skill: SkillTypeExt.fromString(json['skill'] as String? ?? 'reading'),
        exercises: (json['exercises'] as List<dynamic>)
            .map((e) => ExerciseDef.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class Topic {
  final String id;
  final String title;
  final String icon;
  final List<Lesson> lessons;

  const Topic({
    required this.id,
    required this.title,
    required this.icon,
    required this.lessons,
  });

  factory Topic.fromJson(Map<String, dynamic> json) => Topic(
        id: json['id'] as String,
        title: json['title'] as String,
        icon: json['icon'] as String,
        lessons: (json['lessons'] as List<dynamic>)
            .map((e) => Lesson.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class Level {
  final String id;
  final String name;
  final String title;
  final List<Topic> topics;

  const Level({
    required this.id,
    required this.name,
    required this.title,
    required this.topics,
  });

  factory Level.fromJson(Map<String, dynamic> json) => Level(
        id: json['id'] as String,
        name: json['name'] as String,
        title: json['title'] as String,
        topics: (json['topics'] as List<dynamic>)
            .map((e) => Topic.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class Course {
  final String id;
  final String title;
  final List<Level> levels;

  const Course({
    required this.id,
    required this.title,
    required this.levels,
  });

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        id: json['id'] as String,
        title: json['title'] as String,
        levels: (json['levels'] as List<dynamic>)
            .map((e) => Level.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
