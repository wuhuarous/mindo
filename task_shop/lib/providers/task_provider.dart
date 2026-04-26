import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  Task? _currentTask;
  bool _loading = false;
  String _activeRole = 'claimer';

  List<Task> get tasks => _tasks;
  Task? get currentTask => _currentTask;
  bool get loading => _loading;
  String get activeRole => _activeRole;

  void setRole(String role) {
    _activeRole = role;
    notifyListeners();
  }

  Future<void> loadMyTasks() async {
    _loading = true;
    notifyListeners();

    try {
      final res = await ApiService().get('/tasks/mine?role=$_activeRole');
      if (res['success'] == true) {
        _tasks = (res['data'] as List)
            .map((j) => Task.fromJson(j as Map<String, dynamic>))
            .toList();
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<Task?> drawTask() async {
    final res = await ApiService().post('/tasks/draw', {});
    if (res['success'] == true && res['data'] != null) {
      final task = Task.fromJson(res['data'] as Map<String, dynamic>);
      _currentTask = task;
      notifyListeners();
      return task;
    }
    return null;
  }

  Future<bool> submitTask(String taskId, String contentUrl) async {
    final res = await ApiService().post('/tasks/submit', {
      'taskId': taskId,
      'contentUrl': contentUrl,
    });
    if (res['success'] == true) {
      await loadMyTasks();
      return true;
    }
    throw Exception(res['error'] ?? '提交失败');
  }

  Future<bool> publishTask({
    required String type,
    required String title,
    String? contentUrl,
    required int rewardCoins,
  }) async {
    final res = await ApiService().post('/tasks/publish', {
      'type': type,
      'title': title,
      'contentUrl': contentUrl,
      'rewardCoins': rewardCoins,
    });
    if (res['success'] == true) {
      await loadMyTasks();
      return true;
    }
    throw Exception(res['error'] ?? '发布失败');
  }

  void clearCurrentTask() {
    _currentTask = null;
    notifyListeners();
  }
}
