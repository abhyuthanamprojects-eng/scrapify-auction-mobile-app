import 'package:equatable/equatable.dart';

class VendorPerformance extends Equatable {
  final int totalAuctionsParticipated;
  final int totalWins;
  final double winRatePercentage;
  final double totalAwardValueInr;
  final double onTimeFulfilmentRate;
  final double complianceScore;
  final int totalDisputes;
  final int resolvedDisputes;
  final String tierBadge; // 'Platinum' | 'Gold' | 'Silver' | 'Verified'
  final int rankInCategory;

  const VendorPerformance({
    this.totalAuctionsParticipated = 48,
    this.totalWins = 19,
    this.winRatePercentage = 39.5,
    this.totalAwardValueInr = 14850000,
    this.onTimeFulfilmentRate = 97.2,
    this.complianceScore = 98.0,
    this.totalDisputes = 2,
    this.resolvedDisputes = 2,
    this.tierBadge = 'Platinum',
    this.rankInCategory = 3,
  });

  String get tier => tierBadge;
  double get overallScore => 4.8;
  double get onTimeDeliveryPct => onTimeFulfilmentRate;
  double get paymentCompliancePct => complianceScore;
  double get disputeRatePct => (totalDisputes / (totalAuctionsParticipated > 0 ? totalAuctionsParticipated : 1) * 100).clamp(0.0, 100.0);
  int get totalOrdersCompleted => totalWins;
  double get totalTradedValueInr => totalAwardValueInr;

  factory VendorPerformance.fromJson(Map<String, dynamic> json) => VendorPerformance(
        totalAuctionsParticipated: json['total_auctions'] as int? ?? 48,
        totalWins: json['total_wins'] as int? ?? 19,
        winRatePercentage: (json['win_rate'] as num?)?.toDouble() ?? 39.5,
        totalAwardValueInr: (json['total_value_inr'] as num?)?.toDouble() ?? 14850000,
        onTimeFulfilmentRate: (json['on_time_rate'] as num?)?.toDouble() ?? 97.2,
        complianceScore: (json['compliance_score'] as num?)?.toDouble() ?? 98.0,
        totalDisputes: json['total_disputes'] as int? ?? 2,
        resolvedDisputes: json['resolved_disputes'] as int? ?? 2,
        tierBadge: json['tier_badge'] as String? ?? 'Platinum',
        rankInCategory: json['rank_in_category'] as int? ?? 3,
      );

  Map<String, dynamic> toJson() => {
        'total_auctions': totalAuctionsParticipated,
        'total_wins': totalWins,
        'win_rate': winRatePercentage,
        'total_value_inr': totalAwardValueInr,
        'on_time_rate': onTimeFulfilmentRate,
        'compliance_score': complianceScore,
        'total_disputes': totalDisputes,
        'resolved_disputes': resolvedDisputes,
        'tier_badge': tierBadge,
        'rank_in_category': rankInCategory,
      };

  @override
  List<Object?> get props => [
        totalAuctionsParticipated,
        totalWins,
        winRatePercentage,
        complianceScore,
        tierBadge,
      ];
}
