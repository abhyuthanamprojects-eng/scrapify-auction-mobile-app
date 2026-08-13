import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wallet.dart';
import '../models/transaction.dart';
import '../services/wallet_service.dart';

final _walletService = WalletService();

final walletBalanceProvider = FutureProvider<WalletBalance>((ref) async {
  return _walletService.balance();
});

final transactionsProvider =
    FutureProvider<List<Transaction>>((ref) async {
  final filter = ref.watch(transactionFilterProvider);
  final result = await _walletService.transactions(type: filter);
  return result.transactions;
});

final transactionFilterProvider = StateProvider<String?>((ref) => null);
