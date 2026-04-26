import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/constants.dart';

class CircularTimer extends StatelessWidget {
  final int secondsRemaining;
  final int totalSeconds;
  final bool isUrgent;

  const CircularTimer({
    super.key,
    required this.secondsRemaining,
    this.totalSeconds = 60,
    this.isUrgent = false,
  });

  @override
  Widget build(BuildContext context) {
    final progress = secondsRemaining / totalSeconds;
    final color = isUrgent ? AppColors.destructive : AppColors.primary;

    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Claymorphism outer ring
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.6),
                  blurRadius: 4,
                  offset: const Offset(-2, -2),
                ),
              ],
            ),
          ),
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 10,
            strokeCap: StrokeCap.round,
            backgroundColor: AppColors.border.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation(color),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$secondsRemaining',
                  style: GoogleFonts.fredoka(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                Text(
                  '秒',
                  style: GoogleFonts.nunito(
                    color: isUrgent ? AppColors.destructive : AppColors.mutedForeground,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
