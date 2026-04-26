class Task {
  final String id;
  final String type;
  final String title;
  final String? contentUrl;
  final int rewardCoins;
  final String status;
  final String publisherId;
  final String? claimerId;
  final DateTime? deadline;
  final DateTime createdAt;

  const Task({
    required this.id,
    required this.type,
    required this.title,
    this.contentUrl,
    required this.rewardCoins,
    required this.status,
    required this.publisherId,
    this.claimerId,
    this.deadline,
    required this.createdAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      contentUrl: json['contentUrl'] as String?,
      rewardCoins: json['rewardCoins'] as int,
      status: json['status'] as String,
      publisherId: json['publisherId'] as String,
      claimerId: json['claimerId'] as String?,
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline'] as String) : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  bool get isExpired => deadline != null && DateTime.now().isAfter(deadline!);

  String get typeLabel {
    switch (type) {
      case 'text': return '文案';
      case 'image': return '图片';
      case 'video': return '视频';
      default: return type;
    }
  }

  String get statusLabel {
    switch (status) {
      case 'pending': return '待领取';
      case 'doing': return '进行中';
      case 'completed': return '已完成';
      case 'expired': return '已过期';
      default: return status;
    }
  }
}
