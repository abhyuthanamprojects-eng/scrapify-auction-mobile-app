import 'package:equatable/equatable.dart';

enum DisputeStatus {
  open,
  raised,
  awaitingResponse,
  underReview,
  evidenceRequested,
  resolved,
  resolvedRefund,
  rejected,
  closed;

  String get label => switch (this) {
        open || raised => 'Under Review',
        awaitingResponse => 'Awaiting Response',
        underReview => 'Under Review',
        evidenceRequested => 'Evidence Requested',
        resolved || resolvedRefund => 'Resolved (Refund Approved)',
        rejected => 'Claim Rejected',
        closed => 'Closed',
      };
}

enum DisputeCategory {
  quantityVariance,
  qualityMismatch,
  paymentDelay,
  deliveryFailure,
  complianceViolation,
  serviceDeficiency,
  other;

  String get label => switch (this) {
        quantityVariance => 'Quantity / Weight Variance',
        qualityMismatch => 'Quality / Spec Mismatch',
        paymentDelay => 'Payment / Settlement Issue',
        deliveryFailure => 'Delivery / Lifting Delay',
        complianceViolation => 'Safety & Compliance Breach',
        serviceDeficiency => 'Service Scope Deficiency',
        other => 'Other Commercial Dispute',
      };
}

class DisputeTimelineEvent extends Equatable {
  final String author;
  final String timestamp;
  final String message;

  const DisputeTimelineEvent({
    required this.author,
    required this.timestamp,
    required this.message,
  });

  factory DisputeTimelineEvent.fromJson(Map<String, dynamic> json) => DisputeTimelineEvent(
        author: json['author'] as String? ?? 'User',
        timestamp: json['timestamp'] as String? ?? '',
        message: json['message'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'author': author,
        'timestamp': timestamp,
        'message': message,
      };

  @override
  List<Object?> get props => [author, timestamp, message];
}

class DisputeMessage extends Equatable {
  final String senderName;
  final String senderRole; // 'Buyer' | 'Seller' | 'Admin'
  final String message;
  final String timestamp;
  final List<String> attachments;

  const DisputeMessage({
    required this.senderName,
    required this.senderRole,
    required this.message,
    required this.timestamp,
    this.attachments = const [],
  });

  factory DisputeMessage.fromJson(Map<String, dynamic> json) => DisputeMessage(
        senderName: json['sender_name'] as String? ?? 'User',
        senderRole: json['sender_role'] as String? ?? 'Bidder',
        message: json['message'] as String? ?? '',
        timestamp: json['timestamp'] as String? ?? '',
        attachments: (json['attachments'] as List?)?.cast<String>() ?? [],
      );

  Map<String, dynamic> toJson() => {
        'sender_name': senderName,
        'sender_role': senderRole,
        'message': message,
        'timestamp': timestamp,
        'attachments': attachments,
      };

  @override
  List<Object?> get props => [senderName, timestamp, message];
}

class DisputeItem extends Equatable {
  final String id;
  final String auctionCode;
  final String auctionTitle;
  final String orderNumber;
  final String? orderId;
  final String? disputeId;
  final String? title;
  final double? claimedAmountInr;
  final dynamic category;
  final String description;
  final DisputeStatus status;
  final String? raisedAt;
  final String? createdDate;
  final String? resolvedAt;
  final String? resolutionSummary;
  final List<DisputeMessage> messages;
  final List<DisputeTimelineEvent> timeline;
  final List<String> evidenceUrls;
  final List<String> evidencePhotos;

  const DisputeItem({
    required this.id,
    this.disputeId,
    this.auctionCode = '',
    this.auctionTitle = '',
    this.orderNumber = '',
    this.orderId,
    this.title,
    this.claimedAmountInr = 45000,
    this.category,
    required this.description,
    this.status = DisputeStatus.raised,
    this.raisedAt,
    this.createdDate,
    this.resolvedAt,
    this.resolutionSummary,
    this.messages = const [],
    this.timeline = const [],
    this.evidenceUrls = const [],
    this.evidencePhotos = const [],
  });

  factory DisputeItem.fromJson(Map<String, dynamic> json) => DisputeItem(
        id: json['id'] as String? ?? 'DSP-${DateTime.now().millisecondsSinceEpoch}',
        auctionCode: json['auction_code'] as String? ?? '',
        auctionTitle: json['auction_title'] as String? ?? '',
        orderNumber: json['order_number'] as String? ?? '',
        description: json['description'] as String? ?? '',
        status: DisputeStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => DisputeStatus.open,
        ),
        raisedAt: json['raised_at'] as String? ?? '',
        resolvedAt: json['resolved_at'] as String?,
        resolutionSummary: json['resolution_summary'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'auction_code': auctionCode,
        'auction_title': auctionTitle,
        'order_number': orderNumber,
        'description': description,
        'status': status.name,
        'raised_at': raisedAt,
        'resolved_at': resolvedAt,
        'resolution_summary': resolutionSummary,
      };

  @override
  List<Object?> get props => [id, auctionCode, status, category];
}
