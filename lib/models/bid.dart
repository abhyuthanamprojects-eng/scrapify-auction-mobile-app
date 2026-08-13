class Bid {
  final int id;
  final String auctionId;
  final String? subLotId;
  final String vendorId;
  final String vendorName;
  final double amountInr;
  final bool isProxy;
  final DateTime at;

  const Bid({
    required this.id,
    required this.auctionId,
    this.subLotId,
    required this.vendorId,
    required this.vendorName,
    required this.amountInr,
    this.isProxy = false,
    required this.at,
  });

  factory Bid.fromJson(Map<String, dynamic> json) => Bid(
        id: json['id'] as int? ?? 0,
        auctionId: json['auction_id']?.toString() ?? '',
        subLotId: json['sub_lot_id'] as String?,
        vendorId: json['vendor_id']?.toString() ?? '',
        vendorName: json['vendor_name'] as String? ?? '',
        amountInr: (json['amount_inr'] as num?)?.toDouble() ?? 0,
        isProxy: json['is_proxy'] as bool? ?? false,
        at: DateTime.tryParse(json['at'] as String? ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'auction_id': auctionId,
        'sub_lot_id': subLotId,
        'vendor_id': vendorId,
        'vendor_name': vendorName,
        'amount_inr': amountInr,
        'is_proxy': isProxy,
        'at': at.toIso8601String(),
      };

  factory Bid.fromBroadcast(Map<String, dynamic> json) => Bid(
        id: json['id'] as int? ?? 0,
        auctionId: json['auction_code'] as String? ?? '',
        subLotId: json['lot_code'] as String?,
        vendorId: json['vendor_id']?.toString() ?? '',
        vendorName: json['vendor_name'] as String? ?? '',
        amountInr: (json['amount'] as num?)?.toDouble() ?? 0,
        isProxy: json['is_proxy'] as bool? ?? false,
        at: DateTime.tryParse(json['at'] as String? ?? '') ?? DateTime.now(),
      );
}
