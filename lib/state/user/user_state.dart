import '../../data/models/content.dart';

class UserState {
  final String name;
  final int xp;
  final int streak;
  final String lastActivityDate;
  final int dailyGoalXP;
  final int todayXP;
  final bool onboardingDone;
  final CefrLevel cefrLevel;
  final bool placementDone;
  final bool notificationsEnabled;
  final int notificationHour;
  final List<String> bookmarkedMediaIds;

  const UserState({
    this.name = '',
    this.xp = 0,
    this.streak = 0,
    this.lastActivityDate = '',
    this.dailyGoalXP = 20,
    this.todayXP = 0,
    this.onboardingDone = false,
    this.cefrLevel = CefrLevel.a1,
    this.placementDone = false,
    this.notificationsEnabled = false,
    this.notificationHour = 20,
    this.bookmarkedMediaIds = const [],
  });

  UserState copyWith({
    String? name,
    int? xp,
    int? streak,
    String? lastActivityDate,
    int? dailyGoalXP,
    int? todayXP,
    bool? onboardingDone,
    CefrLevel? cefrLevel,
    bool? placementDone,
    bool? notificationsEnabled,
    int? notificationHour,
    List<String>? bookmarkedMediaIds,
  }) {
    return UserState(
      name: name ?? this.name,
      xp: xp ?? this.xp,
      streak: streak ?? this.streak,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      dailyGoalXP: dailyGoalXP ?? this.dailyGoalXP,
      todayXP: todayXP ?? this.todayXP,
      onboardingDone: onboardingDone ?? this.onboardingDone,
      cefrLevel: cefrLevel ?? this.cefrLevel,
      placementDone: placementDone ?? this.placementDone,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationHour: notificationHour ?? this.notificationHour,
      bookmarkedMediaIds: bookmarkedMediaIds ?? this.bookmarkedMediaIds,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'xp': xp,
        'streak': streak,
        'lastActivityDate': lastActivityDate,
        'dailyGoalXP': dailyGoalXP,
        'todayXP': todayXP,
        'onboardingDone': onboardingDone,
        'cefrLevel': cefrLevel.display,
        'placementDone': placementDone,
        'notificationsEnabled': notificationsEnabled,
        'notificationHour': notificationHour,
        'bookmarkedMediaIds': bookmarkedMediaIds,
      };

  factory UserState.fromJson(Map<String, dynamic> json) => UserState(
        name: json['name'] as String? ?? '',
        xp: (json['xp'] as num?)?.toInt() ?? 0,
        streak: (json['streak'] as num?)?.toInt() ?? 0,
        lastActivityDate: json['lastActivityDate'] as String? ?? '',
        dailyGoalXP: (json['dailyGoalXP'] as num?)?.toInt() ?? 20,
        todayXP: (json['todayXP'] as num?)?.toInt() ?? 0,
        onboardingDone: json['onboardingDone'] as bool? ?? false,
        cefrLevel: CefrLevelExt.fromString(json['cefrLevel'] as String? ?? 'A1'),
        placementDone: json['placementDone'] as bool? ?? false,
        notificationsEnabled: json['notificationsEnabled'] as bool? ?? false,
        notificationHour: (json['notificationHour'] as num?)?.toInt() ?? 20,
        bookmarkedMediaIds:
            (json['bookmarkedMediaIds'] as List<dynamic>?)?.cast<String>() ?? [],
      );
}
