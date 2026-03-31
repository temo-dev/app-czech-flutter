import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/exercise.dart';

class MatchingPairsWidget extends StatefulWidget {
  final MatchingExercise exercise;
  final void Function(bool) onAnswer;

  const MatchingPairsWidget({super.key, required this.exercise, required this.onAnswer});

  @override
  State<MatchingPairsWidget> createState() => _MatchingPairsWidgetState();
}

class _MatchingPairsWidgetState extends State<MatchingPairsWidget> {
  String? _selectedLeft;
  String? _selectedRight;
  final Set<String> _matched = {};
  List<String>? _wrongPair;
  int _errors = 0;

  late final List<String> _shuffledRight;

  @override
  void initState() {
    super.initState();
    _shuffledRight = widget.exercise.pairs.map((p) => p.id).toList()..shuffle();
  }

  void _selectLeft(String id) {
    if (_matched.contains(id)) return;
    setState(() => _selectedLeft = _selectedLeft == id ? null : id);
    _tryMatch();
  }

  void _selectRight(String id) {
    if (_matched.contains(id)) return;
    setState(() => _selectedRight = _selectedRight == id ? null : id);
    _tryMatch();
  }

  void _tryMatch() {
    if (_selectedLeft == null || _selectedRight == null) return;
    if (_selectedLeft == _selectedRight) {
      // Match!
      setState(() {
        _matched.add(_selectedLeft!);
        _selectedLeft = null;
        _selectedRight = null;
        _wrongPair = null;
      });
      if (_matched.length == widget.exercise.pairs.length) {
        Future.delayed(const Duration(milliseconds: 400), () {
          widget.onAnswer(_errors == 0);
        });
      }
    } else {
      // Wrong
      setState(() {
        _wrongPair = [_selectedLeft!, _selectedRight!];
        _errors++;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() { _selectedLeft = null; _selectedRight = null; _wrongPair = null; });
      });
    }
  }

  Color _leftColor(String id) {
    if (_matched.contains(id)) return AppColors.successLight;
    if (_wrongPair?.contains(id) == true) return AppColors.errorLight;
    if (_selectedLeft == id) return AppColors.primary.withOpacity(0.15);
    return AppColors.white;
  }

  Color _rightColor(String id) {
    if (_matched.contains(id)) return AppColors.successLight;
    if (_wrongPair?.contains(id) == true) return AppColors.errorLight;
    if (_selectedRight == id) return AppColors.primary.withOpacity(0.15);
    return AppColors.white;
  }

  Color _borderLeft(String id) {
    if (_matched.contains(id)) return AppColors.success;
    if (_wrongPair?.contains(id) == true) return AppColors.error;
    if (_selectedLeft == id) return AppColors.primary;
    return AppColors.border;
  }

  Color _borderRight(String id) {
    if (_matched.contains(id)) return AppColors.success;
    if (_wrongPair?.contains(id) == true) return AppColors.error;
    if (_selectedRight == id) return AppColors.primary;
    return AppColors.border;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text('NỐI CÁC CẶP TƯƠNG ỨNG', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 1.5)),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column: Czech
              Expanded(
                child: Column(
                  children: widget.exercise.pairs.map((pair) {
                    final hidden = _matched.contains(pair.id);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AnimatedOpacity(
                        opacity: hidden ? 0.3 : 1,
                        duration: const Duration(milliseconds: 300),
                        child: GestureDetector(
                          onTap: hidden ? null : () => _selectLeft(pair.id),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              color: _leftColor(pair.id),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _borderLeft(pair.id), width: 2),
                            ),
                            child: Text(pair.czech, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark), textAlign: TextAlign.center),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 12),
              // Right column: Vietnamese (shuffled)
              Expanded(
                child: Column(
                  children: _shuffledRight.map((id) {
                    final pair = widget.exercise.pairs.firstWhere((p) => p.id == id);
                    final hidden = _matched.contains(id);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AnimatedOpacity(
                        opacity: hidden ? 0.3 : 1,
                        duration: const Duration(milliseconds: 300),
                        child: GestureDetector(
                          onTap: hidden ? null : () => _selectRight(id),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              color: _rightColor(id),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _borderRight(id), width: 2),
                            ),
                            child: Text(pair.vietnamese, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark), textAlign: TextAlign.center),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('${_matched.length}/${widget.exercise.pairs.length} cặp đã ghép', style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
