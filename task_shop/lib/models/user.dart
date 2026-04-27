class User {
  final String id;
  final String phone;
  final String? nickname;
  final int avatarIndex;
  final int coins;

  const User({
    required this.id,
    required this.phone,
    this.nickname,
    this.avatarIndex = 0,
    required this.coins,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      phone: json['phone'] as String,
      nickname: json['nickname'] as String?,
      avatarIndex: (json['avatarIndex'] as int?) ?? 0,
      coins: (json['coins'] as int?) ?? 0,
    );
  }

  String get displayName => nickname ?? '用户 ${phone.substring(0, 3)}****${phone.substring(7)}';
}
