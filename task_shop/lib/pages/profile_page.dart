import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/coin_display.dart';
import '../widgets/avatar_picker.dart';
import '../config/constants.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _showPicker = false;
  bool _editingNickname = false;
  late TextEditingController _nicknameController;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _saveAvatar(int index) async {
    setState(() => _showPicker = false);
    try {
      await context.read<UserProvider>().updateProfile(avatarIndex: index);
    } on Exception {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('头像保存失败')));
      }
    }
  }

  void _startEditNickname(String? current) {
    _nicknameController.text = current ?? '';
    setState(() => _editingNickname = true);
  }

  Future<void> _saveNickname() async {
    final name = _nicknameController.text.trim();
    setState(() => _editingNickname = false);
    if (name.isEmpty) return;
    try {
      await context.read<UserProvider>().updateProfile(nickname: name);
    } on Exception {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('昵称保存失败')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final displayName = user?.displayName ?? '用户';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('个人中心')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 用户卡片
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppTokens.radiusXL),
              boxShadow: [
                AppTokens.shadowMD,
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.6),
                  blurRadius: 2,
                  offset: const Offset(-1, -1),
                ),
              ],
              border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _showPicker = !_showPicker),
                  child: Stack(
                    children: [
                      AvatarDisplay(
                        avatarIndex: user?.avatarIndex ?? 0,
                        size: 72,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: const [AppTokens.shadowSM],
                          ),
                          child: const Icon(Icons.edit_rounded,
                              size: 14, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 昵称 — 可编辑
                if (_editingNickname) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 160,
                        child: TextField(
                          controller: _nicknameController,
                          autofocus: true,
                          maxLength: 20,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.foreground),
                          decoration: InputDecoration(
                            hintText: '输入昵称',
                            hintStyle: GoogleFonts.nunito(
                                color: AppColors.mutedForeground.withValues(alpha: 0.5),
                                fontSize: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppTokens.radiusSM),
                              borderSide: const BorderSide(color: AppColors.primary),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppTokens.radiusSM),
                              borderSide: const BorderSide(color: AppColors.primary, width: 2),
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            counterText: '',
                            isDense: true,
                          ),
                          onSubmitted: (_) => _saveNickname(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _saveNickname,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  GestureDetector(
                    onTap: () => _startEditNickname(user?.nickname),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            displayName,
                            style: GoogleFonts.nunito(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.foreground),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.edit_rounded,
                            size: 16, color: AppColors.mutedForeground),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 8),
                CoinDisplay(coins: user?.coins ?? 0),
              ],
            ),
          ),

          // 头像选择器
          if (_showPicker) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppTokens.radiusXL),
                boxShadow: const [AppTokens.shadowSM],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('选择头像',
                      style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w600, color: AppColors.foreground)),
                  const SizedBox(height: 12),
                  AvatarPicker(
                    selectedIndex: user?.avatarIndex ?? 0,
                    onSelected: _saveAvatar,
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),
          _MenuItem(
              icon: Icons.list_alt_rounded,
              title: '我的任务',
              subtitle: '查看发布和领取的任务',
              onTap: () => Navigator.pop(context)),
          _MenuItem(
              icon: Icons.card_giftcard_rounded,
              title: '盲盒记录',
              subtitle: '查看抽盲盒历史'),
          _MenuItem(
              icon: Icons.info_rounded,
              title: '关于',
              subtitle: '一分钟差事铺 v1.0.0'),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                context.read<UserProvider>().logout();
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (_) => false);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.destructive,
                side: const BorderSide(color: AppColors.destructive),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTokens.radiusLG)),
              ),
              child: Text('退出登录',
                  style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w600, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppTokens.radiusMD),
        boxShadow: [
          BoxShadow(
            color: AppColors.clayShadowDark.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.5),
            blurRadius: 1,
            offset: const Offset(-1, -1),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTokens.radiusSM),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        title: Text(title,
            style: GoogleFonts.nunito(
                fontWeight: FontWeight.w600, color: AppColors.foreground)),
        subtitle: Text(subtitle,
            style: GoogleFonts.nunito(
                fontSize: 12, color: AppColors.mutedForeground)),
        trailing: const Icon(Icons.chevron_right_rounded,
            color: AppColors.mutedForeground),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusMD)),
        onTap: onTap,
      ),
    );
  }
}
