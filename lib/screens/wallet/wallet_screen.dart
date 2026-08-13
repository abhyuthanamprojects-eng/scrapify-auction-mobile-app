import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../models/transaction.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/cards/wallet_card.dart';
import '../../widgets/shared/loading_skeleton.dart';
import '../../widgets/shared/empty_state.dart';
import '../../services/wallet_service.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(walletBalanceProvider);
    final txnAsync = ref.watch(transactionsProvider);
    final activeFilter = ref.watch(transactionFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screenPaddingH,
                MediaQuery.of(context).padding.top + 16,
                AppSpacing.screenPaddingH,
                16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Wallet', style: AppTextStyles.titleLarge),
                  const SizedBox(height: 16),
                  balanceAsync.when(
                    data: (wallet) => WalletCard(balance: wallet.balanceInr, compact: false),
                    loading: () => const CardSkeleton(),
                    error: (e, _) => WalletCard(balance: 0, compact: false),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _actionButton('Add Money', Icons.add, () => _showAddMoney(context, ref))),
                      const SizedBox(width: 12),
                      Expanded(child: _actionButton('Withdraw', Icons.arrow_downward, () {})),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenPaddingH, 8, AppSpacing.screenPaddingH, 8),
              child: Row(
                children: [
                  Text('Transactions', style: AppTextStyles.titleSmall),
                  const Spacer(),
                  _filterPill(ref, 'add_money', 'Credit', activeFilter),
                  _filterPill(ref, 'payment', 'Debit', activeFilter),
                  _filterPill(ref, 'emd_lock', 'EMD', activeFilter),
                ],
              ),
            ),
          ),
          txnAsync.when(
            data: (txns) {
              if (txns.isEmpty) {
                return const SliverToBoxAdapter(
                  child: EmptyState(
                    icon: Icons.receipt_long,
                    title: 'No transactions',
                    subtitle: 'Your transaction history will appear here',
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _transactionTile(txns[i]),
                  childCount: txns.length,
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(child: ListSkeleton(count: 3)),
            error: (e, _) => SliverToBoxAdapter(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Failed to load', style: AppTextStyles.caption),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => ref.invalidate(transactionsProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.bottomNavPadding)),
        ],
      ),
    );
  }

  Widget _actionButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppSpacing.buttonLg,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.blackWithOpacity(0.05)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: AppColors.navy),
            const SizedBox(width: 6),
            Text(label, style: AppTextStyles.labelMedium),
          ],
        ),
      ),
    );
  }

  Widget _filterPill(WidgetRef ref, String type, String label, String? active) {
    final isActive = active == type;
    return GestureDetector(
      onTap: () => ref.read(transactionFilterProvider.notifier).state = isActive ? null : type,
      child: Container(
        margin: const EdgeInsets.only(left: 6),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? AppColors.navy : AppColors.navyWithOpacity(0.05),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: isActive ? AppColors.white : AppColors.navy),
        ),
      ),
    );
  }

  Widget _transactionTile(Transaction txn) {
    final isCredit = txn.isCredit;
    final typeColors = {
      TransactionType.addMoney: AppColors.success,
      TransactionType.payment: AppColors.destructive,
      TransactionType.emdLock: AppColors.auction,
      TransactionType.emdRelease: AppColors.accentBlue,
      TransactionType.refund: AppColors.success,
      TransactionType.other: AppColors.navy,
    };
    final color = typeColors[txn.type] ?? AppColors.navy;

    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.screenPaddingH, 0, AppSpacing.screenPaddingH, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.blackWithOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCredit ? Icons.arrow_downward : Icons.arrow_upward,
              size: 16,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(txn.title, style: AppTextStyles.labelMedium),
                Text(txn.note ?? txn.reference ?? '', style: AppTextStyles.captionMuted),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isCredit ? "+" : "-"} ${Formatters.formatINR(txn.amountInr.abs())}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isCredit ? AppColors.success : AppColors.destructive,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  txn.type.label,
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddMoney(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddMoneySheet(ref: ref),
    );
  }
}

class _AddMoneySheet extends StatefulWidget {
  final WidgetRef ref;
  const _AddMoneySheet({required this.ref});

  @override
  State<_AddMoneySheet> createState() => _AddMoneySheetState();
}

class _AddMoneySheetState extends State<_AddMoneySheet> {
  final _controller = TextEditingController();
  String _method = 'UPI';
  bool _processing = false;
  bool _success = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _process() async {
    final amount = double.tryParse(_controller.text) ?? 0;
    if (amount <= 0) return;
    setState(() {
      _processing = true;
      _error = null;
    });
    try {
      await WalletService().topUp(amount: amount, method: _method.toLowerCase());
      widget.ref.invalidate(walletBalanceProvider);
      widget.ref.invalidate(transactionsProvider);
      if (mounted) setState(() {
        _processing = false;
        _success = true;
      });
    } catch (e) {
      if (mounted) setState(() {
        _processing = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_success) {
      return Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 48, color: AppColors.success),
            const SizedBox(height: 12),
            Text('Money Added!', style: AppTextStyles.titleMedium),
            const SizedBox(height: 4),
            Text('${Formatters.formatINR(double.tryParse(_controller.text) ?? 0)} via $_method', style: AppTextStyles.caption),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: AppSpacing.buttonLg,
              child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add Money', style: AppTextStyles.titleMedium),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Enter amount', prefixText: '₹ '),
            style: AppTextStyles.priceLarge,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [1000, 5000, 10000, 25000].map((a) => GestureDetector(
              onTap: () => _controller.text = '$a',
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.navyWithOpacity(0.05),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text('₹${Formatters.formatINR(a)}', style: AppTextStyles.labelSmall),
              ),
            )).toList(),
          ),
          const SizedBox(height: 16),
          Text('Payment Method', style: AppTextStyles.labelMedium),
          const SizedBox(height: 8),
          ...['UPI', 'Credit/Debit Card', 'Net Banking'].map((m) => RadioListTile<String>(
            title: Text(m, style: AppTextStyles.bodyMedium),
            value: m,
            groupValue: _method,
            onChanged: (v) => setState(() => _method = v!),
            activeColor: AppColors.auction,
            dense: true,
          )),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(fontSize: 12, color: AppColors.destructive)),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: AppSpacing.buttonXl,
            child: ElevatedButton(
              onPressed: _processing ? null : _process,
              child: _processing
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                  : const Text('Add Money'),
            ),
          ),
        ],
      ),
    );
  }
}
