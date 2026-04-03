enum RewardCategory { merchandise, experiences, digital, all }

enum RedemptionStatus { pending, approved, fulfilled, rejected }

class RewardModel {
  final int id;
  final String name;
  final int pointsCost;
  final String iconName;
  final String colorHex;
  final RewardCategory category;
  final int stockAvailable;
  final String? description;

  const RewardModel({
    required this.id,
    required this.name,
    required this.pointsCost,
    required this.iconName,
    required this.colorHex,
    required this.category,
    required this.stockAvailable,
    this.description,
  });

  bool get inStock => stockAvailable > 0;

  factory RewardModel.fromJson(Map<String, dynamic> json) {
    return RewardModel(
      id: json['id'] as int,
      name: json['name'] as String,
      pointsCost: json['points_cost'] as int,
      iconName: json['icon_name'] as String? ?? 'card_giftcard',
      colorHex: json['color_hex'] as String? ?? '#E53935',
      category: _parseCategory(json['category'] as String),
      stockAvailable: json['stock_available'] as int? ?? 999,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'points_cost': pointsCost,
        'icon_name': iconName,
        'color_hex': colorHex,
        'category': category.name,
        'stock_available': stockAvailable,
        'description': description,
      };

  static RewardCategory _parseCategory(String s) {
    switch (s) {
      case 'merchandise':
        return RewardCategory.merchandise;
      case 'experiences':
        return RewardCategory.experiences;
      case 'digital':
        return RewardCategory.digital;
      default:
        return RewardCategory.all;
    }
  }
}

class RedemptionModel {
  final int id;
  final int rewardId;
  final String rewardName;
  final String rewardIconName;
  final String rewardColorHex;
  final int pointsSpent;
  final RedemptionStatus status;
  final DateTime redeemedAt;

  const RedemptionModel({
    required this.id,
    required this.rewardId,
    required this.rewardName,
    required this.rewardIconName,
    required this.rewardColorHex,
    required this.pointsSpent,
    required this.status,
    required this.redeemedAt,
  });

  factory RedemptionModel.fromJson(Map<String, dynamic> json) {
    return RedemptionModel(
      id: json['id'] as int,
      rewardId: json['reward_id'] as int,
      rewardName: json['reward_name'] as String,
      rewardIconName: json['reward_icon_name'] as String? ?? 'card_giftcard',
      rewardColorHex: json['reward_color_hex'] as String? ?? '#E53935',
      pointsSpent: json['points_spent'] as int,
      status: _parseStatus(json['status'] as String),
      redeemedAt: DateTime.parse(json['redeemed_at'] as String),
    );
  }

  static RedemptionStatus _parseStatus(String s) {
    switch (s) {
      case 'approved':
        return RedemptionStatus.approved;
      case 'fulfilled':
        return RedemptionStatus.fulfilled;
      case 'rejected':
        return RedemptionStatus.rejected;
      default:
        return RedemptionStatus.pending;
    }
  }
}

class RedeemRequest {
  final int rewardId;

  const RedeemRequest({required this.rewardId});

  Map<String, dynamic> toJson() => {'reward_id': rewardId};
}

