import 'package:equatable/equatable.dart';

class Lot extends Equatable {
  final String code;
  final String? auctionId;
  final String name;
  final String? quantity;
  final String? uom;
  final double reservePriceInr;
  final double currentBidInr;
  final int bidders;
  final String status;
  final double? finalPriceInr;

  const Lot({
    required this.code,
    this.auctionId,
    required this.name,
    this.quantity,
    this.uom,
    this.reservePriceInr = 0,
    this.currentBidInr = 0,
    this.bidders = 0,
    this.status = 'open',
    this.finalPriceInr,
  });

  factory Lot.fromJson(Map<String, dynamic> json) => Lot(
        code: json['code'] as String? ?? json['id'] as String? ?? '',
        auctionId: json['auction_id'] as String?,
        name: json['name'] as String? ?? '',
        quantity: json['quantity'] as String?,
        uom: json['uom'] as String?,
        reservePriceInr: (json['reserve_price_inr'] as num?)?.toDouble() ?? 0,
        currentBidInr: (json['current_bid_inr'] as num?)?.toDouble() ?? 0,
        bidders: json['bidders'] as int? ?? 0,
        status: json['status'] as String? ?? 'open',
        finalPriceInr: (json['final_price_inr'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'quantity': quantity,
        'uom': uom,
        'reserve_price': reservePriceInr,
      };

  @override
  List<Object?> get props => [code];
}
