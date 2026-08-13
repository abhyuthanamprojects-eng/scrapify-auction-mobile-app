enum TransactionType {
  addMoney,
  emdLock,
  emdRelease,
  refund,
  payment,
  other;

  static TransactionType fromString(String? s) => switch (s) {
        'add_money' => addMoney,
        'emd_lock' => emdLock,
        'emd_release' => emdRelease,
        'refund' => refund,
        'payment' => payment,
        _ => other,
      };

  String get label => switch (this) {
        addMoney => 'Added Money',
        emdLock => 'EMD Locked',
        emdRelease => 'EMD Released',
        refund => 'Refund',
        payment => 'Payment',
        other => 'Transaction',
      };
}

class Transaction {
  final int id;
  final TransactionType type;
  final double amountInr;
  final double balanceAfterInr;
  final String? note;
  final String? method;
  final String status;
  final String? reference;
  final DateTime at;

  const Transaction({
    required this.id,
    required this.type,
    required this.amountInr,
    this.balanceAfterInr = 0,
    this.note,
    this.method,
    this.status = 'success',
    this.reference,
    required this.at,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'] as int? ?? 0,
        type: TransactionType.fromString(json['type'] as String?),
        amountInr: (json['amount_inr'] as num?)?.toDouble() ?? 0,
        balanceAfterInr:
            (json['balance_after_inr'] as num?)?.toDouble() ?? 0,
        note: json['note'] as String?,
        method: json['method'] as String?,
        status: json['status'] as String? ?? 'success',
        reference: json['reference'] as String?,
        at: DateTime.tryParse(json['at'] as String? ?? '') ?? DateTime.now(),
      );

  bool get isCredit => amountInr > 0;
  String get title => type.label;
}
