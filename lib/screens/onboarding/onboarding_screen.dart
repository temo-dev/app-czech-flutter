import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../state/user/user_notifier.dart';

const _goals = [
  _Goal(xp: 10, label: 'Nhẹ nhàng', desc: '5 phút/ngày', emoji: '🌱'),
  _Goal(xp: 20, label: 'Thông thường', desc: '10 phút/ngày', emoji: '⚡', recommended: true),
  _Goal(xp: 50, label: 'Nghiêm túc', desc: '20 phút/ngày', emoji: '🔥'),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;
  final _nameController = TextEditingController();
  int _goal = 20;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _finish() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    ref.read(userProvider.notifier).completeOnboarding(name, _goal);
    context.go('/placement');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, Color(0xFFC04820)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.15),
                        end: Offset.zero,
                      ).animate(anim),
                      child: child,
                    ),
                  ),
                  child: _buildStep(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _Step0(key: const ValueKey('step0'), onNext: () => setState(() => _step = 1));
      case 1:
        return _Step1(
          key: const ValueKey('step1'),
          controller: _nameController,
          onNext: () {
            if (_nameController.text.trim().isNotEmpty) setState(() => _step = 2);
          },
        );
      default:
        return _Step2(
          key: const ValueKey('step2'),
          name: _nameController.text.trim(),
          goal: _goal,
          onSelectGoal: (xp) => setState(() => _goal = xp),
          onFinish: _finish,
        );
    }
  }
}

class _Step0 extends StatelessWidget {
  final VoidCallback onNext;
  const _Step0({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('🇨🇿', style: TextStyle(fontSize: 80))
            .animate().scale(duration: 500.ms, curve: Curves.elasticOut),
        const SizedBox(height: 24),
        const Text(
          'Học Tiếng Séc',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
        const SizedBox(height: 8),
        const Text(
          'Dành cho người Việt Nam 🇻🇳',
          style: TextStyle(fontSize: 18, color: Color(0xFFFFE4D4)),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 350.ms),
        const SizedBox(height: 48),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: onNext,
            child: const Text(
              'Bắt đầu nào! →',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ),
        ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3),
      ],
    );
  }
}

class _Step1 extends StatelessWidget {
  final VoidCallback onNext;
  final TextEditingController controller;
  const _Step1({super.key, required this.onNext, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bạn tên là gì? 😊',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        const Center(
          child: Text(
            'Để chúng tôi gọi bạn',
            style: TextStyle(color: Color(0xFFFFE4D4), fontSize: 15),
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.textDark),
          decoration: InputDecoration(
            hintText: 'Nhập tên của bạn...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
          onSubmitted: (_) => onNext(),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: onNext,
            child: const Text(
              'Tiếp theo →',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }
}

class _Step2 extends StatelessWidget {
  final String name;
  final int goal;
  final ValueChanged<int> onSelectGoal;
  final VoidCallback onFinish;

  const _Step2({
    super.key,
    required this.name,
    required this.goal,
    required this.onSelectGoal,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Mục tiêu học của bạn?',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Xin chào, $name! 👋',
          style: const TextStyle(color: Color(0xFFFFE4D4), fontSize: 15),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ..._goals.map((g) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _GoalTile(goalItem: g, isSelected: goal == g.xp, onTap: () => onSelectGoal(g.xp)),
        )),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: onFinish,
            child: const Text(
              'Bắt đầu học! 🚀',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }
}

class _GoalTile extends StatelessWidget {
  final _Goal goalItem;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoalTile({required this.goalItem, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isSelected ? 1.03 : 1.0,
      duration: const Duration(milliseconds: 150),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.4),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Text(goalItem.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goalItem.label,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: isSelected ? AppColors.textDark : Colors.white,
                      ),
                    ),
                    Text(
                      goalItem.desc,
                      style: TextStyle(
                        fontSize: 13,
                        color: isSelected
                            ? AppColors.textMuted
                            : Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              if (goalItem.recommended)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Gợi ý',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : AppColors.primary,
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

class _Goal {
  final int xp;
  final String label;
  final String desc;
  final String emoji;
  final bool recommended;

  const _Goal({
    required this.xp,
    required this.label,
    required this.desc,
    required this.emoji,
    this.recommended = false,
  });
}
