class ProgressState {
  final List<String> completedLessonIds;
  final Map<String, int> lessonStars;
  final String? lastLessonId;

  const ProgressState({
    this.completedLessonIds = const [],
    this.lessonStars = const {},
    this.lastLessonId,
  });

  ProgressState copyWith({
    List<String>? completedLessonIds,
    Map<String, int>? lessonStars,
    String? lastLessonId,
    bool clearLastLesson = false,
  }) {
    return ProgressState(
      completedLessonIds: completedLessonIds ?? this.completedLessonIds,
      lessonStars: lessonStars ?? this.lessonStars,
      lastLessonId: clearLastLesson ? null : (lastLessonId ?? this.lastLessonId),
    );
  }

  Map<String, dynamic> toJson() => {
        'completedLessonIds': completedLessonIds,
        'lessonStars': lessonStars,
        'lastLessonId': lastLessonId,
      };

  factory ProgressState.fromJson(Map<String, dynamic> json) => ProgressState(
        completedLessonIds:
            (json['completedLessonIds'] as List<dynamic>?)?.cast<String>() ?? [],
        lessonStars: (json['lessonStars'] as Map<String, dynamic>?)
                ?.map((k, v) => MapEntry(k, (v as num).toInt())) ??
            {},
        lastLessonId: json['lastLessonId'] as String?,
      );
}
