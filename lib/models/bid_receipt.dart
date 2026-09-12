import 'package:equatable/equatable.dart';

class BidReceipt extends Equatable {
  final String receiptId;
  final String auctionCode;
  final String auctionTitle;
  final String lotNumber;
  final double amountInr;
  final int rankAtSubmission;
  final String timestamp;
  final String status; // 'accepted' | 'rejected' | 'leading' | 'beaten'
  final String? rejectionReason;
  final String clientIp;
  final String signatureHash;
  final String deviceId;

  const BidReceipt({
    required this.receiptId,
    required this.auctionCode,
    required this.auctionTitle,
    this.lotNumber = 'Lot 01',
    required this.amountInr,
    this.rankAtSubmission = 1,
    required this.timestamp,
    this.status = 'accepted',
    this.rejectionReason,
    this.clientIp = '',
    this.signatureHash = '',
    this.deviceId = '',
    double? bidAmountInr,
    String? cryptographicSignature,
    String? ipAddress,
  });

  double get bidAmountInr => amountInr;
  String get cryptographicSignature => signatureHash;
  String get ipAddress => clientIp;

  factory BidReceipt.fromJson(Map<String, dynamic> json) => BidReceipt(
        receiptId: json['receipt_id'] as String? ?? '',
        auctionCode: json['auction_code'] as String? ?? '',
        auctionTitle: json['auction_title'] as String? ?? '',
        lotNumber: json['lot_number'] as String? ?? 'Lot 01',
        amountInr: (json['amount_inr'] as num?)?.toDouble() ?? 0,
        rankAtSubmission: json['rank_at_submission'] as int? ?? 1,
        timestamp: json['timestamp'] as String? ?? DateTime.now().toIso8601String(),
        status: json['status'] as String? ?? 'accepted',
        rejectionReason: json['rejection_reason'] as String?,
        clientIp: json['client_ip'] as String? ?? '',
        signatureHash: json['signature_hash'] as String? ?? '',
        deviceId: json['device_id'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'receipt_id': receiptId,
        'auction_code': auctionCode,
        'auction_title': auctionTitle,
        'lot_number': lotNumber,
        'amount_inr': amountInr,
        'rank_at_submission': rankAtSubmission,
        'timestamp': timestamp,
        'status': status,
        'rejection_reason': rejectionReason,
        'client_ip': clientIp,
        'signature_hash': signatureHash,
        'device_id': deviceId,
      };

  @override
  List<Object?> get props => [receiptId, auctionCode, amountInr, timestamp, status];
}
