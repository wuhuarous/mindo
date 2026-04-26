import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import '../config/constants.dart';
import '../widgets/avatar_picker.dart';

class TaskDetailPage extends StatefulWidget {
  final Task task;

  const TaskDetailPage({super.key, required this.task});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  Map<String, dynamic>? _detail;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final res = await ApiService().get('/tasks/${widget.task.id}');
      if (res['success'] == true) {
        setState(() => _detail = res['data'] as Map<String, dynamic>);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color _typeColor() {
    switch (widget.task.type) {
      case 'text': return AppColors.textTask;
      case 'image': return AppColors.imageTask;
      case 'video': return AppColors.videoTask;
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasCompletion = _detail != null &&
        _detail!['completions'] != null &&
        (_detail!['completions'] as List).isNotEmpty;
    final completion =
        hasCompletion ? (_detail!['completions'] as List).first as Map<String, dynamic> : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('任务详情')),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 任务信息卡片
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius:
                          BorderRadius.circular(AppTokens.radiusXL),
                      boxShadow: [
                        AppTokens.shadowMD,
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.6),
                          blurRadius: 2,
                          offset: const Offset(-1, -1),
                        ),
                      ],
                      border: Border.all(
                          color: AppColors.border.withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: _typeColor().withValues(alpha: 0.1),
                                borderRadius:
                                    BorderRadius.circular(AppTokens.radiusSM),
                              ),
                              child: Icon(
                                widget.task.type == 'text'
                                    ? Icons.text_fields_rounded
                                    : widget.task.type == 'image'
                                        ? Icons.image_rounded
                                        : Icons.videocam_rounded,
                                color: _typeColor(),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(widget.task.title,
                                      style: GoogleFonts.fredoka(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.foreground)),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _statusBgColor(),
                                      borderRadius: BorderRadius.circular(
                                          AppTokens.radiusSM),
                                    ),
                                    child: Text(widget.task.statusLabel,
                                        style: GoogleFonts.nunito(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: _statusColor())),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // 文案内容
                        if (widget.task.type == 'text' &&
                            widget.task.contentUrl != null &&
                            widget.task.contentUrl!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.muted,
                              borderRadius:
                                  BorderRadius.circular(AppTokens.radiusSM),
                            ),
                            child: Text(widget.task.contentUrl!,
                                style: GoogleFonts.nunito(
                                    fontSize: 14,
                                    color: AppColors.foreground,
                                    height: 1.6)),
                          ),
                        ],
                        // 图片内容
                        if (widget.task.type == 'image' &&
                            widget.task.contentUrl != null) ...[
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(AppTokens.radiusMD),
                            child: Image.network(
                              widget.task.contentUrl!,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, e, s) => Container(
                                height: 180,
                                decoration: BoxDecoration(
                                  color: AppColors.muted,
                                  borderRadius: BorderRadius.circular(
                                      AppTokens.radiusMD),
                                ),
                                child: const Center(
                                    child: Icon(Icons.broken_image_rounded,
                                        color: AppColors.mutedForeground)),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            const Icon(Icons.monetization_on_rounded,
                                size: 18, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text('${widget.task.rewardCoins} 币奖励',
                                style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                    fontSize: 14)),
                            const Spacer(),
                            Text(
                              '${widget.task.createdAt.month}/${widget.task.createdAt.day} ${widget.task.createdAt.hour}:${widget.task.createdAt.minute.toString().padLeft(2, '0')}',
                              style: GoogleFonts.nunito(
                                  fontSize: 12,
                                  color: AppColors.mutedForeground),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 完成情况
                  if (hasCompletion && completion != null) ...[
                    Text('回复内容',
                        style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: AppColors.foreground)),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius:
                            BorderRadius.circular(AppTokens.radiusXL),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.statusCompleted.withValues(alpha: 0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.6),
                            blurRadius: 2,
                            offset: const Offset(-1, -1),
                          ),
                        ],
                        border: Border.all(color: AppColors.statusCompleted.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const AvatarDisplay(avatarIndex: 0, size: 32),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '领取人',
                                    style: GoogleFonts.nunito(
                                        fontSize: 12,
                                        color: AppColors.mutedForeground),
                                  ),
                                  Text('已完成',
                                      style: GoogleFonts.nunito(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.statusCompleted)),
                                ],
                              ),
                              const Spacer(),
                              if (completion['submittedAt'] != null)
                                Text(
                                  '${DateTime.parse(completion['submittedAt'] as String).month}/${DateTime.parse(completion['submittedAt'] as String).day} ${DateTime.parse(completion['submittedAt'] as String).hour}:${DateTime.parse(completion['submittedAt'] as String).minute.toString().padLeft(2, '0')}',
                                  style: GoogleFonts.nunito(
                                      fontSize: 11,
                                      color: AppColors.mutedForeground),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildContentDisplay(
                              completion['contentUrl'] as String? ?? ''),
                        ],
                      ),
                    ),
                  ] else if (widget.task.status == 'doing') ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius:
                            BorderRadius.circular(AppTokens.radiusXL),
                        border: Border.all(
                            color: AppColors.border.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.hourglass_empty_rounded,
                              size: 40, color: AppColors.border),
                          const SizedBox(height: 10),
                          Text('等待领取人提交...',
                              style: GoogleFonts.nunito(
                                  color: AppColors.mutedForeground)),
                        ],
                      ),
                    ),
                  ] else if (widget.task.status == 'pending') ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius:
                            BorderRadius.circular(AppTokens.radiusXL),
                        border: Border.all(
                            color: AppColors.border.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.inbox_rounded,
                              size: 40, color: AppColors.border),
                          const SizedBox(height: 10),
                          Text('等待被领取...',
                              style: GoogleFonts.nunito(
                                  color: AppColors.mutedForeground)),
                        ],
                      ),
                    ),
                  ] else if (widget.task.status == 'expired') ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius:
                            BorderRadius.circular(AppTokens.radiusXL),
                        border: Border.all(
                            color: AppColors.border.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.timer_off_rounded,
                              size: 40, color: AppColors.mutedForeground),
                          const SizedBox(height: 10),
                          Text('任务已过期',
                              style: GoogleFonts.nunito(
                                  color: AppColors.mutedForeground)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Color _statusColor() {
    switch (widget.task.status) {
      case 'pending': return AppColors.statusPending;
      case 'doing': return AppColors.statusDoing;
      case 'completed': return AppColors.statusCompleted;
      case 'expired': return AppColors.statusExpired;
      default: return AppColors.mutedForeground;
    }
  }

  Color _statusBgColor() {
    switch (widget.task.status) {
      case 'pending': return AppColors.statusPending.withValues(alpha: 0.1);
      case 'doing': return AppColors.statusDoing.withValues(alpha: 0.1);
      case 'completed': return AppColors.statusCompleted.withValues(alpha: 0.1);
      case 'expired': return AppColors.statusExpired.withValues(alpha: 0.1);
      default: return AppColors.muted.withValues(alpha: 0.1);
    }
  }

  bool _isImageUrl(String url) {
    if (url.isEmpty) return false;
    return url.startsWith('http') &&
        (url.contains('.jpg') || url.contains('.jpeg') ||
            url.contains('.png') || url.contains('.gif') ||
            url.contains('.webp') || url.contains('.bmp') ||
            url.contains('cos.ap-guangzhou.myqcloud.com'));
  }

  Widget _buildContentDisplay(String contentUrl) {
    if (_isImageUrl(contentUrl)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppTokens.radiusSM),
        child: Image.network(
          contentUrl,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, e, s) => Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppTokens.radiusSM),
            ),
            child: Text(contentUrl,
                style: GoogleFonts.nunito(
                    fontSize: 14, color: AppColors.foreground, height: 1.6)),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppTokens.radiusSM),
      ),
      child: Text(contentUrl,
          style: GoogleFonts.nunito(
              fontSize: 14, color: AppColors.foreground, height: 1.6)),
    );
  }
}
