import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';
import '../config/constants.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  bool _codeSent = false;
  bool _agreed = true; // 默认勾选
  late final AnimationController _animController;
  late final Animation<double> _fadeSlide;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeSlide = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final phone = _phoneController.text;
    if (phone.length != 11) return;
    final res = await ApiService().post('/auth/send-code', {'phone': phone});
    if (res['success'] == true) {
      setState(() => _codeSent = true);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('验证码已发送')));
      }
    }
  }

  Future<void> _login({String? phone}) async {
    final p = phone ?? _phoneController.text;
    if (p.length != 11) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('请输入有效的11位手机号')));
      }
      return;
    }

    final userProvider = context.read<UserProvider>();
    await userProvider.login(p, _codeController.text.isEmpty ? '000000' : _codeController.text);
    if (mounted && userProvider.isLoggedIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    }
  }

  bool _quickLoading = false;

  // 一键登录：自动生成手机号直接进入
  Future<void> _quickLogin() async {
    setState(() => _quickLoading = true);
    final ts = DateTime.now().millisecondsSinceEpoch.toString();
    final randomPhone = '138${ts.substring(ts.length - 8)}';
    _phoneController.text = randomPhone;
    await _login(phone: randomPhone);
    if (mounted) setState(() => _quickLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
            child: FadeTransition(
              opacity: _fadeSlide,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.05),
                  end: Offset.zero,
                ).animate(_fadeSlide),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      const Spacer(flex: 2),

                      // 顶部装饰区
                      _buildHeader(),

                      const Spacer(flex: 1),

                      // 输入区
                      _buildPhoneInput(),
                      const SizedBox(height: 14),
                      _buildCodeRow(),

                      const SizedBox(height: 28),

                      // 登录按钮
                      Consumer<UserProvider>(
                        builder: (context, provider, _) {
                          return _buildButton(
                            onPressed: provider.loading ? null : () => _login(),
                            isLoading: provider.loading,
                            label: '登 录',
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // 一键体验
                      Row(
                        children: [
                          const Expanded(child: Divider(color: AppColors.border)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text('或',
                                style: GoogleFonts.nunito(
                                    color: AppColors.mutedForeground,
                                    fontSize: 13)),
                          ),
                          const Expanded(child: Divider(color: AppColors.border)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      GestureDetector(
                        onTap: _quickLoading ? null : _quickLogin,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius:
                                BorderRadius.circular(AppTokens.radiusLG),
                            border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.4)),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: _quickLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: AppColors.primary))
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.rocket_launch_rounded,
                                        color: AppColors.primary, size: 22),
                                    const SizedBox(width: 10),
                                    Text('一键体验',
                                        style: GoogleFonts.nunito(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16)),
                                  ],
                                ),
                        ),
                      ),

                      // 协议
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => setState(() => _agreed = !_agreed),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _agreed
                                  ? Icons.check_circle_rounded
                                  : Icons.circle_outlined,
                              size: 18,
                              color: _agreed
                                  ? AppColors.primary
                                  : AppColors.mutedForeground,
                            ),
                            const SizedBox(width: 6),
                            Text.rich(
                              TextSpan(
                                text: '登录即表示同意 ',
                                style: GoogleFonts.nunito(
                                    color: AppColors.mutedForeground,
                                    fontSize: 12),
                                children: [
                                  TextSpan(
                                      text: '用户协议',
                                      style: GoogleFonts.nunito(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600)),
                                  const TextSpan(text: ' 和 '),
                                  TextSpan(
                                      text: '隐私政策',
                                      style: GoogleFonts.nunito(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(flex: 2),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppTokens.radius2XL),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.3),
                blurRadius: 2,
                offset: const Offset(-2, -2),
              ),
            ],
          ),
          child: const Icon(Icons.timer_rounded, size: 48, color: Colors.white),
        ),
        const SizedBox(height: 24),
        Text('一分钟差事铺',
            style: GoogleFonts.fredoka(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: AppColors.foreground,
                letterSpacing: -0.5)),
        const SizedBox(height: 8),
        Text('抽盲盒 · 做任务 · 赚金币',
            style: GoogleFonts.nunito(
                color: AppColors.mutedForeground,
                fontSize: 15,
                letterSpacing: 1)),
        // 装饰小点
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _dot(AppColors.textTask),
            const SizedBox(width: 8),
            _dot(AppColors.imageTask),
            const SizedBox(width: 8),
            _dot(AppColors.videoTask),
          ],
        ),
      ],
    );
  }

  Widget _dot(Color c) => Container(
      width: 8, height: 8,
      decoration: BoxDecoration(color: c.withValues(alpha: 0.4), shape: BoxShape.circle));

  Widget _buildPhoneInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppTokens.radiusMD),
        boxShadow: [
          BoxShadow(
            color: AppColors.clayShadowDark.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.7),
            blurRadius: 1,
            offset: const Offset(-1, -1),
          ),
        ],
      ),
      child: TextField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        style: GoogleFonts.nunito(fontSize: 16, color: AppColors.foreground),
        decoration: InputDecoration(
          hintText: '输入手机号',
          hintStyle: GoogleFonts.nunito(
              color: AppColors.mutedForeground.withValues(alpha: 0.5)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 20, vertical: 18),
          prefixIcon: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTokens.radiusSM),
            ),
            child: const Icon(Icons.phone_rounded,
                color: AppColors.primary, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildCodeRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppTokens.radiusMD),
              boxShadow: [
                BoxShadow(
                  color: AppColors.clayShadowDark.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.7),
                  blurRadius: 1,
                  offset: const Offset(-1, -1),
                ),
              ],
            ),
            child: TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.nunito(fontSize: 16, color: AppColors.foreground),
              decoration: InputDecoration(
                hintText: '验证码',
                hintStyle: GoogleFonts.nunito(
                    color: AppColors.mutedForeground.withValues(alpha: 0.5)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 18),
                prefixIcon: Container(
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTokens.radiusSM),
                  ),
                  child: const Icon(Icons.lock_rounded,
                      color: AppColors.accent, size: 20),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTokens.radiusMD),
            boxShadow: const [AppTokens.shadowSM],
          ),
          child: ElevatedButton(
            onPressed: _sendCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTokens.radiusMD),
              ),
            ),
            child: Text(_codeSent ? '重新发送' : '获取验证码',
                style: GoogleFonts.nunito(
                    fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _buildButton({
    required VoidCallback? onPressed,
    required bool isLoading,
    required String label,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTokens.radiusLG),
          boxShadow: isLoading ? null : [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTokens.radiusLG)),
            elevation: 0,
          ),
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Colors.white))
              : Text(label,
                  style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 4)),
        ),
      ),
    );
  }
}
