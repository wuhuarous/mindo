import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task.dart';
import '../config/constants.dart';
import 'avatar_picker.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;

  const TaskCard({super.key, required this.task, this.onTap});

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

  Color _statusColor() {
    switch (task.status) {
      case 'pending': return AppColors.statusPending;
      case 'doing': return AppColors.statusDoing;
      case 'completed': return AppColors.statusCompleted;
      case 'expired': return AppColors.statusExpired;
      default: return AppColors.mutedForeground;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _typeColor();
    final user = task.publisher ?? task.claimer;

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Avatar
                  AvatarDisplay(
                    avatarIndex: user?.avatarIndex ?? 0,
                    size: 40,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? '未知用户',
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColors.foreground,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _timeAgo(task.createdAt),
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            color: AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _statusColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTokens.radiusSM),
                    ),
                    child: Text(
                      task.statusLabel,
                      style: GoogleFonts.nunito(
                        color: _statusColor(),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Title & type
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTokens.radiusSM),
                    ),
                    child: Icon(_typeIcon(), color: typeColor, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      task.title,
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppColors.foreground,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.monetization_on_rounded, size: 16, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    '${task.rewardCoins} 币',
                    style: GoogleFonts.nunito(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inMinutes < 60) return '${diff.inMinutes} 分钟前';
    if (diff.inHours < 24) return '${diff.inHours} 小时前';
    if (diff.inDays < 7) return '${diff.inDays} 天前';
    return '${dt.month}/${dt.day}';
  }
}
