class MyBid {
  final String auctionId;
  final String title;
  final String status;
  final double myBidInr;
  final double currentInr;
  final int bidCount;
  final String result;

  const MyBid({
    required this.auctionId,
    required this.title,
    required this.status,
    required this.myBidInr,
    required this.currentInr,
    required this.bidCount,
    required this.result,
  });

  factory MyBid.fromJson(Map<String, dynamic> json) => MyBid(
        auctionId: json['auction_id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        status: json['status'] as String? ?? '',
        myBidInr: (json['my_bid_inr'] as num?)?.toDouble() ?? 0,
        currentInr: (json['current_inr'] as num?)?.toDouble() ?? 0,
        bidCount: json['bid_count'] as int? ?? 0,
        result: json['result'] as String? ?? '',
      );

  bool get isWinning => result == 'Winning' || result == 'Won';
}
