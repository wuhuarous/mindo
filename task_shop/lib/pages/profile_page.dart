import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  int _avatarIndex = 0;
  bool _showPicker = false;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _avatarIndex = prefs.getInt('avatar') ?? 0);
  }

  Future<void> _saveAvatar(int i) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('avatar', i);
    setState(() {
      _avatarIndex = i;
      _showPicker = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;

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
              border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.5)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _showPicker = !_showPicker),
                  child: Stack(
                    children: [
                      AvatarDisplay(
                          avatarIndex: _avatarIndex, size: 72),
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
                const SizedBox(height: 12),
                Text(
                  '用户 ${user?.phone.substring(0, 3) ?? ''}****${user?.phone.substring(7) ?? ''}',
                  style: GoogleFonts.fredoka(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.foreground),
                ),
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
                          fontWeight: FontWeight.w600,
                          color: AppColors.foreground)),
                  const SizedBox(height: 12),
                  AvatarPicker(
                    selectedIndex: _avatarIndex,
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
                fontWeight: FontWeight.w600,
                color: AppColors.foreground)),
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
