import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task.dart';
import '../config/constants.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;

  const TaskCard({super.key, required this.task, this.onTap});

  Color _statusColor() {
    switch (task.status) {
      case 'pending': return AppColors.statusPending;
      case 'doing': return AppColors.statusDoing;
      case 'completed': return AppColors.statusCompleted;
      case 'expired': return AppColors.statusExpired;
      default: return AppColors.mutedForeground;
    }
  }

  Color _typeColor() {
    switch (task.type) {
      case 'text': return AppColors.textTask;
      case 'image': return AppColors.imageTask;
      case 'video': return AppColors.videoTask;
      default: return AppColors.primary;
    }
  }

  IconData _typeIcon() {
    switch (task.type) {
      case 'text': return Icons.text_fields_rounded;
      case 'image': return Icons.image_rounded;
      case 'video': return Icons.videocam_rounded;
      default: return Icons.task_alt_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _typeColor();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppTokens.radiusXL),
        boxShadow: [
          AppTokens.shadowSM,
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.5),
            blurRadius: 1,
            offset: const Offset(-1, -1),
          ),
        ],
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTokens.radiusXL),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTokens.radiusMD),
                ),
                child: Icon(_typeIcon(), color: typeColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task.title,
                        style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: AppColors.foreground)),
                    const SizedBox(height: 4),
                    Text('${task.typeLabel} · ${task.rewardCoins} 币奖励',
                        style: GoogleFonts.nunito(
                            color: AppColors.mutedForeground,
                            fontSize: 13)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _statusColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTokens.radiusSM),
                ),
                child: Text(task.statusLabel,
                    style: GoogleFonts.nunito(
                        color: _statusColor(),
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
