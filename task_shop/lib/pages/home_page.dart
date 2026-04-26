import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/coin_display.dart';
import '../config/constants.dart';
import 'draw_page.dart';
import 'publish_page.dart';
import 'profile_page.dart';
import 'task_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadMyTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('一分钟差事铺'),
        actions: [
          Consumer<UserProvider>(
            builder: (context, userProvider, _) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CoinDisplay(coins: userProvider.user?.coins ?? 0),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_rounded),
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const ProfilePage())),
          ),
        ],
      ),
      body: Column(
        children: [
          // Bento action cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _ActionCard(
                    icon: Icons.card_giftcard_rounded,
                    label: '抽盲盒',
                    subtitle: '领取随机任务',
                    gradientColors: const [Color(0xFFFF7B00), Color(0xFFFF9D45)],
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const DrawPage())),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _ActionCard(
                    icon: Icons.add_circle_rounded,
                    label: '发布任务',
                    subtitle: '赚取虚拟币',
                    gradientColors: const [AppColors.accent, Color(0xFF3B82F6)],
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const PublishPage())),
                  ),
                ),
              ],
            ),
          ),
          // Role tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Consumer<TaskProvider>(
              builder: (context, provider, _) {
                return Row(
                  children: [
                    _RoleChip(
                      label: '我领取的',
                      active: provider.activeRole == 'claimer',
                      onTap: () {
                        provider.setRole('claimer');
                        provider.loadMyTasks();
                      },
                    ),
                    const SizedBox(width: 8),
                    _RoleChip(
                      label: '我发布的',
                      active: provider.activeRole == 'publisher',
                      onTap: () {
                        provider.setRole('publisher');
                        provider.loadMyTasks();
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          // Task list
          Expanded(
            child: Consumer<TaskProvider>(
              builder: (context, provider, _) {
                if (provider.loading) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary));
                }
                if (provider.tasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox_rounded,
                            size: 64, color: AppColors.border),
                        const SizedBox(height: 12),
                        Text('暂无任务',
                            style: GoogleFonts.nunito(
                                color: AppColors.mutedForeground,
                                fontSize: 16)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: provider.tasks.length,
                  itemBuilder: (_, i) => TaskCard(
                    task: provider.tasks[i],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => TaskDetailPage(task: provider.tasks[i])),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppTokens.radiusXL),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.2),
              blurRadius: 2,
              offset: const Offset(-1, -1),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: Colors.white),
            const SizedBox(height: 10),
            Text(label,
                style: GoogleFonts.fredoka(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(subtitle,
                style: GoogleFonts.nunito(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _RoleChip({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppTokens.durationFast,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.muted,
          borderRadius: BorderRadius.circular(AppTokens.radiusSM),
          boxShadow: active ? const [AppTokens.shadowSM] : null,
        ),
        child: Text(label,
            style: GoogleFonts.nunito(
                color: active ? Colors.white : AppColors.mutedForeground,
                fontWeight: FontWeight.w600,
                fontSize: 14)),
      ),
    );
  }
}
