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
      appBar: AppBar(
        title: Text('发布差事', style: GoogleFonts.fredoka(fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 类型选择 — 大卡片式
            _buildSectionLabel('选择差事类型', Icons.category_rounded),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildTypeCard(
                  icon: Icons.text_fields_rounded,
                  label: '文案',
                  desc: '写段文字',
                  color: AppColors.textTask,
                  selected: _type == 'text',
                  onTap: () => setState(() => _type = 'text'),
                ),
                const SizedBox(width: 12),
                _buildTypeCard(
                  icon: Icons.image_rounded,
                  label: '图片',
                  desc: '拍张照片',
                  color: AppColors.imageTask,
                  selected: _type == 'image',
                  onTap: () => setState(() => _type = 'image'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 标题
            _buildSectionLabel('差事标题', Icons.edit_note_rounded),
            const SizedBox(height: 10),
            _buildTitleInput(),

            const SizedBox(height: 24),

            // 内容区
            _buildSectionLabel(
              _type == 'text' ? '文案内容' : '上传图片',
              _type == 'text' ? Icons.article_rounded : Icons.add_photo_alternate_rounded,
            ),
            const SizedBox(height: 10),
            if (_type == 'text') _buildTextContentInput(),
            if (_type == 'image') _buildImagePicker(),

            const SizedBox(height: 24),

            // 奖励
            _buildSectionLabel('奖励设置', Icons.monetization_on_rounded),
            const SizedBox(height: 10),
            _buildRewardInput(),

            const SizedBox(height: 36),

            // 发布按钮
            _buildPublishButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text, IconData icon) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
        const SizedBox(width: 8),
        Text(text,
            style: GoogleFonts.nunito(
                fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.foreground)),
      ],
    );
  }

  Widget _buildTypeCard({
    required IconData icon,
    required String label,
    required String desc,
    required Color color,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppTokens.durationNormal,
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.08) : AppColors.card,
            borderRadius: BorderRadius.circular(AppTokens.radiusXL),
            border: Border.all(
              color: selected ? color : AppColors.border.withValues(alpha: 0.4),
              width: selected ? 2 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 16, offset: const Offset(0, 8)),
                    BoxShadow(color: Colors.white.withValues(alpha: 0.8), blurRadius: 2, offset: const Offset(-1, -1)),
                  ]
                : [
                    BoxShadow(color: AppColors.clayShadowDark.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 4)),
                    BoxShadow(color: Colors.white.withValues(alpha: 0.5), blurRadius: 1, offset: const Offset(-1, -1)),
                  ],
          ),
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: selected ? color.withValues(alpha: 0.15) : AppColors.muted,
                  borderRadius: BorderRadius.circular(AppTokens.radiusMD),
                ),
                child: Icon(icon, size: 28, color: selected ? color : AppColors.mutedForeground),
              ),
              const SizedBox(height: 12),
              Text(label,
                  style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: selected ? color : AppColors.foreground)),
              const SizedBox(height: 4),
              Text(desc,
                  style: GoogleFonts.nunito(
                      fontSize: 11, color: AppColors.mutedForeground)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppTokens.radiusMD),
        boxShadow: [
          BoxShadow(color: AppColors.clayShadowDark.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 3)),
          BoxShadow(color: Colors.white.withValues(alpha: 0.5), blurRadius: 1, offset: const Offset(-1, -1)),
        ],
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: TextField(
        controller: _titleController,
        maxLength: 50,
        style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.foreground),
        decoration: InputDecoration(
          hintText: _type == 'text' ? '比如：写一句励志语录' : '比如：拍一张日落的照片',
          hintStyle: GoogleFonts.nunito(color: AppColors.mutedForeground.withValues(alpha: 0.45), fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          counterStyle: GoogleFonts.nunito(color: AppColors.mutedForeground, fontSize: 11),
        ),
      ),
    );
  }

  Widget _buildTextContentInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppTokens.radiusMD),
        boxShadow: [
          BoxShadow(color: AppColors.clayShadowDark.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 3)),
          BoxShadow(color: Colors.white.withValues(alpha: 0.5), blurRadius: 1, offset: const Offset(-1, -1)),
        ],
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: TextField(
        controller: _textController,
        maxLines: 5,
        maxLength: 200,
        style: GoogleFonts.nunito(fontSize: 14, color: AppColors.foreground, height: 1.6),
        decoration: InputDecoration(
          hintText: '输入任务要求的文案内容...',
          hintStyle: GoogleFonts.nunito(color: AppColors.mutedForeground.withValues(alpha: 0.45), fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(18),
          counterStyle: GoogleFonts.nunito(color: AppColors.mutedForeground, fontSize: 11),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    if (_selectedImages.isEmpty) {
      return GestureDetector(
        onTap: _pickImages,
        child: Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppTokens.radiusXL),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.5), style: BorderStyle.solid),
            boxShadow: [
              BoxShadow(color: AppColors.clayShadowDark.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 4)),
              BoxShadow(color: Colors.white.withValues(alpha: 0.5), blurRadius: 1, offset: const Offset(-1, -1)),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.imageTask.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTokens.radiusMD),
                ),
                child: const Icon(Icons.add_photo_alternate_rounded, color: AppColors.imageTask, size: 30),
              ),
              const SizedBox(height: 14),
              Text('点击选择图片',
                  style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.foreground)),
              const SizedBox(height: 4),
              Text('支持 JPG、PNG 格式',
                  style: GoogleFonts.nunito(fontSize: 12, color: AppColors.mutedForeground)),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppTokens.radiusXL),
          child: Stack(
            children: [
              Image.file(
                _selectedImages.first,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () => _removeImage(0),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.destructive,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildChipButton('换一张', Icons.swap_horiz_rounded, _pickImages),
            const Spacer(),
            Text('${_selectedImages.length} 张已选',
                style: GoogleFonts.nunito(fontSize: 12, color: AppColors.mutedForeground)),
          ],
        ),
      ],
    );
  }

  Widget _buildChipButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppTokens.radiusSM),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(color: AppColors.clayShadowDark.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.mutedForeground),
            const SizedBox(width: 6),
            Text(label, style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.mutedForeground)),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppTokens.radiusMD),
        boxShadow: [
          BoxShadow(color: AppColors.clayShadowDark.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 3)),
          BoxShadow(color: Colors.white.withValues(alpha: 0.5), blurRadius: 1, offset: const Offset(-1, -1)),
        ],
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.monetization_on_rounded, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _rewardController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.foreground),
              decoration: InputDecoration(
                hintText: '1-10 币',
                hintStyle: GoogleFonts.nunito(color: AppColors.mutedForeground.withValues(alpha: 0.45), fontSize: 14),
                border: InputBorder.none,
              ),
            ),
          ),
          Text('币', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
        ],
      ),
    );
  }

  Widget _buildPublishButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTokens.radiusXL),
        gradient: _publishing
            ? null
            : const LinearGradient(
                colors: [Color(0xFFF97316), Color(0xFFEA580C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: _publishing ? AppColors.border : null,
        boxShadow: _publishing
            ? null
            : [
                BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8)),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _publishing ? null : _publish,
          borderRadius: BorderRadius.circular(AppTokens.radiusXL),
          child: Center(
            child: _publishing
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 22),
                      const SizedBox(width: 10),
                      Text('发布差事',
                          style: GoogleFonts.nunito(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
