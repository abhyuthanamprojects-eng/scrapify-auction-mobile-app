class WalletBalance {
  final double balanceInr;
  final double lockedInr;
  final double availableInr;
  final String currency;

  const WalletBalance({
    this.balanceInr = 0,
    this.lockedInr = 0,
    this.availableInr = 0,
    this.currency = 'INR',
  });

  factory WalletBalance.fromJson(Map<String, dynamic> json) => WalletBalance(
        balanceInr: (json['balance_inr'] as num?)?.toDouble() ?? 0,
        lockedInr: (json['locked_inr'] as num?)?.toDouble() ?? 0,
        availableInr: (json['available_inr'] as num?)?.toDouble() ?? 0,
        currency: json['currency'] as String? ?? 'INR',
      );
}
