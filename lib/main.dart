import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'core/config/supabase_config.dart';
import 'core/utils/notification_service.dart';
import 'data/models/sm2_record.dart';
import 'data/repositories/curriculum_repository.dart';
import 'state/progress/progress_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Init Hive
  await Hive.initFlutter();
  Hive.registerAdapter(Sm2RecordAdapter());
  await Future.wait([
    Hive.openBox('user-store'),
    Hive.openBox('progress-store'),
    Hive.openBox('review-store'),
  ]);

  // Init Supabase
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  // Init notifications
  await NotificationService.init();

  // Load curriculum data
  final curriculumRepo = CurriculumRepository();
  await curriculumRepo.init();

  runApp(
    ProviderScope(
      overrides: [
        curriculumRepositoryProvider.overrideWithValue(curriculumRepo),
      ],
      child: const CzechApp(),
    ),
  );
}
