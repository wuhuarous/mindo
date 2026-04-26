import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/constants.dart';

/// Claymorphism style blind box card with Tactile Digital press effect
class BlindBoxCard extends StatefulWidget {
  final bool isOpened;
  final String? taskType;
  final String? taskTitle;
  final String? contentUrl;
  final int? rewardCoins;
  final VoidCallback? onTap;

  const BlindBoxCard({
    super.key,
    this.isOpened = false,
    this.taskType,
    this.taskTitle,
    this.contentUrl,
    this.rewardCoins,
    this.onTap,
  });

  @override
  State<BlindBoxCard> createState() => _BlindBoxCardState();
}

class _BlindBoxCardState extends State<BlindBoxCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: AppTokens.durationFast,
    );
    _pressScale = Tween<double>(begin: 1.0, end: AppTokens.pressScale).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void onTapDown(TapDownDetails _) => _pressController.forward();
  void onTapUp(TapUpDetails _) {
    _pressController.reverse();
    if (widget.onTap != null && !widget.isOpened) widget.onTap!();
  }
  void onTapCancel() => _pressController.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      onTapCancel: onTapCancel,
      child: AnimatedBuilder(
        animation: _pressScale,
        builder: (context, child) {
          return Transform.scale(scale: _pressScale.value, child: child);
        },
        child: AnimatedSwitcher(
          duration: AppTokens.durationSlow,
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeIn,
          child: widget.isOpened ? _buildRevealed() : _buildClosed(),
        ),
      ),
    );
  }

  Widget _buildClosed() {
    return Container(
      key: const ValueKey('closed'),
      width: 220,
      height: 280,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF7B00), Color(0xFFFF9D45)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTokens.radius2XL),
        boxShadow: [
          AppTokens.shadowLG,
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.3),
            blurRadius: 2,
            offset: const Offset(-2, -2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 12,
            left: 20,
            right: 20,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 0.8,
                  colors: [
                    Colors.white.withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.question_mark_rounded,
                      size: 48, color: Colors.white),
                ),
                const SizedBox(height: 20),
                Text('点击开盲盒',
                    style: GoogleFonts.fredoka(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('试试手气！',
                    style: GoogleFonts.nunito(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevealed() {
    final typeIcons = {
      'text': Icons.text_fields_rounded,
      'image': Icons.image_rounded,
      'video': Icons.videocam_rounded,
    };
    final typeColors = {
      'text': AppColors.textTask,
      'image': AppColors.imageTask,
      'video': AppColors.videoTask,
    };
    final typeLabels = {'text': '文案', 'image': '图片', 'video': '视频'};
    final icon = typeIcons[widget.taskType] ?? Icons.task_alt_rounded;
    final iconColor = typeColors[widget.taskType] ?? AppColors.primary;

    return Container(
      key: const ValueKey('opened'),
      width: 220,
      height: 320,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppTokens.radius2XL),
        boxShadow: [
          AppTokens.shadowMD,
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.6),
            blurRadius: 2,
            offset: const Offset(-1, -1),
          ),
        ],
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.spaceXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTokens.radiusLG),
              ),
              child: Icon(icon, size: 28, color: iconColor),
            ),
            const SizedBox(height: 14),
            Text(widget.taskTitle ?? '',
                style: GoogleFonts.fredoka(
                    fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.foreground),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            // Show text content for text type tasks
            if (widget.taskType == 'text' && widget.contentUrl != null && widget.contentUrl!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.muted,
                  borderRadius: BorderRadius.circular(AppTokens.radiusSM),
                ),
                child: Text(
                  widget.contentUrl!,
                  style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: AppColors.mutedForeground,
                      height: 1.4),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            if (widget.taskType == 'image' || widget.taskType == 'video')
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 6),
                child: Icon(
                  widget.taskType == 'image' ? Icons.image_rounded : Icons.videocam_rounded,
                  size: 36,
                  color: iconColor.withValues(alpha: 0.4),
                ),
              ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTokens.radiusSM),
              ),
              child: Text(
                '${typeLabels[widget.taskType] ?? ''} · ${widget.rewardCoins ?? 0} 币',
                style: GoogleFonts.nunito(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
