import 'dart:math';
import '../data/models/sm2_record.dart';

String todayIso() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}

Sm2Record createRecord(String vocabId) {
  return Sm2Record(vocabId: vocabId, nextReviewDate: todayIso());
}

/// quality: 0–5 (0-1 = wrong, 2 = hard, 3 = ok, 4 = good, 5 = perfect)
Sm2Record updateSm2(Sm2Record record, int quality) {
  final q = quality.clamp(0, 5);
  var easeFactor = record.easeFactor;
  var interval = record.interval;
  var repetitions = record.repetitions;

  if (q < 3) {
    // Failed — reset
    repetitions = 0;
    interval = 1;
  } else {
    if (repetitions == 0) {
      interval = 1;
    } else if (repetitions == 1) {
      interval = 6;
    } else {
      interval = (interval * easeFactor).round();
    }
    repetitions += 1;
    easeFactor = max(1.3, easeFactor + 0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));
  }

  final nextDate = DateTime.now().add(Duration(days: interval));
  final nextDateStr =
      '${nextDate.year}-${nextDate.month.toString().padLeft(2, '0')}-${nextDate.day.toString().padLeft(2, '0')}';

  return record.copyWith(
    easeFactor: easeFactor,
    interval: interval,
    repetitions: repetitions,
    nextReviewDate: nextDateStr,
  );
}

bool isDue(Sm2Record record) {
  return record.nextReviewDate.compareTo(todayIso()) <= 0;
}
