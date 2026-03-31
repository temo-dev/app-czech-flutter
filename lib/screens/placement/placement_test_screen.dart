import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/content.dart';
import '../../state/user/user_notifier.dart';

class _PlacementQuestion {
  final String id;
  final CefrLevel level;
  final String question;
  final List<({String id, String text})> options;
  final String correctId;

  const _PlacementQuestion({
    required this.id,
    required this.level,
    required this.question,
    required this.options,
    required this.correctId,
  });
}

const _questions = [
  _PlacementQuestion(id: 'p1', level: CefrLevel.a1, question: '"Děkuji" có nghĩa là gì?', options: [(id: 'a', text: 'Xin chào'), (id: 'b', text: 'Cảm ơn'), (id: 'c', text: 'Tạm biệt'), (id: 'd', text: 'Xin lỗi')], correctId: 'b'),
  _PlacementQuestion(id: 'p2', level: CefrLevel.a1, question: 'Số "pět" có nghĩa là bao nhiêu?', options: [(id: 'a', text: '3'), (id: 'b', text: '4'), (id: 'c', text: '5'), (id: 'd', text: '6')], correctId: 'c'),
  _PlacementQuestion(id: 'p3', level: CefrLevel.a1, question: '"Já ___ student." — Điền dạng đúng:', options: [(id: 'a', text: 'je'), (id: 'b', text: 'jsem'), (id: 'c', text: 'jsi'), (id: 'd', text: 'jsou')], correctId: 'b'),
  _PlacementQuestion(id: 'p4', level: CefrLevel.a1, question: '"Modrá" nghĩa là màu gì?', options: [(id: 'a', text: 'Màu đỏ'), (id: 'b', text: 'Màu vàng'), (id: 'c', text: 'Màu xanh dương'), (id: 'd', text: 'Màu xanh lá')], correctId: 'c'),
  _PlacementQuestion(id: 'p5', level: CefrLevel.a1, question: 'Cách phủ định "Mám čas" là?', options: [(id: 'a', text: 'Ne mám čas.'), (id: 'b', text: 'Nemám čas.'), (id: 'c', text: 'Mám ne čas.'), (id: 'd', text: 'Mít ne čas.')], correctId: 'b'),
  _PlacementQuestion(id: 'p6', level: CefrLevel.a2, question: '"Kolik to stojí?" có nghĩa là gì?', options: [(id: 'a', text: 'Bạn muốn gì?'), (id: 'b', text: 'Cái này ở đâu?'), (id: 'c', text: 'Giá bao nhiêu?'), (id: 'd', text: 'Bạn có không?')], correctId: 'c'),
  _PlacementQuestion(id: 'p7', level: CefrLevel.a2, question: '"Včera jsem ___ vlak." — Điền dạng quá khứ (nam):', options: [(id: 'a', text: 'jela'), (id: 'b', text: 'jet'), (id: 'c', text: 'jel'), (id: 'd', text: 'jedu')], correctId: 'c'),
  _PlacementQuestion(id: 'p8', level: CefrLevel.a2, question: '"Nemocnice" nghĩa là gì?', options: [(id: 'a', text: 'Nhà thuốc'), (id: 'b', text: 'Bệnh viện'), (id: 'c', text: 'Phòng khám'), (id: 'd', text: 'Bác sĩ')], correctId: 'b'),
  _PlacementQuestion(id: 'p9', level: CefrLevel.a2, question: 'Dạng Accusative của "žena" là?', options: [(id: 'a', text: 'žena'), (id: 'b', text: 'ženy'), (id: 'c', text: 'ženu'), (id: 'd', text: 'ženě')], correctId: 'c'),
  _PlacementQuestion(id: 'p10', level: CefrLevel.a2, question: '"Jízdenka" nghĩa là gì?', options: [(id: 'a', text: 'Bến xe'), (id: 'b', text: 'Vé xe'), (id: 'c', text: 'Lái xe'), (id: 'd', text: 'Đường phố')], correctId: 'b'),
  _PlacementQuestion(id: 'p11', level: CefrLevel.b1, question: '"Jdu bez práce" có nghĩa là?', options: [(id: 'a', text: 'Tôi đi làm'), (id: 'b', text: 'Tôi đi mà không có việc làm'), (id: 'c', text: 'Tôi không thích làm việc'), (id: 'd', text: 'Tôi đến công ty')], correctId: 'b'),
  _PlacementQuestion(id: 'p12', level: CefrLevel.b1, question: '"Životopis" nghĩa là gì?', options: [(id: 'a', text: 'Hợp đồng lao động'), (id: 'b', text: 'CV / Lý lịch'), (id: 'c', text: 'Bảng lương'), (id: 'd', text: 'Thư mời phỏng vấn')], correctId: 'b'),
  _PlacementQuestion(id: 'p13', level: CefrLevel.b1, question: 'Séc gia nhập EU năm nào?', options: [(id: 'a', text: '1999'), (id: 'b', text: '2002'), (id: 'c', text: '2004'), (id: 'd', text: '2009')], correctId: 'c'),
  _PlacementQuestion(id: 'p14', level: CefrLevel.b1, question: '"Rezervace" nghĩa là gì?', options: [(id: 'a', text: 'Bản đồ'), (id: 'b', text: 'Hộ chiếu'), (id: 'c', text: 'Đặt phòng / đặt chỗ'), (id: 'd', text: 'Hướng dẫn viên')], correctId: 'c'),
  _PlacementQuestion(id: 'p15', level: CefrLevel.b1, question: '"Jdu do práce" — "práce" ở cách nào?', options: [(id: 'a', text: 'Nominative'), (id: 'b', text: 'Genitive'), (id: 'c', text: 'Accusative'), (id: 'd', text: 'Locative')], correctId: 'b'),
];

