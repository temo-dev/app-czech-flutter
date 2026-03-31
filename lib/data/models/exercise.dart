class ExerciseOption {
  final String id;
  final String text;

  const ExerciseOption({required this.id, required this.text});

  factory ExerciseOption.fromJson(Map<String, dynamic> json) =>
      ExerciseOption(id: json['id'] as String, text: json['text'] as String);
}

class MatchingPair {
  final String id;
  final String czech;
  final String vietnamese;

  const MatchingPair({required this.id, required this.czech, required this.vietnamese});

  factory MatchingPair.fromJson(Map<String, dynamic> json) => MatchingPair(
        id: json['id'] as String,
        czech: json['czech'] as String,
        vietnamese: json['vietnamese'] as String,
      );
}

class ReadingQuestion {
  final String id;
  final String question;
  final List<ExerciseOption> options;
  final String correctId;

  const ReadingQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctId,
  });

  factory ReadingQuestion.fromJson(Map<String, dynamic> json) => ReadingQuestion(
        id: json['id'] as String,
        question: json['question'] as String,
        options: (json['options'] as List).map((e) => ExerciseOption.fromJson(e)).toList(),
        correctId: json['correctId'] as String,
      );
}

sealed class Exercise {}

class FlashCardExercise extends Exercise {
  final String vocabId;
  FlashCardExercise({required this.vocabId});
}

class MultipleChoiceExercise extends Exercise {
  final String question;
  final String questionLang;
  final String vocabId;
  final List<ExerciseOption> options;
  final String correctId;

  MultipleChoiceExercise({
    required this.question,
    required this.questionLang,
    required this.vocabId,
    required this.options,
    required this.correctId,
  });
}

class FillBlankExercise extends Exercise {
  final String sentenceVi;
  final String sentenceCs;
  final String answer;
  final List<String> wordBank;

  FillBlankExercise({
    required this.sentenceVi,
    required this.sentenceCs,
    required this.answer,
    required this.wordBank,
  });
}

class MatchingExercise extends Exercise {
  final List<MatchingPair> pairs;
  MatchingExercise({required this.pairs});
}

class ListeningExercise extends Exercise {
  final String vocabId;
  final List<ExerciseOption> options;
  final String correctId;

  ListeningExercise({
    required this.vocabId,
    required this.options,
    required this.correctId,
  });
}

class SpeakingExercise extends Exercise {
  final String vocabId;
  final String prompt;
  final String answer;
  final String pronunciation;

  SpeakingExercise({
    required this.vocabId,
    required this.prompt,
    required this.answer,
    required this.pronunciation,
  });
}

class GrammarExercise extends Exercise {
  final String ruleTitle;
  final String ruleVi;
  final Map<String, String> example;
  final String question;
  final List<ExerciseOption> options;
  final String correctId;
  final String explanation;

  GrammarExercise({
    required this.ruleTitle,
    required this.ruleVi,
    required this.example,
    required this.question,
    required this.options,
    required this.correctId,
    required this.explanation,
  });
}

class ReadingExercise extends Exercise {
  final String passageCs;
  final String passageVi;
  final List<ReadingQuestion> questions;

  ReadingExercise({
    required this.passageCs,
    required this.passageVi,
    required this.questions,
  });
}

class WritingExercise extends Exercise {
  final String promptVi;
  final String answer;
  final String? hint;

  WritingExercise({required this.promptVi, required this.answer, this.hint});
}

class VideoExercise extends Exercise {
  final String youtubeId;
  final String title;
  final String level;
  final String question;
  final List<ExerciseOption> options;
  final String correctId;

  VideoExercise({
    required this.youtubeId,
    required this.title,
    required this.level,
    required this.question,
    required this.options,
    required this.correctId,
  });
}

class ExerciseResult {
  final int exerciseIndex;
  final bool correct;
  final int timeMs;

  const ExerciseResult({
    required this.exerciseIndex,
    required this.correct,
    required this.timeMs,
  });
}
