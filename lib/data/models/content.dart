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
      default: return CefrLevel.a1;
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
  final List<ExerciseDef> exercises;

  const Lesson({
    required this.id,
    required this.title,
    this.subtitle,
    required this.xpReward,
    required this.exercises,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
        id: json['id'] as String,
        title: json['title'] as String,
        subtitle: json['subtitle'] as String?,
        xpReward: (json['xpReward'] as num).toInt(),
        exercises: (json['exercises'] as List<dynamic>)
            .map((e) => ExerciseDef.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class Unit {
  final String id;
  final String title;
  final String subtitle;
  final String color;
  final String darkColor;
  final String icon;
  final List<Lesson> lessons;
  final String? prerequisiteUnitId;

  const Unit({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.darkColor,
    required this.icon,
    required this.lessons,
    this.prerequisiteUnitId,
  });

  factory Unit.fromJson(Map<String, dynamic> json) => Unit(
        id: json['id'] as String,
        title: json['title'] as String,
        subtitle: json['subtitle'] as String,
        color: json['color'] as String,
        darkColor: json['darkColor'] as String,
        icon: json['icon'] as String,
        lessons: (json['lessons'] as List<dynamic>)
            .map((e) => Lesson.fromJson(e as Map<String, dynamic>))
            .toList(),
        prerequisiteUnitId: json['prerequisiteUnitId'] as String?,
      );
}

class Course {
  final String id;
  final String title;
  final String level;
  final List<Unit> units;

  const Course({
    required this.id,
    required this.title,
    required this.level,
    required this.units,
  });

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        id: json['id'] as String,
        title: json['title'] as String,
        level: json['level'] as String,
        units: (json['units'] as List<dynamic>)
            .map((e) => Unit.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
