import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/domain_providers.dart';
import '../../models/award.dart';
import '../../models/transaction.dart';

class PaymentsDashboardScreen extends ConsumerStatefulWidget {
  const PaymentsDashboardScreen({super.key});

  @override
  ConsumerState<PaymentsDashboardScreen> createState() =>
      _PaymentsDashboardScreenState();
}

class _PaymentsDashboardScreenState
    extends ConsumerState<PaymentsDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openPayModal(BuildContext context, Award award) {
    String method = 'wallet';
    final utrCtl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Settle Balance Invoice',
                    style: AppTextStyles.heading(
                      size: 17,
                      weight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    Formatters.formatINR(award.balanceDueInr),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.destructive,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Invoice: ${award.id} • ${award.sellerCompany}',
                style: AppTextStyles.captionMuted,
              ),
              const SizedBox(height: 16),

              // Payment Method Options
              _payOption(
                'Scrapify EMD Wallet',
                'Instant settlement using linked funds',
                Icons.account_balance_wallet_outlined,
                'wallet',
                method,
                () => setModalState(() => method = 'wallet'),
              ),
              _payOption(
                'UPI / QR Code',
                'Instant clearance via GPay, PhonePe, Paytm',
                Icons.qr_code_2,
                'upi',
                method,
                () => setModalState(() => method = 'upi'),
              ),
              _payOption(
                'NEFT / RTGS / Corporate NetBanking',
                'Direct escrow transfer with UTR proof upload',
                Icons.account_balance_outlined,
                'neft',
                method,
                () => setModalState(() => method = 'neft'),
              ),

              if (method == 'neft') ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.appBg,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'VIRTUAL ESCROW ACCOUNT DETAILS',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Escrow account instructions are supplied by the payment API for the selected award.',
                        style: TextStyle(fontSize: 11.5, color: AppColors.navy),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: utrCtl,
                  decoration: const InputDecoration(
                    labelText: 'Bank Reference UTR / Transaction No',
                    hintText: 'e.g. HDFC0001928374',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],

              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Payment processing is unavailable until the settlement API is enabled.',
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.auction,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                    ),
                  ),
                  child: Text(
                    'Pay ${Formatters.formatINR(award.balanceDueInr)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _payOption(
    String title,
    String desc,
    IconData icon,
    String val,
    String selected,
    VoidCallback onTap,
  ) {
    final isSel = val == selected;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSel
              ? AppColors.navy.withValues(alpha: 0.04)
              : AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: isSel ? AppColors.navy : AppColors.cardBorder,
            width: isSel ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSel ? AppColors.auction : const Color(0xFF64748B),
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                      color: AppColors.navy,
                    ),
                  ),
                  Text(desc, style: AppTextStyles.captionMuted),
                ],
              ),
            ),
            Radio.adaptive(
              value: val,
              groupValue: selected,
              activeColor: AppColors.auction,
              onChanged: (_) => onTap(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletBalanceProvider).valueOrNull;
    final awards = ref.watch(awardsProvider);
    final transactionsAsync = ref.watch(transactionsProvider);

    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: AppBar(
        title: const Text('Payments & Financials'),
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Top Summary Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: AppColors.gradientNoir,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TOTAL EMD ESCROW DEPOSIT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.goldSoft,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          Formatters.formatINR(wallet?.balanceInr ?? 0),
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/wallet'),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Deposit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.auction,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusLg,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _headerStat(
                        'Locked in Live',
                        Formatters.formatINR(wallet?.lockedInr ?? 0),
                      ),
                      _headerStat(
                        'Available',
                        Formatters.formatINR(wallet?.availableInr ?? 0),
                      ),
                      _headerStat('Refund Due', '₹0'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0).withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(999),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.white,
                unselectedLabelColor: AppColors.navyWithOpacity(0.65),
                labelStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                indicator: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(999),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerHeight: 0,
                tabs: const [
                  Tab(text: 'Pay Balance'),
                  Tab(text: 'EMD Ledger'),
                  Tab(text: 'Invoices'),
                ],
              ),
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Pay Balance Invoices
                ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 80),
                  itemCount: awards.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) {
                    final a = awards[i];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radius2xl,
                        ),
                        border: Border.all(color: AppColors.cardBorder),
                        boxShadow: AppColors.shadowSm,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(a.id, style: AppTextStyles.mono),
                              Text(
                                Formatters.formatINR(a.balanceDueInr),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.destructive,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(a.auctionTitle, style: AppTextStyles.labelLarge),
                          const SizedBox(height: 4),
                          Text(
                            'Seller: ${a.sellerCompany} • Net Balance',
                            style: AppTextStyles.captionMuted,
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _openPayModal(context, a),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.navy,
                                foregroundColor: AppColors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusLg,
                                  ),
                                ),
                              ),
                              child: const Text(
                                'Pay Net Balance',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // EMD Ledger Tab: render only wallet transactions returned by the API.
                _transactionTab(transactionsAsync),

                // Invoice records are not exposed by the current mobile API contract.
                // Keep this state explicit instead of presenting fabricated invoices.
                _emptyTab('No invoices are available yet.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _transactionTab(AsyncValue<List<Transaction>> transactionsAsync) {
    return transactionsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) =>
          Center(child: Text('Unable to load EMD ledger: $error')),
      data: (transactions) {
        final emdTransactions = transactions
            .where(
              (transaction) =>
                  transaction.type == TransactionType.emdLock ||
                  transaction.type == TransactionType.emdRelease ||
                  transaction.type == TransactionType.refund,
            )
            .toList();
        if (emdTransactions.isEmpty) {
          return _emptyTab('No EMD transactions are available yet.');
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 80),
          itemCount: emdTransactions.length,
          itemBuilder: (_, index) => _transactionTile(emdTransactions[index]),
        );
      },
    );
  }

  Widget _emptyTab(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.captionMuted,
        ),
      ),
    );
  }

  Widget _transactionTile(Transaction transaction) {
    final isRelease =
        transaction.type == TransactionType.emdRelease ||
        transaction.type == TransactionType.refund;
    final color = isRelease ? AppColors.success : AppColors.auction;
    final reference = transaction.reference ?? 'Transaction #${transaction.id}';
    final title = transaction.note ?? transaction.title;
    final date =
        '${transaction.at.day.toString().padLeft(2, '0')}/${transaction.at.month.toString().padLeft(2, '0')}/${transaction.at.year}';
    return _ledgerTile(
      reference,
      '$title • $date',
      transaction.amountInr.abs(),
      transaction.status.toUpperCase(),
      color,
    );
  }

  Widget _headerStat(String label, String val) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.white.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          val,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.goldSoft,
          ),
        ),
      ],
    );
  }

  Widget _ledgerTile(
    String code,
    String title,
    double amount,
    String status,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(code, style: AppTextStyles.mono),
              const SizedBox(height: 2),
              Text(title, style: AppTextStyles.labelMedium),
              const SizedBox(height: 2),
              Text(
                status,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          Text(Formatters.formatINR(amount), style: AppTextStyles.labelLarge),
        ],
      ),
    );
  }
}
