import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/constants.dart';

class CoinDisplay extends StatelessWidget {
  final int coins;
  final bool compact;

  const CoinDisplay({super.key, required this.coins, this.compact = false});

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppTokens.radiusLG),
          boxShadow: const [AppTokens.shadowSM],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.monetization_on, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Text('$coins',
                style: GoogleFonts.nunito(
                    color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTokens.radiusLG),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.monetization_on, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 8),
          Text('$coins 币',
              style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 14)),
        ],
      ),
    );
  }
}
