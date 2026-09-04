import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/shared/screen_header.dart';

class EditProfileScreen extends ConsumerWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final isLocked = user?.isKycPending ?? false;

    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: Column(
        children: [
          ScreenHeader(title: 'Edit Profile', onBack: () => context.pop()),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
              children: [
                if (isLocked) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.auction.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: AppColors.auction.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.auction, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Legal entity and tax identifiers are read-only while your KYC verification is in progress.',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          gradient: user?.kycVerified ?? false ? AppColors.gradientGold : AppColors.gradientNoir,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            (user?.name != null && user.name.isNotEmpty ? user.name[0] : 'U').toUpperCase(),
                            style: AppTextStyles.heading(size: 32, color: AppColors.white),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0, right: 0,
                        child: Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(color: AppColors.navy, shape: BoxShape.circle, border: Border.all(color: AppColors.white, width: 2)),
                          child: const Icon(Icons.camera_alt, size: 14, color: AppColors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _field('Full Name', user?.name ?? ''),
                _field('Email', user?.email ?? '', readOnly: true),
                _field('Phone', user?.phone ?? ''),
                _field('Company Name', user?.companyName ?? '', readOnly: isLocked),
                _field('Vendor Code', user?.vendorCode ?? 'Pending Assignment', readOnly: true),
                if (user?.vendor?.gstNumber != null)
                  _field('GSTIN', user!.vendor!.gstNumber!, readOnly: true),
                if (user?.vendor?.panNumber != null)
                  _field('PAN', user!.vendor!.panNumber!, readOnly: true),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity, height: AppSpacing.buttonXl,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile details updated successfully')),
                      );
                      context.pop();
                    },
                    child: const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, String value, {bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTextStyles.labelMedium),
              if (readOnly)
                const Text('LOCKED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8))),
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            initialValue: value,
            readOnly: readOnly,
            decoration: InputDecoration(
              filled: readOnly,
              fillColor: readOnly ? const Color(0xFFF1F5F9) : AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}
