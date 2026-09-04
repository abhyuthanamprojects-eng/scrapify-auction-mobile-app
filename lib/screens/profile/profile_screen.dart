import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/constants/app_constants.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          20,
          MediaQuery.of(context).padding.top + 16,
          20,
          100,
        ),
        children: [
          _buildProfileHeader(context, user),
          const SizedBox(height: 16),

          _section('Corporate & Operations', [
            _menuItem(Icons.emoji_events_outlined, 'My Awards & Fallback Offers', () => context.push('/awards')),
            _menuItem(Icons.local_shipping_outlined, 'Fulfilment & Gate Passes', () => context.push('/orders')),
            _menuItem(Icons.folder_shared_outlined, 'Document Vault & Certificates', () => context.push('/documents')),
            _menuItem(Icons.people_outline_rounded, 'Team & Authorized Bidders', () => context.push('/team')),
            _menuItem(Icons.star_outline_rounded, 'Vendor Scorecard & Tier', () => context.push('/performance')),
          ]),

          _section('Financials & Escrow', [
            _menuItem(Icons.account_balance_wallet_outlined, 'Payments & EMD Escrow', () => context.push('/payments')),
            _menuItem(Icons.receipt_long_outlined, 'My Live Bids & History', () => context.push('/my-bids')),
            _menuItem(Icons.shield_outlined, 'Disputes & Claims', () => context.push('/disputes')),
          ]),

          _section('Compliance & Settings', [
            _menuItem(
              Icons.verified_user_outlined,
              'KYC & Company Verification',
              () => context.push('/vendor-onboarding'),
              trailing: _kycBadge(user?.kycStatus ?? 'pending', user?.kycVerified ?? false, user?.isKycRejected ?? false),
            ),
            _menuItem(Icons.security_outlined, 'Security & Trusted Devices', () => context.push('/trusted-devices')),
            _menuItem(Icons.notifications_none_outlined, 'Notifications', () => context.push('/notifications')),
            _menuItem(Icons.support_agent_outlined, 'Help Centre & Support Desk', () => _showHelpSheet(context)),
          ]),

          const SizedBox(height: 20),
          _logoutButton(context, ref),
          const SizedBox(height: 24),
          _aboutBranding(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, AppUser? user) {
    final kycStatus = user?.kycStatus ?? 'pending';
    final isApproved = user?.kycVerified ?? false;
    final isRejected = user?.isKycRejected ?? false;
    final userName = user?.name ?? '';
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';
    final displayName = userName.isNotEmpty ? userName : 'Registered User';
    final userCompany = user?.companyName;
    final companyName = (userCompany != null && userCompany.isNotEmpty)
        ? userCompany
        : (user?.roleLabel ?? 'Account Holder');
    final vendorGst = user?.vendor?.gstNumber;
    final gstin = (vendorGst != null && vendorGst.isNotEmpty)
        ? vendorGst
        : 'Not Linked';
    final rejectionReason = user?.rejectionReason;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppColors.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: isApproved ? AppColors.gradientGold : AppColors.gradientNoir,
                  shape: BoxShape.circle,
                  boxShadow: AppColors.shadowSm,
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: AppTextStyles.heading(size: 22, color: AppColors.white),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: AppTextStyles.heading(size: 16, weight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      companyName,
                      style: AppTextStyles.captionMuted,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              _kycBadge(kycStatus, isApproved, isRejected),
            ],
          ),
          if (user?.vendor != null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: Color(0xFFF1F5F9)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _miniDetail('Role', user?.roleLabel ?? 'Buyer'),
                _miniDetail('Vendor Code', user?.vendorCode ?? 'Pending'),
                _miniDetail('GSTIN', gstin),
              ],
            ),
          ],
          if (isRejected && rejectionReason != null && rejectionReason.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.destructive.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.destructive.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.destructive, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('KYC Action Required', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.destructive)),
                        const SizedBox(height: 2),
                        Text(rejectionReason, style: const TextStyle(fontSize: 11, color: Color(0xFF475569))),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/vendor-onboarding'),
                    child: const Text('Fix Now', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.destructive)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _miniDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.navy)),
      ],
    );
  }

  Widget _section(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 0.5),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: AppColors.shadowSm,
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.navy),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.navy)),
            ),
            if (trailing != null) trailing else const Icon(Icons.chevron_right, size: 18, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  Widget _kycBadge(String status, bool isApproved, bool isRejected) {
    Color bg = AppColors.auction.withValues(alpha: 0.12);
    Color fg = AppColors.auction;
    String label = 'Under Review';

    if (isApproved) {
      bg = AppColors.success.withValues(alpha: 0.12);
      fg = AppColors.success;
      label = 'Verified';
    } else if (isRejected) {
      bg = AppColors.destructive.withValues(alpha: 0.12);
      fg = AppColors.destructive;
      label = 'Action Required';
    } else if (status == 'draft') {
      label = 'Draft (Incomplete)';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: fg),
      ),
    );
  }

  Widget _logoutButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: () async {
          await ref.read(authProvider.notifier).logout();
          if (context.mounted) context.go('/login');
        },
        icon: const Icon(Icons.logout, color: AppColors.destructive, size: 18),
        label: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.destructive)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.destructive.withValues(alpha: 0.3)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusXl)),
        ),
      ),
    );
  }

  Widget _aboutBranding() {
    return Center(
      child: Column(
        children: [
          Text('${AppConstants.appName} Enterprise v2.4.0', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
          const SizedBox(height: 2),
          const Text('Secure Multi-Category Auction & Procurement Platform', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }

  void _showHelpSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
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
                decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 14),
            Text('Support & Help Desk', style: AppTextStyles.heading(size: 17, weight: FontWeight.w800)),
            const SizedBox(height: 12),
            _helpRow('Toll-Free Auction Helpline', '1800 200 4890 (Mon-Sat, 9AM-8PM)'),
            _helpRow('Enterprise Support Email', 'support@scrapify.io'),
            _helpRow('Arbitration Desk', 'disputes@scrapify.io'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.push('/support');
                },
                icon: const Icon(Icons.confirmation_number_outlined, size: 16),
                label: const Text('View / Raise Support Tickets'),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _helpRow(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(k, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
          Text(v, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.navy)),
        ],
      ),
    );
  }
}
