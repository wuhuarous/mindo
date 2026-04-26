import 'package:flutter/material.dart';
import '../config/constants.dart';

class AvatarPicker extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const AvatarPicker({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  static const avatars = [
    '🐱', '🐶', '🐼', '🦊', '🐨', '🐸',
    '🐵', '🦁', '🐯', '🐮', '🐷', '🐭',
    '🐰', '🐻', '🐔', '🐧', '🐦', '🦋',
    '🌟', '🔥', '💎', '🎯', '🚀', '🎨',
  ];

  static final avatarColors = [
    const Color(0xFFFEE2E2), const Color(0xFFE0F2FE), const Color(0xFFFEF3C7),
    const Color(0xFFFCE7F3), const Color(0xFFD1FAE5), const Color(0xFFE0E7FF),
    const Color(0xFFFFEDD5), const Color(0xFFF3E8FF), const Color(0xFFECFDF5),
    const Color(0xFFFEF2F2), const Color(0xFFF0FDF4), const Color(0xFFEFF6FF),
    const Color(0xFFFDF2F8), const Color(0xFFFEF9C3), const Color(0xFFF5F5F4),
    const Color(0xFFF1F5F9), const Color(0xFFF0F9FF), const Color(0xFFFDF4FF),
    const Color(0xFFECFEFF), const Color(0xFFFEFCE8), const Color(0xFFF7FEE7),
    const Color(0xFFFFF1F2), const Color(0xFFF0FDFA), const Color(0xFFFAF5FF),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(avatars.length, (i) {
        final isSelected = selectedIndex == i;
        return GestureDetector(
          onTap: () => onSelected(i),
          child: AnimatedContainer(
            duration: AppTokens.durationFast,
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: avatarColors[i],
              borderRadius: BorderRadius.circular(AppTokens.radiusMD),
              border: isSelected
                  ? Border.all(color: AppColors.primary, width: 2.5)
                  : Border.all(color: Colors.transparent),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4))
                    ]
                  : null,
            ),
            child: Center(
              child: Text(avatars[i], style: const TextStyle(fontSize: 28)),
            ),
          ),
        );
      }),
    );
  }
}

class AvatarDisplay extends StatelessWidget {
  final int avatarIndex;
  final double size;

  const AvatarDisplay({
    super.key,
    required this.avatarIndex,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final i = avatarIndex.clamp(0, AvatarPicker.avatars.length - 1);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AvatarPicker.avatarColors[i],
        borderRadius: BorderRadius.circular(size / 4),
      ),
      child: Center(
        child: Text(
          AvatarPicker.avatars[i],
          style: TextStyle(fontSize: size * 0.6),
        ),
      ),
    );
  }
}
