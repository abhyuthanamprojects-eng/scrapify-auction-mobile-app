import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/shared/screen_header.dart';

class RegStatusScreen extends StatelessWidget {
  final String status; // 'pending' | 'rejected' | 'suspended' | 'approved'
  final String? reason;
  final bool updateRequested;
  final Map<String, String> kycDetails;
  final VoidCallback onBack;
  final VoidCallback? onEditRegistration;
  final VoidCallback? onRequestKycUpdate;
  final VoidCallback? onContactSupport;

  const RegStatusScreen({
    super.key,
    required this.status,
    this.reason,
    this.updateRequested = false,
    this.kycDetails = const {},
    required this.onBack,
    this.onEditRegistration,
    this.onRequestKycUpdate,
    this.onContactSupport,
  });

  @override
  Widget build(BuildContext context) {
    final meta = _statusMeta();

    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: Column(
        children: [
          ScreenHeader(
            title: 'Registration status',
            subtitle: 'Vendor KYC',
            onBack: onBack,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPaddingH,
                0,
                AppSpacing.screenPaddingH,
                AppSpacing.bottomNavPadding,
              ),
              children: [
                // Status card
                _card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: meta.bgColor,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                          ),
                          child: Icon(meta.icon, size: 34, color: meta.iconColor),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          meta.title,
                          style: AppTextStyles.heading(size: 18, weight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          meta.body,
                          style: AppTextStyles.body(
                            size: 12,
                            color: AppColors.navyWithOpacity(0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (updateRequested && status == 'pending') ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.auctionWithOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                            ),
                            child: Text(
                              'KYC update requested — back in the admin queue',
                              style: AppTextStyles.body(
                                size: 11,
                                weight: FontWeight.w700,
                                color: AppColors.auction,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Admin reason
                if (reason != null && reason!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.destructiveWithOpacity(0.05),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                      border: Border.all(color: AppColors.destructiveWithOpacity(0.25)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ADMIN REASON',
                          style: AppTextStyles.body(
                            size: 10,
                            weight: FontWeight.w700,
                            color: AppColors.destructive,
                          ).copyWith(letterSpacing: 1.0),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reason!,
                          style: AppTextStyles.body(
                            size: 12,
                            color: AppColors.navy,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Submitted details
                const SizedBox(height: 12),
                _card(
                  child: Column(
                    children: [
                      _sectionHeader('Submitted details'),
                      _divider(),
                      _kvRow('Company', kycDetails['companyName'] ?? '—'),
                      _divider(),
                      _kvRow('GST', kycDetails['gstNumber'] ?? '—'),
                      _divider(),
                      _kvRow('PAN', kycDetails['panNumber'] ?? '—'),
                      _divider(),
                      _kvRow('Licence No.', kycDetails['licenseNumber'] ?? '—'),
                      _divider(),
                      _kvRow('Material interest', kycDetails['materials'] ?? '—'),
                      _divider(),
                      _kvRow('Bank', kycDetails['bank'] ?? '—'),
                    ],
                  ),
                ),

                // Action buttons
                const SizedBox(height: 16),
                if (status == 'rejected' && onEditRegistration != null)
                  _primaryButton(
                    label: 'Edit & resubmit',
                    icon: Icons.arrow_forward,
                    color: AppColors.auction,
                    onTap: onEditRegistration!,
                  ),
                if (status == 'approved' && onRequestKycUpdate != null) ...[
                  _outlineButton(
                    label: 'Request KYC update',
                    onTap: onRequestKycUpdate!,
                  ),
                ],
                if (onContactSupport != null) ...[
                  const SizedBox(height: 8),
                  _outlineButton(
                    label: 'Contact support',
                    icon: Icons.support_agent,
                    onTap: onContactSupport!,
                  ),
                ],

                if (status == 'approved') ...[
                  const SizedBox(height: 12),
                  Text(
                    'KYC fields are read-only after approval. Use "Request KYC update" to change them.',
                    style: AppTextStyles.body(
                      size: 11,
                      color: AppColors.navyWithOpacity(0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  _StatusMeta _statusMeta() {
    switch (status) {
      case 'approved':
        return _StatusMeta(
          icon: Icons.check_circle,
          iconColor: AppColors.success,
          bgColor: AppColors.successWithOpacity(0.1),
          title: 'Approved',
          body: 'Your vendor account is active. You can register for auctions and bid.',
        );
      case 'rejected':
        return _StatusMeta(
          icon: Icons.warning_amber_rounded,
          iconColor: AppColors.destructive,
          bgColor: AppColors.destructiveWithOpacity(0.1),
          title: 'Registration rejected',
          body: 'The admin returned your application with the reason below.',
        );
      case 'suspended':
        return _StatusMeta(
          icon: Icons.block,
          iconColor: AppColors.destructive,
          bgColor: AppColors.destructiveWithOpacity(0.1),
          title: 'Account suspended',
          body: 'Bidding is blocked while your account is suspended.',
        );
      default:
        return _StatusMeta(
          icon: Icons.access_time,
          iconColor: AppColors.auction,
          bgColor: AppColors.auctionWithOpacity(0.1),
          title: 'Under review',
          body: 'Usually within 24 hours. We\'ll notify you by email, SMS and in-app.',
        );
    }
  }

  Widget _card({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.blackWithOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackWithOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionHeader(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.body(
          size: 10,
          weight: FontWeight.w700,
          color: AppColors.navyWithOpacity(0.5),
        ).copyWith(letterSpacing: 1.0),
      ),
    );
  }

  Widget _divider() {
    return Divider(height: 1, thickness: 1, color: AppColors.blackWithOpacity(0.05));
  }

  Widget _kvRow(String label, String value) {
    final isPending = value == '—' || value.isEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.body(size: 12, color: AppColors.navyWithOpacity(0.6)),
          ),
          isPending
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.auctionWithOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Pending',
                    style: AppTextStyles.body(size: 11, weight: FontWeight.w700, color: AppColors.auction),
                  ),
                )
              : Text(
                  value,
                  style: AppTextStyles.body(size: 13, weight: FontWeight.w600, color: AppColors.navy),
                ),
        ],
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    IconData? icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppSpacing.buttonXl,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: AppTextStyles.body(size: 14, weight: FontWeight.w700, color: AppColors.white),
            ),
            if (icon != null) ...[
              const SizedBox(width: 4),
              Icon(icon, size: 14, color: AppColors.white),
            ],
          ],
        ),
      ),
    );
  }

  Widget _outlineButton({
    required String label,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppSpacing.buttonXl,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.blackWithOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 15, color: AppColors.navy),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: AppTextStyles.body(size: 14, weight: FontWeight.w600, color: AppColors.navy),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusMeta {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String body;

  const _StatusMeta({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.body,
  });
}
