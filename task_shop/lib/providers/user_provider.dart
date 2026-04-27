import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class UserProvider extends ChangeNotifier {
  User? _user;
  bool _loading = false;

  User? get user => _user;
  bool get loading => _loading;
  bool get isLoggedIn => _user != null;

  Future<void> login(String phone, String code) async {
    _loading = true;
    notifyListeners();

    try {
      final res = await ApiService().post('/auth/login', {
        'phone': phone,
        'code': code,
      });
      if (res['success'] == true) {
        final data = res['data'] as Map<String, dynamic>;
        await ApiService().setToken(data['token'] as String);
        _user = User.fromJson(data['user'] as Map<String, dynamic>);
      } else {
        throw Exception(res['error'] ?? '登录失败');
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({String? nickname, int? avatarIndex}) async {
    final body = <String, dynamic>{};
    if (nickname != null) body['nickname'] = nickname;
    if (avatarIndex != null) body['avatarIndex'] = avatarIndex;
    if (body.isEmpty) return;

    final res = await ApiService().put('/user/profile', body);
    if (res['success'] == true) {
      _user = User.fromJson(res['data'] as Map<String, dynamic>);
      notifyListeners();
    }
  }

  void updateCoins(int newCoins) {
    if (_user == null) return;
    _user = User(id: _user!.id, phone: _user!.phone, nickname: _user!.nickname, avatarIndex: _user!.avatarIndex, coins: newCoins);
    notifyListeners();
  }

  void logout() {
    _user = null;
    ApiService().clearToken();
    notifyListeners();
  }
}
