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
    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: Column(
        children: [
          ScreenHeader(title: 'Edit Profile', onBack: () => context.pop()),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
              children: [
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(gradient: AppColors.gradientGold, shape: BoxShape.circle),
                        child: Center(child: Text((user?.name ?? 'G')[0], style: AppTextStyles.heading(size: 32, color: AppColors.white))),
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
                _field('Email', user?.email ?? ''),
                _field('Phone', user?.phone ?? ''),
                _field('Company Name', user?.companyName ?? ''),
                _field('Vendor Code', user?.vendorCode ?? ''),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity, height: AppSpacing.buttonXl,
                  child: ElevatedButton(onPressed: () => context.pop(), child: const Text('Save Changes')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.labelMedium),
          const SizedBox(height: 6),
          TextFormField(initialValue: value, decoration: const InputDecoration()),
        ],
      ),
    );
  }
}
