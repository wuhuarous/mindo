import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../widgets/blind_box_card.dart';
import '../config/constants.dart';
import 'task_execute_page.dart';

class DrawPage extends StatefulWidget {
  const DrawPage({super.key});

  @override
  State<DrawPage> createState() => _DrawPageState();
}

class _DrawPageState extends State<DrawPage> {
  Task? _drawnTask;
  bool _isDrawing = false;
  int _skipCount = 3;

  Future<void> _draw() async {
    setState(() => _isDrawing = true);
    final task = await context.read<TaskProvider>().drawTask();
    if (task != null) {
      setState(() => _drawnTask = task);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('暂无可用任务')));
      }
    }
    setState(() => _isDrawing = false);
  }

  void _goExecute() {
    if (_drawnTask != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => TaskExecutePage(task: _drawnTask!)),
      );
    }
  }

  void _skip() {
    if (_skipCount > 0) {
      setState(() {
        _skipCount--;
        _drawnTask = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('抽盲盒')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('今日可跳过次数',
                style: GoogleFonts.nunito(
                    color: AppColors.mutedForeground)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTokens.radiusSM),
              ),
              child: Text('$_skipCount / 3',
                  style: GoogleFonts.fredoka(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary)),
            ),
            const SizedBox(height: 40),
            BlindBoxCard(
              isOpened: _drawnTask != null,
              taskType: _drawnTask?.type,
              taskTitle: _drawnTask?.title,
              contentUrl: _drawnTask?.contentUrl,
              rewardCoins: _drawnTask?.rewardCoins,
              onTap: _isDrawing ? null : _draw,
            ),
            const SizedBox(height: 24),
            if (_isDrawing)
              const CircularProgressIndicator(color: AppColors.primary),
            if (_drawnTask != null) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: 220,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(AppTokens.radiusLG),
                    boxShadow: const [AppTokens.shadowMD],
                  ),
                  child: ElevatedButton(
                    onPressed: _goExecute,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(220, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTokens.radiusLG),
                      ),
                    ),
                    child: Text('开始执行',
                        style: GoogleFonts.nunito(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (_skipCount > 0)
                TextButton(
                  onPressed: _skip,
                  child: Text('跳过此任务（剩余 $_skipCount 次）',
                      style: GoogleFonts.nunito(
                          color: AppColors.mutedForeground)),
                ),
            ],
            if (_drawnTask == null && !_isDrawing)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('点击上方盲盒抽取任务',
                    style: GoogleFonts.nunito(
                        color: AppColors.mutedForeground)),
              ),
          ],
        ),
      ),
    );
  }
}
