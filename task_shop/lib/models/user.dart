class User {
  final String id;
  final String phone;
  final int coins;

  const User({required this.id, required this.phone, required this.coins});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      phone: json['phone'] as String,
      coins: json['coins'] as int,
    );
  }
}
