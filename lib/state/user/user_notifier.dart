import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/utils/notification_service.dart';
import '../../data/models/content.dart';
import '../../engine/sm2.dart' show todayIso;
import 'user_state.dart';

const _kUserBox = 'user-store';
const _kUserKey = 'state';

class UserNotifier extends StateNotifier<UserState> {
  UserNotifier() : super(const UserState()) {
    _load();
  }

  void _load() {
    final box = Hive.box(_kUserBox);
    final raw = box.get(_kUserKey);
    if (raw != null) {
      state = UserState.fromJson(jsonDecode(raw as String) as Map<String, dynamic>);
    }
  }

  void _save() {
    final box = Hive.box(_kUserBox);
    box.put(_kUserKey, jsonEncode(state.toJson()));
  }

  void completeOnboarding(String name, int goalXP) {
    state = state.copyWith(name: name, dailyGoalXP: goalXP, onboardingDone: true);
    _save();
  }

  void completePlacement(CefrLevel level) {
    state = state.copyWith(cefrLevel: level, placementDone: true);
    _save();
  }

  void skipPlacement() {
    state = state.copyWith(cefrLevel: CefrLevel.a1, placementDone: true);
    _save();
  }

  void addXP(int amount) {
    final today = todayIso();
    final isNewDay = state.lastActivityDate != today;
    final yesterday = () {
      final d = DateTime.now().subtract(const Duration(days: 1));
      return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    }();
    final wasYesterday = state.lastActivityDate == yesterday;

    state = state.copyWith(
      xp: state.xp + amount,
      todayXP: isNewDay ? amount : state.todayXP + amount,
      lastActivityDate: today,
      streak: isNewDay ? (wasYesterday ? state.streak + 1 : 1) : state.streak,
    );
    _save();
  }

  void checkStreak() {
    final today = todayIso();
    if (state.lastActivityDate == today) return;
    final yesterday = () {
      final d = DateTime.now().subtract(const Duration(days: 1));
      return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    }();
    if (state.lastActivityDate.compareTo(yesterday) < 0 && state.streak > 0) {
      state = state.copyWith(streak: 0, todayXP: 0);
    } else if (state.lastActivityDate != today) {
      state = state.copyWith(todayXP: 0);
    }
    _save();
  }

  Future<void> setNotifications(bool enabled, {int? hour}) async {
    state = state.copyWith(
      notificationsEnabled: enabled,
      notificationHour: hour ?? state.notificationHour,
    );
    _save();

    if (enabled) {
      await NotificationService.requestPermission();
      await NotificationService.scheduleDailyReminder(
          hour ?? state.notificationHour);
    } else {
      await NotificationService.cancelReminder();
    }
  }

  void toggleBookmark(String mediaId) {
    final ids = state.bookmarkedMediaIds;
    state = state.copyWith(
      bookmarkedMediaIds: ids.contains(mediaId)
          ? ids.where((id) => id != mediaId).toList()
          : [...ids, mediaId],
    );
    _save();
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserState>(
  (ref) => UserNotifier(),
);
