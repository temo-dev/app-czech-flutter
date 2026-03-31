import 'dart:math';
import '../data/models/content.dart';
import '../data/models/exercise.dart';
import '../data/models/vocab_item.dart';

final _random = Random();

List<T> _shuffle<T>(List<T> list) {
  final result = List<T>.from(list);
  for (int i = result.length - 1; i > 0; i--) {
    final j = _random.nextInt(i + 1);
    final tmp = result[i];
    result[i] = result[j];
    result[j] = tmp;
  }
  return result;
}

List<String> _getDistractors(
  String correctId,
  int count,
  List<VocabItem> vocabulary, {
  List<String>? fromIds,
}) {
  final pool = (fromIds ?? vocabulary.map((v) => v.id).toList())
      .where((id) => id != correctId)
      .toList();
  return _shuffle(pool).take(count).toList();
}

List<Exercise> buildExercises(
  Lesson lesson,
  List<VocabItem> vocabulary,
  Map<String, VocabItem> vocabMap,
) {
  final exercises = <Exercise>[];

  for (final def in lesson.exercises) {
    final ids = def.vocabIds;

    if (def.type == 'flashcard') {
      for (final id in ids) {
        exercises.add(FlashCardExercise(vocabId: id));
      }
    }

    if (def.type == 'multipleChoice') {
      for (final id in ids) {
        final item = vocabMap[id];
        if (item == null) continue;
        final distractorIds = _getDistractors(
          id,
          3,
          vocabulary,
          fromIds: ids.length >= 4 ? ids : null,
        );
        final options = _shuffle([
          ExerciseOption(id: id, text: item.vietnamese),
          ...distractorIds.map((did) {
            final d = vocabMap[did];
            return ExerciseOption(id: did, text: d?.vietnamese ?? did);
          }),
        ]);
        exercises.add(MultipleChoiceExercise(
          question: item.czech,
          questionLang: 'czech',
          vocabId: id,
          options: options,
          correctId: id,
        ));
      }
    }

    if (def.type == 'matching') {
      // Group up to 5 pairs per exercise
      for (int i = 0; i < ids.length; i += 5) {
        final chunk = ids.sublist(i, min(i + 5, ids.length));
        final pairs = chunk
            .map((id) {
              final v = vocabMap[id];
              if (v == null) return null;
              return MatchingPair(id: id, czech: v.czech, vietnamese: v.vietnamese);
            })
            .whereType<MatchingPair>()
            .toList();
        if (pairs.length >= 2) {
          exercises.add(MatchingExercise(pairs: pairs));
        }
      }
    }

    if (def.type == 'listening') {
      for (final id in ids) {
        final item = vocabMap[id];
        if (item == null) continue;
        final distractorIds = _getDistractors(id, 3, vocabulary, fromIds: ids);
        final options = _shuffle([
          ExerciseOption(id: id, text: item.vietnamese),
          ...distractorIds.map((did) {
            final d = vocabMap[did];
            return ExerciseOption(id: did, text: d?.vietnamese ?? did);
          }),
        ]);
        exercises.add(ListeningExercise(vocabId: id, options: options, correctId: id));
      }
    }

    if (def.type == 'speaking') {
      for (final id in ids) {
        final item = vocabMap[id];
        if (item == null) continue;
        exercises.add(SpeakingExercise(
          vocabId: id,
          prompt: item.vietnamese,
          answer: item.czech,
          pronunciation: item.pronunciation,
        ));
      }
    }

    if (def.type == 'grammar' && def.data != null) {
      final d = def.data!;
      exercises.add(GrammarExercise(
        ruleTitle: d['ruleTitle'] as String? ?? '',
        ruleVi: d['ruleVi'] as String? ?? '',
        example: Map<String, String>.from(d['example'] as Map? ?? {}),
        question: d['question'] as String? ?? '',
        options: ((d['options'] as List?) ?? [])
            .map((e) => ExerciseOption.fromJson(e as Map<String, dynamic>))
            .toList(),
        correctId: d['correctId'] as String? ?? '',
        explanation: d['explanation'] as String? ?? '',
      ));
    }

    if (def.type == 'reading' && def.data != null) {
      final d = def.data!;
      exercises.add(ReadingExercise(
        passageCs: d['passageCs'] as String? ?? '',
        passageVi: d['passageVi'] as String? ?? '',
        questions: ((d['questions'] as List?) ?? [])
            .map((e) => ReadingQuestion.fromJson(e as Map<String, dynamic>))
            .toList(),
      ));
    }

    if (def.type == 'writing' && def.data != null) {
      final d = def.data!;
      exercises.add(WritingExercise(
        promptVi: d['promptVi'] as String? ?? '',
        answer: d['answer'] as String? ?? '',
        hint: d['hint'] as String?,
      ));
    }

    if (def.type == 'video' && def.data != null) {
      final d = def.data!;
      exercises.add(VideoExercise(
        youtubeId: d['youtubeId'] as String? ?? '',
        title: d['title'] as String? ?? '',
        level: d['level'] as String? ?? '',
        question: d['question'] as String? ?? '',
        options: ((d['options'] as List?) ?? [])
            .map((e) => ExerciseOption.fromJson(e as Map<String, dynamic>))
            .toList(),
        correctId: d['correctId'] as String? ?? '',
      ));
    }

    if (def.type == 'fillBlank') {
      for (final id in ids) {
        final item = vocabMap[id];
        if (item == null) continue;
        final distractorIds = _getDistractors(id, 3, vocabulary, fromIds: ids);
        final wordBank = _shuffle([
          item.czech,
          ...distractorIds.map((d) => vocabMap[d]?.czech ?? d),
        ]);
        exercises.add(FillBlankExercise(
          sentenceVi: '"${item.vietnamese}" trong tiếng Séc là:',
          sentenceCs: item.czech,
          answer: item.czech,
          wordBank: wordBank,
        ));
      }
    }
  }

  return exercises;
}
