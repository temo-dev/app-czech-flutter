import 'package:hive/hive.dart';

part 'sm2_record.g.dart';

@HiveType(typeId: 0)
class Sm2Record extends HiveObject {
  @HiveField(0)
  String vocabId;

  @HiveField(1)
  double easeFactor;

  @HiveField(2)
  int interval;

  @HiveField(3)
  int repetitions;

  @HiveField(4)
  String nextReviewDate;

  Sm2Record({
    required this.vocabId,
    this.easeFactor = 2.5,
    this.interval = 1,
    this.repetitions = 0,
    required this.nextReviewDate,
  });

  Sm2Record copyWith({
    double? easeFactor,
    int? interval,
    int? repetitions,
    String? nextReviewDate,
  }) {
    return Sm2Record(
      vocabId: vocabId,
      easeFactor: easeFactor ?? this.easeFactor,
      interval: interval ?? this.interval,
      repetitions: repetitions ?? this.repetitions,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
    );
  }

  Map<String, dynamic> toJson() => {
        'vocabId': vocabId,
        'easeFactor': easeFactor,
        'interval': interval,
        'repetitions': repetitions,
        'nextReviewDate': nextReviewDate,
      };

  factory Sm2Record.fromJson(Map<String, dynamic> json) => Sm2Record(
        vocabId: json['vocabId'] as String,
        easeFactor: (json['easeFactor'] as num).toDouble(),
        interval: (json['interval'] as num).toInt(),
        repetitions: (json['repetitions'] as num).toInt(),
        nextReviewDate: json['nextReviewDate'] as String,
      );
}
