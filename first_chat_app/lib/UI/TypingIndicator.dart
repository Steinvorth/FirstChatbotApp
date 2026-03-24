import 'package:flutter/material.dart';
import 'package:first_chat_app/Theme/index.dart';

/// Animated typing indicator — 3 dots that bounce in sequence.
/// Shown inside the AI bubble while waiting for the first token.
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  static const int _dotCount = 3;
  static const Duration _dotDuration = Duration(milliseconds: 500);
  static const Duration _dotDelay = Duration(milliseconds: 160);

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(_dotCount, (i) {
      return AnimationController(vsync: this, duration: _dotDuration);
    });

    _animations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0,
        end: -6,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    }).toList();

    _StartAnimation();
  }

  void _StartAnimation() async {
    while (mounted) {
      for (int i = 0; i < _dotCount; i++) {
        if (!mounted) return;
        _controllers[i].forward();
        await Future.delayed(_dotDelay);
      }
      for (int i = 0; i < _dotCount; i++) {
        if (!mounted) return;
        _controllers[i].reverse();
        await Future.delayed(_dotDelay);
      }
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_dotCount, (i) {
        return AnimatedBuilder(
          animation: _animations[i],
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _animations[i].value),
              child: child,
            );
          },
          child: Container(
            margin: EdgeInsets.only(right: i < _dotCount - 1 ? 4 : 0),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.textMuted.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}
