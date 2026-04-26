import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../providers/timer_provider.dart';
import '../services/oss_service.dart';
import '../widgets/circular_timer.dart';
import '../config/constants.dart';

class TaskExecutePage extends StatefulWidget {
  final Task task;

  const TaskExecutePage({super.key, required this.task});

  @override
  State<TaskExecutePage> createState() => _TaskExecutePageState();
}

class _TaskExecutePageState extends State<TaskExecutePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;

  // 用户可以选择任意一种回复方式
  String _responseType = 'text';
  final _textController = TextEditingController();
  File? _selectedVideo;
  final List<File> _selectedImages = [];
  bool _submitting = false;

  static const _typeOptions = [
    {'type': 'text', 'label': '文案', 'icon': Icons.text_fields_rounded, 'color': AppColors.textTask},
    {'type': 'image', 'label': '图片', 'icon': Icons.image_rounded, 'color': AppColors.imageTask},
    {'type': 'video', 'label': '视频', 'icon': Icons.videocam_rounded, 'color': AppColors.videoTask},
  ];

  @override
  void initState() {
    super.initState();
    _shakeController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TimerProvider>().start(60);
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickContent() async {
    final picker = ImagePicker();
    if (_responseType == 'image') {
      final files = await picker.pickMultiImage();
      if (files.isNotEmpty) {
        setState(() {
          _selectedImages.clear();
          _selectedImages.addAll(files.map((f) => File(f.path)));
        });
      }
    } else if (_responseType == 'video') {
      final file = await picker.pickVideo(source: ImageSource.gallery);
      if (file != null) setState(() => _selectedVideo = File(file.path));
    }
  }

  bool _hasValidContent() {
    switch (_responseType) {
      case 'text': return _textController.text.trim().isNotEmpty;
      case 'image': return _selectedImages.isNotEmpty;
      case 'video': return _selectedVideo != null;
      default: return false;
    }
  }

  Future<void> _submit() async {
    if (!_hasValidContent()) return;

    final timerProvider = context.read<TimerProvider>();
    final taskProvider = context.read<TaskProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (timerProvider.isExpired) {
      messenger.showSnackBar(const SnackBar(content: Text('倒计时已结束')));
      return;
    }

    setState(() => _submitting = true);

    try {
      String? url;
      if (_responseType == 'text') {
        url = _textController.text.trim();
      } else if (_responseType == 'image') {
        url = await OssService().uploadFile(_selectedImages.first,
            'completions/${DateTime.now().millisecondsSinceEpoch}.jpg');
      } else if (_responseType == 'video') {
        url = await OssService().uploadFile(
            _selectedVideo!, 'completions/${DateTime.now().millisecondsSinceEpoch}.mp4');
      }

      if (url == null) {
        setState(() => _submitting = false);
        return;
      }

      await taskProvider.submitTask(widget.task.id, url);
      if (mounted) {
        messenger.showSnackBar(const SnackBar(content: Text('提交成功！奖励已发放')));
        timerProvider.stop();
        navigator.pop();
      }
    } on Exception catch (e) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text('提交失败: $e')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Color _taskTypeColor() {
    switch (widget.task.type) {
      case 'text': return AppColors.textTask;
      case 'image': return AppColors.imageTask;
      case 'video': return AppColors.videoTask;
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          context.read<TimerProvider>().stop();
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(widget.task.title),
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () {
              context.read<TimerProvider>().stop();
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Consumer<TimerProvider>(
          builder: (context, timer, _) {
            if (timer.isUrgent && timer.isRunning) {
              _shakeController.forward().then((_) => _shakeController.reverse());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  AnimatedBuilder(
                    animation: _shakeController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(
                          _shakeController.value * 4 *
                              (_shakeController.status == AnimationStatus.forward ? 1 : -1),
                          0,
                        ),
                        child: child,
                      );
                    },
                    child: CircularTimer(
                      secondsRemaining: timer.secondsRemaining,
                      isUrgent: timer.isUrgent,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 任务信息卡片
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(AppTokens.radiusMD),
                      border: Border.all(
                          color: _taskTypeColor().withValues(alpha: 0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: _taskTypeColor().withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.6),
                          blurRadius: 2,
                          offset: const Offset(-1, -1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _taskTypeColor().withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(AppTokens.radiusSM),
                              ),
                              child: Icon(
                                widget.task.type == 'text'
                                    ? Icons.text_fields_rounded
                                    : widget.task.type == 'image'
                                        ? Icons.image_rounded
                                        : Icons.videocam_rounded,
                                color: _taskTypeColor(),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(widget.task.title,
                                      style: GoogleFonts.nunito(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: AppColors.foreground)),
                                  const SizedBox(height: 2),
                                  Text('${widget.task.typeLabel}任务 · ${widget.task.rewardCoins} 币',
                                      style: GoogleFonts.nunito(
                                          fontSize: 13,
                                          color: AppColors.mutedForeground)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // 文案类型显示具体内容
                        if (widget.task.type == 'text' &&
                            widget.task.contentUrl != null &&
                            widget.task.contentUrl!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.muted,
                              borderRadius:
                                  BorderRadius.circular(AppTokens.radiusSM),
                            ),
                            child: Text(
                              widget.task.contentUrl!,
                              style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  color: AppColors.foreground,
                                  height: 1.5),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 回复方式选择器
                  Text('选择回复方式',
                      style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w600,
                          color: AppColors.foreground)),
                  const SizedBox(height: 10),
                  Row(
                    children: _typeOptions.map((opt) {
                      final selected = _responseType == opt['type'] as String;
                      final color = opt['color'] as Color;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: GestureDetector(
                            onTap: () => setState(() => _responseType = opt['type'] as String),
                            child: AnimatedContainer(
                              duration: AppTokens.durationNormal,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: selected
                                    ? color.withValues(alpha: 0.12)
                                    : AppColors.card,
                                borderRadius: BorderRadius.circular(AppTokens.radiusSM),
                                border: Border.all(
                                  color: selected ? color : AppColors.border,
                                  width: selected ? 2 : 1,
                                ),
                                boxShadow: selected
                                    ? [BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 4))]
                                    : null,
                              ),
                              child: Column(
                                children: [
                                  Icon(opt['icon'] as IconData,
                                      size: 20,
                                      color: selected ? color : AppColors.mutedForeground),
                                  const SizedBox(height: 4),
                                  Text(opt['label'] as String,
                                      style: GoogleFonts.nunito(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: selected ? color : AppColors.mutedForeground)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // 根据选择的回复方式显示对应输入
                  if (_responseType == 'text')
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(AppTokens.radiusMD),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.clayShadowDark.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                            color: AppColors.border.withValues(alpha: 0.6)),
                      ),
                      child: TextField(
                        controller: _textController,
                        maxLines: 5,
                        maxLength: 200,
                        style: GoogleFonts.nunito(color: AppColors.foreground),
                        decoration: InputDecoration(
                          hintText: '输入回复内容...',
                          hintStyle: GoogleFonts.nunito(
                              color: AppColors.mutedForeground.withValues(alpha: 0.5)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                          counterStyle: GoogleFonts.nunito(
                              color: AppColors.mutedForeground, fontSize: 11),
                        ),
                      ),
                    ),

                  if (_responseType == 'image') ...[
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppTokens.radiusLG),
                        boxShadow: const [AppTokens.shadowSM],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _pickContent,
                        icon: const Icon(Icons.image_rounded, color: AppColors.imageTask),
                        label: Text(
                            _selectedImages.isEmpty ? '选择图片' : '已选 ${_selectedImages.length} 张',
                            style: GoogleFonts.nunito(
                                fontWeight: FontWeight.w600, color: AppColors.foreground)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.card,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTokens.radiusLG),
                            side: const BorderSide(color: AppColors.border),
                          ),
                        ),
                      ),
                    ),
                    if (_selectedImages.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: SizedBox(
                          height: 80,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _selectedImages.length,
                            itemBuilder: (_, i) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(AppTokens.radiusSM),
                                child: Image.file(_selectedImages[i],
                                    width: 80, height: 80, fit: BoxFit.cover),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],

                  if (_responseType == 'video')
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppTokens.radiusLG),
                        boxShadow: const [AppTokens.shadowSM],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _pickContent,
                        icon: const Icon(Icons.videocam_rounded, color: AppColors.videoTask),
                        label: Text(_selectedVideo != null ? '已选择视频' : '选择视频',
                            style: GoogleFonts.nunito(
                                fontWeight: FontWeight.w600, color: AppColors.foreground)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.card,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTokens.radiusLG),
                            side: const BorderSide(color: AppColors.border),
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 36),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppTokens.radiusLG),
                        boxShadow: (_submitting || timer.isExpired)
                            ? null
                            : const [AppTokens.shadowMD],
                      ),
                      child: ElevatedButton(
                        onPressed: _submitting || timer.isExpired ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTokens.radiusLG),
                          ),
                        ),
                        child: _submitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : Text('提交完成',
                                style: GoogleFonts.nunito(
                                    fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
