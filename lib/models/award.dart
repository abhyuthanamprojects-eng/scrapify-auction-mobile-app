import 'package:equatable/equatable.dart';

enum AwardStatus {
  pendingApproval,
  offered,
  accepted,
  declined,
  defaulted,
  fallbackOffered,
  completed,
  cancelled,
  expired;

  static AwardStatus fromString(String? s) => switch (s?.toLowerCase()) {
        'pending_approval' => pendingApproval,
        'offered' => offered,
        'accepted' => accepted,
        'declined' => declined,
        'defaulted' => defaulted,
        'fallback_offered' => fallbackOffered,
        'completed' => completed,
        'cancelled' => cancelled,
        'expired' => expired,
        _ => offered,
      };

  String get label => switch (this) {
        pendingApproval => 'Pending Approval',
        offered => 'Offered',
        accepted => 'Accepted',
        declined => 'Declined',
        defaulted => 'Defaulted',
        fallbackOffered => 'Fallback Offer',
        completed => 'Completed',
        cancelled => 'Cancelled',
        expired => 'Expired',
      };
}

class Award extends Equatable {
  final String id;
  final String auctionCode;
  final String auctionTitle;
  final String company;
  final String category;
  final double awardValueInr;
  final double emdAdjustedInr;
  final double netPayableInr;
  final AwardStatus status;
  final String acceptanceDeadline;
  final String awardedAt;
  final String? acceptedAt;
  final String? declinedReason;
  final bool isFallback;
  final String? fallbackOriginalBidder;
  final String poNumber;
  final String? contractUrl;

  const Award({
    required this.id,
    required this.auctionCode,
    required this.auctionTitle,
    required this.company,
    required this.category,
    required this.awardValueInr,
    this.emdAdjustedInr = 0,
    required this.netPayableInr,
    this.status = AwardStatus.offered,
    required this.acceptanceDeadline,
    required this.awardedAt,
    this.acceptedAt,
    this.declinedReason,
    this.isFallback = false,
    this.fallbackOriginalBidder,
    required this.poNumber,
    this.contractUrl,
  });

  double get amountInr => awardValueInr;
  double get balanceDueInr => netPayableInr;
  String get sellerCompany => company;
  double get adjustedEmdInr => emdAdjustedInr;
  double get gstAmountInr => awardValueInr * 0.18;
  String get issuedDate => awardedAt;

  factory Award.fromJson(Map<String, dynamic> json) => Award(
        id: json['id'] as String? ?? '',
        auctionCode: json['auction_code'] as String? ?? '',
        auctionTitle: json['auction_title'] as String? ?? '',
        company: json['company'] as String? ?? '',
        category: json['category'] as String? ?? '',
        awardValueInr: (json['award_value_inr'] as num?)?.toDouble() ?? 0,
        emdAdjustedInr: (json['emd_adjusted_inr'] as num?)?.toDouble() ?? 0,
        netPayableInr: (json['net_payable_inr'] as num?)?.toDouble() ?? 0,
        status: AwardStatus.fromString(json['status'] as String?),
        acceptanceDeadline: json['acceptance_deadline'] as String? ?? '',
        awardedAt: json['awarded_at'] as String? ?? '',
        acceptedAt: json['accepted_at'] as String?,
        declinedReason: json['declined_reason'] as String?,
        isFallback: json['is_fallback'] as bool? ?? false,
        fallbackOriginalBidder: json['fallback_original_bidder'] as String?,
        poNumber: json['po_number'] as String? ?? 'PO-2026-000',
        contractUrl: json['contract_url'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'auction_code': auctionCode,
        'auction_title': auctionTitle,
        'company': company,
        'category': category,
        'award_value_inr': awardValueInr,
        'emd_adjusted_inr': emdAdjustedInr,
        'net_payable_inr': netPayableInr,
        'status': status.name,
        'acceptance_deadline': acceptanceDeadline,
        'awarded_at': awardedAt,
        'accepted_at': acceptedAt,
        'declined_reason': declinedReason,
        'is_fallback': isFallback,
        'fallback_original_bidder': fallbackOriginalBidder,
        'po_number': poNumber,
        'contract_url': contractUrl,
      };

  Award copyWith({AwardStatus? status, String? acceptedAt, String? declinedReason}) => Award(
        id: id,
        auctionCode: auctionCode,
        auctionTitle: auctionTitle,
        company: company,
        category: category,
        awardValueInr: awardValueInr,
        emdAdjustedInr: emdAdjustedInr,
        netPayableInr: netPayableInr,
        status: status ?? this.status,
        acceptanceDeadline: acceptanceDeadline,
        awardedAt: awardedAt,
        acceptedAt: acceptedAt ?? this.acceptedAt,
        declinedReason: declinedReason ?? this.declinedReason,
        isFallback: isFallback,
        fallbackOriginalBidder: fallbackOriginalBidder,
        poNumber: poNumber,
        contractUrl: contractUrl,
      );

  @override
  List<Object?> get props => [id, auctionCode, awardValueInr, status, isFallback];
}
