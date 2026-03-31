/// Script migrate dữ liệu từ JSON assets lên Supabase
///
/// Chạy một lần duy nhất sau khi đã tạo schema:
///   dart run supabase/seed.dart
///
/// Yêu cầu: điền URL + service_role key bên dưới
/// (dùng service_role key để bypass RLS khi insert)

import 'dart:convert';
import 'dart:io';

import 'package:supabase/supabase.dart';

// Điền thông tin từ Supabase Dashboard → Settings → API
const _supabaseUrl = 'https://xqbrrbtuhoxbwrpaglov.supabase.co';
const _serviceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhxYnJyYnR1aG94YndycGFnbG92Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NDk5MjM0OCwiZXhwIjoyMDkwNTY4MzQ4fQ.B65P4C6nV5AwNC3hQMnbVp-YnH7jDjcckGyFQ7RdcYM'; // KHÔNG phải anon key

Future<void> main() async {
  final client = SupabaseClient(_supabaseUrl, _serviceRoleKey);

  print('Bắt đầu seed dữ liệu...\n');

  await _seedVocabulary(client);
  await _seedCurriculum(client);

  print('\nHoàn thành! Đóng kết nối...');
  client.dispose();
}

Future<void> _seedVocabulary(SupabaseClient client) async {
  print('📚 Đang seed vocabulary...');

  final raw = await File('assets/data/vocabulary.json').readAsString();
  final list = jsonDecode(raw) as List<dynamic>;

  final rows = list.map((item) {
    final v = item as Map<String, dynamic>;
    final example = v['example'] as Map<String, dynamic>?;
    return {
      'id': v['id'],
      'czech': v['czech'],
      'vietnamese': v['vietnamese'],
      'pronunciation': v['pronunciation'],
      'audio_file': v['audioFile'],
      'part_of_speech': v['partOfSpeech'],
      'tags': v['tags'],
      'gender': v['gender'],
      'example_czech': example?['czech'],
      'example_vietnamese': example?['vietnamese'],
    };
  }).toList();

  // Upsert để chạy lại được mà không bị lỗi duplicate
  await client.from('vocabulary').upsert(rows);
  print('   ✓ ${rows.length} từ vựng');
}

Future<void> _seedCurriculum(SupabaseClient client) async {
  print('📖 Đang seed curriculum...');

  final raw = await File('assets/data/curriculum.json').readAsString();
  final data = jsonDecode(raw) as Map<String, dynamic>;

  // Course
  await client.from('courses').upsert({
    'id': data['id'],
    'title': data['title'],
    'level': data['level'],
  });
  print('   ✓ Course: ${data['title']}');

  // Units và Lessons
  final units = data['units'] as List<dynamic>;
  int unitCount = 0;
  int lessonCount = 0;

  for (int unitIndex = 0; unitIndex < units.length; unitIndex++) {
    final unit = units[unitIndex] as Map<String, dynamic>;

    await client.from('units').upsert({
      'id': unit['id'],
      'course_id': data['id'],
      'title': unit['title'],
      'subtitle': unit['subtitle'],
      'color': unit['color'],
      'dark_color': unit['darkColor'],
      'icon': unit['icon'],
      'sort_order': unitIndex,
      'prerequisite_unit_id': unit['prerequisiteUnitId'],
    });
    unitCount++;

    final lessons = unit['lessons'] as List<dynamic>;
    for (int lessonIndex = 0; lessonIndex < lessons.length; lessonIndex++) {
      final lesson = lessons[lessonIndex] as Map<String, dynamic>;

      await client.from('lessons').upsert({
        'id': lesson['id'],
        'unit_id': unit['id'],
        'title': lesson['title'],
        'subtitle': lesson['subtitle'],
        'xp_reward': lesson['xpReward'],
        'sort_order': lessonIndex,
        'exercises': lesson['exercises'],
      });
      lessonCount++;
    }
  }

  print('   ✓ $unitCount units, $lessonCount lessons');
}
