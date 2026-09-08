import 'package:equatable/equatable.dart';

enum TeamRole {
  vendorAdmin,
  authorizedBidder,
  fieldInspector,
  financeApprover;

  String get label => switch (this) {
    vendorAdmin => 'Administrator',
    authorizedBidder => 'Authorized Bidder',
    fieldInspector => 'Field / Logistics Officer',
    financeApprover => 'Viewer / Observer',
  };
}

class TeamMember extends Equatable {
  final String id;
  final String name;
  final String email;
  final String mobile;
  final TeamRole role;
  final double maxBiddingLimitInr;
  final bool isActive;
  final String joinedAt;
  final List<String> allowedCategories;

  const TeamMember({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.role,
    this.maxBiddingLimitInr = 0,
    this.isActive = true,
    this.joinedAt = '',
    this.allowedCategories = const [],
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) => TeamMember(
    id: json['id'] as String? ?? 'TM-${DateTime.now().millisecondsSinceEpoch}',
    name: json['name'] as String? ?? '',
    email: json['email'] as String? ?? '',
    mobile: json['mobile'] as String? ?? '',
    role: TeamRole.values.firstWhere(
      (r) => r.name == json['role'],
      orElse: () => TeamRole.authorizedBidder,
    ),
    maxBiddingLimitInr:
        (json['max_bidding_limit_inr'] as num?)?.toDouble() ?? 0,
    isActive: json['is_active'] as bool? ?? true,
    joinedAt: json['joined_at'] as String? ?? '',
    allowedCategories:
        (json['allowed_categories'] as List?)?.cast<String>() ?? const [],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'mobile': mobile,
    'role': role.name,
    'max_bidding_limit_inr': maxBiddingLimitInr,
    'is_active': isActive,
    'joined_at': joinedAt,
    'allowed_categories': allowedCategories,
  };

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    role,
    isActive,
    maxBiddingLimitInr,
  ];
}