CefrLevel _calcLevel(Map<CefrLevel, int> scores) {
  if ((scores[CefrLevel.b1] ?? 0) >= 3) return CefrLevel.b1;
  if ((scores[CefrLevel.a2] ?? 0) >= 3) return CefrLevel.a2;
  return CefrLevel.a1;
}

class PlacementTestScreen extends ConsumerStatefulWidget {
  const PlacementTestScreen({super.key});

  @override
  ConsumerState<PlacementTestScreen> createState() => _PlacementTestScreenState();
}

class _PlacementTestScreenState extends ConsumerState<PlacementTestScreen> {
  int _current = 0;
  String? _selected;
  final Map<CefrLevel, int> _scores = {CefrLevel.a1: 0, CefrLevel.a2: 0, CefrLevel.b1: 0};
  String _phase = 'intro'; // intro | test | result
  CefrLevel _resultLevel = CefrLevel.a1;

  void _handleSelect(String optId) {
    if (_selected != null) return;
    setState(() => _selected = optId);
    final q = _questions[_current];
    final correct = optId == q.correctId;
    if (correct) _scores[q.level] = (_scores[q.level] ?? 0) + 1;

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      if (_current + 1 >= _questions.length) {
        setState(() {
          _resultLevel = _calcLevel(_scores);
          _phase = 'result';
        });
      } else {
        setState(() {
          _current++;
          _selected = null;
        });
      }
    });
  }

  void _skip() {
    ref.read(userProvider.notifier).skipPlacement();
    context.go('/home');
  }

  void _confirm() {
    ref.read(userProvider.notifier).completePlacement(_resultLevel);
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return switch (_phase) {
      'intro' => _buildIntro(),
      'result' => _buildResult(),
      _ => _buildTest(),
    };
  }

  Widget _buildIntro() {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🎯', style: TextStyle(fontSize: 64))
                      .animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 16),
                  const Text(
                    'Kiểm Tra Đầu Vào',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textDark),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 8),
                  const Text(
                    '15 câu hỏi ngắn để xác định trình độ. Không phạt nếu sai!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14, height: 1.5),
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Column(
                      children: [
                        _InfoRow(emoji: '⏱️', text: '15 câu hỏi, khoảng 5 phút'),
                        SizedBox(height: 8),
                        _InfoRow(emoji: '📊', text: 'Phân loại A1 / A2 / B1'),
                        SizedBox(height: 8),
                        _InfoRow(emoji: '💚', text: 'Không trừ tim, không áp lực'),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => setState(() => _phase = 'test'),
                    child: const Text('Bắt đầu kiểm tra'),
                  ).animate().fadeIn(delay: 500.ms),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _skip,
                    child: const Text('Bỏ qua, học từ A1', style: TextStyle(color: AppColors.textMuted, decoration: TextDecoration.underline)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResult() {
    final levelLabel = switch (_resultLevel) {
      CefrLevel.a1 => 'Người mới bắt đầu',
      CefrLevel.a2 => 'Sơ cấp',
      CefrLevel.b1 => 'Trung cấp',
    };
    final levelColor = switch (_resultLevel) {
      CefrLevel.a1 => const Color(0xFF059669),
      CefrLevel.a2 => const Color(0xFF2563EB),
      CefrLevel.b1 => const Color(0xFF7C3AED),
    };
    final levelBg = switch (_resultLevel) {
      CefrLevel.a1 => const Color(0xFFECFDF5),
      CefrLevel.a2 => const Color(0xFFEFF6FF),
      CefrLevel.b1 => const Color(0xFFF5F3FF),
    };

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 72))
                      .animate().scale(delay: 200.ms, duration: 600.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 16),
                  const Text('Kết Quả', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                  const SizedBox(height: 8),
                  const Text('Dựa trên các câu trả lời, trình độ của bạn là:', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: levelBg,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: levelColor.withOpacity(0.3), width: 2),
                    ),
                    child: Column(
                      children: [
                        Text(_resultLevel.display, style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: levelColor)),
                        Text(levelLabel, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: levelColor)),
                        const SizedBox(height: 8),
                        Text(
                          'A1: ${_scores[CefrLevel.a1]}/5 đúng · A2: ${_scores[CefrLevel.a2]}/5 đúng · B1: ${_scores[CefrLevel.b1]}/5 đúng',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.9, 0.9)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _confirm,
                    child: Text('Bắt đầu học từ ${_resultLevel.display}'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _skip,
                    child: const Text('Bắt đầu từ A1 thay vì', style: TextStyle(color: AppColors.textMuted, decoration: TextDecoration.underline)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTest() {
    final q = _questions[_current];
    final progress = (_current / _questions.length);
    final levelColor = switch (q.level) {
      CefrLevel.a1 => const Color(0xFF059669),
      CefrLevel.a2 => const Color(0xFF2563EB),
      CefrLevel.b1 => const Color(0xFF7C3AED),
    };
    final levelBg = switch (q.level) {
      CefrLevel.a1 => const Color(0xFFD1FAE5),
      CefrLevel.a2 => const Color(0xFFDBEAFE),
      CefrLevel.b1 => const Color(0xFFEDE9FE),
    };

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(onPressed: _skip, child: const Text('Bỏ qua', style: TextStyle(color: AppColors.textMuted))),
                        Text('${_current + 1} / ${_questions.length}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: levelBg, borderRadius: BorderRadius.circular(20)),
                          child: Text(q.level.display, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: levelColor)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppColors.cream,
                        valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
              // Question
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween<Offset>(begin: const Offset(0.15, 0), end: Offset.zero).animate(anim),
                        child: child,
                      ),
                    ),
                    child: Column(
                      key: ValueKey(q.id),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.cream,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('CÂU HỎI', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 1.5)),
                              const SizedBox(height: 8),
                              Text(q.question, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...q.options.map((opt) {
                          Color bgColor = AppColors.white;
                          Color borderColor = AppColors.border;
                          Color textColor = AppColors.textDark;

                          if (_selected != null) {
                            if (opt.id == q.correctId) {
                              bgColor = AppColors.success;
                              borderColor = AppColors.success;
                              textColor = Colors.white;
                            } else if (opt.id == _selected) {
                              bgColor = AppColors.error;
                              borderColor = AppColors.error;
                              textColor = Colors.white;
                            } else {
                              bgColor = AppColors.cream;
                              borderColor = AppColors.border;
                              textColor = AppColors.textMuted;
                            }
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: GestureDetector(
                              onTap: () => _handleSelect(opt.id),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: borderColor, width: 2),
                                ),
                                child: Text(opt.text, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: textColor)),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String emoji;
  final String text;
  const _InfoRow({required this.emoji, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(fontSize: 14, color: AppColors.textMuted)),
      ],
    );
  }
}
