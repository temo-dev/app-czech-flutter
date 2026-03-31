import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/sm2_record.dart';
import '../../engine/sm2.dart';

const _kReviewBox = 'review-store';
const _kReviewKey = 'records';

class ReviewState {
  final Map<String, Sm2Record> records;

  const ReviewState({this.records = const {}});

  ReviewState copyWith({Map<String, Sm2Record>? records}) =>
      ReviewState(records: records ?? this.records);

  List<Sm2Record> getDueItems() =>
      records.values.where((r) => isDue(r)).toList();

  int getDueCount() => records.values.where((r) => isDue(r)).length;
}

class ReviewNotifier extends StateNotifier<ReviewState> {
  ReviewNotifier() : super(const ReviewState()) {
    _load();
  }

  void _load() {
    final box = Hive.box(_kReviewBox);
    final raw = box.get(_kReviewKey);
    if (raw != null) {
      final map = jsonDecode(raw as String) as Map<String, dynamic>;
      final records = map.map(
        (k, v) => MapEntry(k, Sm2Record.fromJson(v as Map<String, dynamic>)),
      );
      state = ReviewState(records: records);
    }
  }

  void _save() {
    final box = Hive.box(_kReviewBox);
    final json = state.records.map((k, v) => MapEntry(k, v.toJson()));
    box.put(_kReviewKey, jsonEncode(json));
  }

  void addVocabToReview(String vocabId) {
    if (state.records.containsKey(vocabId)) return;
    final newRecords = Map<String, Sm2Record>.from(state.records);
    newRecords[vocabId] = createRecord(vocabId);
    state = state.copyWith(records: newRecords);
    _save();
  }

  void updateRecord(String vocabId, int quality) {
    final rec = state.records[vocabId];
    if (rec == null) return;
    final newRecords = Map<String, Sm2Record>.from(state.records);
    newRecords[vocabId] = updateSm2(rec, quality);
    state = state.copyWith(records: newRecords);
    _save();
  }
}

final reviewProvider = StateNotifierProvider<ReviewNotifier, ReviewState>(
  (ref) => ReviewNotifier(),
);
