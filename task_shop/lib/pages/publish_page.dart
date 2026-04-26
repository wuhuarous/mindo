import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/task_provider.dart';
import '../services/oss_service.dart';
import '../config/constants.dart';

class PublishPage extends StatefulWidget {
  const PublishPage({super.key});

  @override
  State<PublishPage> createState() => _PublishPageState();
}

class _PublishPageState extends State<PublishPage> {
  final _titleController = TextEditingController();
  final _rewardController = TextEditingController();
  final _textController = TextEditingController();
  String _type = 'text';
  final List<File> _selectedImages = [];
  bool _publishing = false;

  @override
  void dispose() {
    _titleController.dispose();
    _rewardController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final files = await ImagePicker().pickMultiImage();
    if (files.isNotEmpty) {
      setState(() {
        _selectedImages.clear();
        _selectedImages.addAll(files.map((f) => File(f.path)));
      });
    }
  }

  void _removeImage(int i) => setState(() => _selectedImages.removeAt(i));

  Future<void> _publish() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    final reward = int.tryParse(_rewardController.text) ?? 0;
    if (reward < 1) return;
    if (_type == 'image' && _selectedImages.isEmpty) return;

    setState(() => _publishing = true);
    try {
      final taskProvider = context.read<TaskProvider>();
      String? url;
      if (_type == 'image' && _selectedImages.isNotEmpty) {
        url = await OssService().uploadFile(_selectedImages.first,
            'tasks/${DateTime.now().millisecondsSinceEpoch}.jpg');
      } else {
        url = _textController.text.trim();
      }

      await taskProvider.publishTask(
        type: _type,
        title: title,
        contentUrl: url,
        rewardCoins: reward,
      );

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('发布成功')));
        Navigator.pop(context);
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('发布失败: $e')));
      }
    } finally {
      setState(() => _publishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('发布任务')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 类型选择
            Text('任务类型', style: _labelStyle()),
            const SizedBox(height: 10),
            Row(
              children: [
                _TypeOption(
                  icon: Icons.text_fields_rounded,
                  label: '文案',
                  selected: _type == 'text',
                  color: AppColors.textTask,
                  onTap: () => setState(() => _type = 'text'),
                ),
                const SizedBox(width: 10),
                _TypeOption(
                  icon: Icons.image_rounded,
                  label: '图片',
                  selected: _type == 'image',
                  color: AppColors.imageTask,
                  onTap: () => setState(() => _type = 'image'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 标题
            Text('任务标题', style: _labelStyle()),
            const SizedBox(height: 8),
            _ClayInput(
              controller: _titleController,
              hint: _type == 'text' ? '比如：写一句励志语录' : '比如：猜猜这张图片是哪里的',
              maxLength: 50,
            ),
            const SizedBox(height: 20),

            // 内容区
            if (_type == 'text') ...[
              Text('文案内容', style: _labelStyle()),
              const SizedBox(height: 8),
              _ClayInput(
                controller: _textController,
                hint: '输入任务要求的文案内容...',
                maxLines: 5,
                maxLength: 200,
              ),
            ],

            if (_type == 'image') ...[
              Text('上传图片', style: _labelStyle()),
              const SizedBox(height: 8),
              if (_selectedImages.isEmpty)
                GestureDetector(
                  onTap: _pickImages,
                  child: Container(
                    width: double.infinity,
                    height: 160,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(AppTokens.radiusMD),
                      border: Border.all(
                          color: AppColors.border, style: BorderStyle.solid),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.clayShadowDark.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.imageTask.withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(AppTokens.radiusSM),
                          ),
                          child: const Icon(Icons.add_photo_alternate_rounded,
                              color: AppColors.imageTask, size: 28),
                        ),
                        const SizedBox(height: 12),
                        Text('点击选择图片',
                            style: GoogleFonts.nunito(
                                color: AppColors.mutedForeground,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        Text('最多 9 张',
                            style: GoogleFonts.nunito(
                                color: AppColors.border, fontSize: 12)),
                      ],
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppTokens.radiusMD),
                      child: Image.file(
                        _selectedImages.first,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _pickImages,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius:
                                  BorderRadius.circular(AppTokens.radiusSM),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text('重新选择',
                                style: GoogleFonts.nunito(
                                    fontSize: 12,
                                    color: AppColors.mutedForeground)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _removeImage(0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.destructive.withValues(alpha: 0.1),
                              borderRadius:
                                  BorderRadius.circular(AppTokens.radiusSM),
                            ),
                            child: Text('删除',
                                style: GoogleFonts.nunito(
                                    fontSize: 12,
                                    color: AppColors.destructive)),
                          ),
                        ),
                      ],
                    ),
                    if (_selectedImages.length > 1) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 70,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedImages.length,
                          itemBuilder: (_, i) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(AppTokens.radiusSM),
                              child: Image.file(_selectedImages[i],
                                  width: 70, height: 70, fit: BoxFit.cover),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
            ],
            const SizedBox(height: 20),

            // 奖励
            Text('奖励币数', style: _labelStyle()),
            const SizedBox(height: 8),
            _ClayInput(
              controller: _rewardController,
              hint: '设置完成任务的奖励（1-10 币）',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),

            // 发布按钮
            SizedBox(
              width: double.infinity,
              height: 52,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTokens.radiusLG),
                  boxShadow:
                      _publishing ? null : const [AppTokens.shadowMD],
                ),
                child: ElevatedButton(
                  onPressed: _publishing ? null : _publish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTokens.radiusLG)),
                  ),
                  child: _publishing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text('发布任务',
                          style: GoogleFonts.nunito(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _labelStyle() => GoogleFonts.nunito(
      fontWeight: FontWeight.w600,
      fontSize: 14,
      color: AppColors.foreground);
}

class _TypeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _TypeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppTokens.durationNormal,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.1) : AppColors.card,
            borderRadius: BorderRadius.circular(AppTokens.radiusMD),
            border: Border.all(
              color: selected ? color : AppColors.border,
              width: selected ? 2 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                        color: color.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ]
                : [
                    BoxShadow(
                        color: AppColors.clayShadowDark.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 3))
                  ],
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 24,
                  color: selected ? color : AppColors.mutedForeground),
              const SizedBox(height: 6),
              Text(label,
                  style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w600,
                      color: selected ? color : AppColors.mutedForeground)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClayInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int? maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;

  const _ClayInput({
    required this.controller,
    required this.hint,
    this.maxLines,
    this.maxLength,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppTokens.radiusMD),
        boxShadow: [
          BoxShadow(
            color: AppColors.clayShadowDark.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border:
            Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines ?? 1,
        maxLength: maxLength,
        style: GoogleFonts.nunito(
            fontSize: 15, color: AppColors.foreground),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.nunito(
              color: AppColors.mutedForeground.withValues(alpha: 0.5)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 14),
          counterStyle: GoogleFonts.nunito(
              color: AppColors.mutedForeground, fontSize: 11),
        ),
      ),
    );
  }
}
