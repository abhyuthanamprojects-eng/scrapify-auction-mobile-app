class Order {
  final String code;
  final String auctionId;
  final String? lotId;
  final String title;
  final String vendorId;
  final double winningAmountInr;
  final double emdAppliedInr;
  final double gstAmountInr;
  final double tcsAmountInr;
  final double totalAmountInr;
  final double balanceDueInr;
  final String status;
  final String? paymentDueAt;
  final String? paidAt;
  final String? handoverOtp;
  final OrderPickup? pickup;
  final OrderWeighbridge? weighbridge;
  final List<OrderDocument> documents;

  const Order({
    required this.code,
    required this.auctionId,
    this.lotId,
    required this.title,
    required this.vendorId,
    this.winningAmountInr = 0,
    this.emdAppliedInr = 0,
    this.gstAmountInr = 0,
    this.tcsAmountInr = 0,
    this.totalAmountInr = 0,
    this.balanceDueInr = 0,
    this.status = 'awaiting_payment',
    this.paymentDueAt,
    this.paidAt,
    this.handoverOtp,
    this.pickup,
    this.weighbridge,
    this.documents = const [],
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        code: json['id'] as String? ?? json['code'] as String? ?? '',
        auctionId: json['auction_id'] as String? ?? '',
        lotId: json['lot_id'] as String?,
        title: json['title'] as String? ?? '',
        vendorId: json['vendor_id'] as String? ?? '',
        winningAmountInr:
            (json['winning_amount_inr'] as num?)?.toDouble() ?? 0,
        emdAppliedInr: (json['emd_applied_inr'] as num?)?.toDouble() ?? 0,
        gstAmountInr: (json['gst_amount_inr'] as num?)?.toDouble() ?? 0,
        tcsAmountInr: (json['tcs_amount_inr'] as num?)?.toDouble() ?? 0,
        totalAmountInr: (json['total_amount_inr'] as num?)?.toDouble() ?? 0,
        balanceDueInr: (json['balance_due_inr'] as num?)?.toDouble() ?? 0,
        status: json['status'] as String? ?? 'awaiting_payment',
        paymentDueAt: json['payment_due_at'] as String?,
        paidAt: json['paid_at'] as String?,
        handoverOtp: json['handover_otp'] as String?,
        pickup: json['pickup'] != null
            ? OrderPickup.fromJson(json['pickup'] as Map<String, dynamic>)
            : null,
        weighbridge: json['weighbridge'] != null
            ? OrderWeighbridge.fromJson(
                json['weighbridge'] as Map<String, dynamic>)
            : null,
        documents: (json['documents'] as List?)
                ?.map((e) =>
                    OrderDocument.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  bool get isPaid => status == 'paid' || status == 'pickup_scheduled' || status == 'picked_up';
}

class OrderPickup {
  final String? windowStart;
  final String? windowEnd;
  final String? warehouse;
  final String status;

  const OrderPickup({
    this.windowStart,
    this.windowEnd,
    this.warehouse,
    this.status = 'scheduled',
  });

  factory OrderPickup.fromJson(Map<String, dynamic> json) => OrderPickup(
        windowStart: json['window_start'] as String?,
        windowEnd: json['window_end'] as String?,
        warehouse: json['warehouse'] as String?,
        status: json['status'] as String? ?? 'scheduled',
      );
}

class OrderWeighbridge {
  final double declaredKg;
  final double actualKg;
  final double adjustmentInr;

  const OrderWeighbridge({
    this.declaredKg = 0,
    this.actualKg = 0,
    this.adjustmentInr = 0,
  });

  factory OrderWeighbridge.fromJson(Map<String, dynamic> json) =>
      OrderWeighbridge(
        declaredKg: (json['declared_kg'] as num?)?.toDouble() ?? 0,
        actualKg: (json['actual_kg'] as num?)?.toDouble() ?? 0,
        adjustmentInr: (json['adjustment_inr'] as num?)?.toDouble() ?? 0,
      );
}

class OrderDocument {
  final String type;
  final String fileName;

  const OrderDocument({required this.type, required this.fileName});

  factory OrderDocument.fromJson(Map<String, dynamic> json) => OrderDocument(
        type: json['type'] as String? ?? '',
        fileName: json['file_name'] as String? ?? '',
      );
}
