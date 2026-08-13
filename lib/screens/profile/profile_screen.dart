import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/asset_paths.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screenPaddingH,
          MediaQuery.of(context).padding.top + 16,
          AppSpacing.screenPaddingH,
          AppSpacing.bottomNavPadding,
        ),
        children: [
          _buildProfileHeader(user),
          const SizedBox(height: 20),
          _section('Account', [
            _menuItem(Icons.person_outline, 'Edit Profile', () => context.push('/profile/edit')),
            _menuItem(Icons.location_on_outlined, 'Addresses', () => context.push('/profile/addresses')),
            _menuItem(Icons.payment, 'Payment Methods', () => context.push('/profile/payments')),
          ]),
          _section('Verification', [
            _menuItem(Icons.verified_user_outlined, 'KYC Documents', () => context.push('/profile/kyc'), trailing: _kycBadge(user?.kycVerified ?? false)),
          ]),
          _section('Activity', [
            _menuItem(Icons.notifications_outlined, 'Notifications', () => context.push('/notifications')),
            _menuItem(Icons.receipt_long, 'My Bids', () {}),
          ]),
          _section('Finance', [
            _menuItem(Icons.account_balance_wallet_outlined, 'Wallet', () {}),
            _menuItem(Icons.lock_outline, 'EMD Ledger', () {}),
          ]),
          _section('Preferences', [
            _menuItem(Icons.notifications_none, 'Notification Settings', () => context.push('/profile/notif-settings')),
            _menuItem(Icons.help_outline, 'Help & FAQ', () => _showHelpSheet(context)),
            _menuItem(Icons.flag_outlined, 'Raise a Ticket', () => _showTicketSheet(context)),
          ]),
          const SizedBox(height: 20),
          _logoutButton(context, ref),
          const SizedBox(height: 24),
          _aboutBranding(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.blackWithOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: AppColors.gradientGold,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                (user?.name ?? 'G')[0],
                style: AppTextStyles.heading(size: 22, color: AppColors.white),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user?.name ?? 'Guest', style: AppTextStyles.titleSmall),
                Text(user?.email ?? '', style: AppTextStyles.caption),
                if (user?.companyName != null)
                  Text(user!.companyName!, style: AppTextStyles.captionMuted),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.navy),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(title, style: AppTextStyles.labelSmall.copyWith(color: AppColors.navyWithOpacity(0.5))),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            border: Border.all(color: AppColors.blackWithOpacity(0.05)),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _menuItem(IconData icon, String label, VoidCallback onTap, {Widget? trailing}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.navyWithOpacity(0.6)),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: AppTextStyles.bodyMedium)),
            if (trailing != null) trailing,
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 18, color: AppColors.navyWithOpacity(0.3)),
          ],
        ),
      ),
    );
  }

  Widget _kycBadge(bool verified) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: verified ? AppColors.success.withValues(alpha: 0.1) : AppColors.auction.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        verified ? 'Verified' : 'Pending',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: verified ? AppColors.success : AppColors.auction,
        ),
      ),
    );
  }

  Widget _logoutButton(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              TextButton(
                onPressed: () {
                  ref.read(authProvider.notifier).logout();
                  context.go('/login');
                },
                child: const Text('Logout', style: TextStyle(color: AppColors.destructive)),
              ),
            ],
          ),
        );
      },
      child: Container(
        height: AppSpacing.buttonLg,
        decoration: BoxDecoration(
          color: AppColors.destructive.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, size: 18, color: AppColors.destructive),
            const SizedBox(width: 8),
            Text('Logout', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.destructive)),
          ],
        ),
      ),
    );
  }

  Widget _aboutBranding() {
    return Center(
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(AssetPaths.appIcon, width: 36, height: 36, fit: BoxFit.cover),
          ),
          const SizedBox(height: 6),
          Text('Scrapify Auction', style: AppTextStyles.caption),
          Text('v1.0.0', style: AppTextStyles.captionMuted),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showHelpSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Help & FAQ', style: AppTextStyles.titleMedium),
            const SizedBox(height: 16),
            _faqItem('How do I place a bid?', 'Navigate to a live auction, enter your bid amount, and tap Place Bid.'),
            _faqItem('What is EMD?', 'Earnest Money Deposit is a refundable amount locked before bidding.'),
            _faqItem('How do refunds work?', 'EMD is auto-released to your wallet when you lose an auction.'),
            _faqItem('How to contact support?', 'Use the Raise a Ticket option or email support@scrapify.in'),
          ],
        ),
      ),
    );
  }

  Widget _faqItem(String q, String a) {
    return ExpansionTile(
      title: Text(q, style: AppTextStyles.labelMedium),
      children: [Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 12), child: Text(a, style: AppTextStyles.caption))],
    );
  }

  void _showTicketSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Raise a Ticket', style: AppTextStyles.titleMedium),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(hintText: 'Subject')),
            const SizedBox(height: 12),
            const TextField(decoration: InputDecoration(hintText: 'Describe your issue...'), maxLines: 4),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: AppSpacing.buttonLg,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
