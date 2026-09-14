import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../providers/auth_provider.dart';
import '../../services/profile_service.dart';
import '../../widgets/shared/screen_header.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _saving = false;
  bool _initialized = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final updated = await ProfileService().update(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
      );
      ref.read(authProvider.notifier).setUser(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final isLocked = user?.isKycPending ?? false;
    final name = user?.name ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    final gstin = user?.vendor?.gstNumber;
    final pan = user?.vendor?.panNumber;

    if (!_initialized) {
      _nameCtrl.text = name;
      _phoneCtrl.text = user?.phone ?? '';
      _initialized = true;
    }

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
                            initial,
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
                _editableField('Full Name', _nameCtrl),
                _readOnlyField('Email', user?.email ?? ''),
                _editableField('Phone', _phoneCtrl),
                _readOnlyField('Company Name', user?.companyName ?? ''),
                _readOnlyField('Vendor Code', user?.vendorCode ?? 'Pending Assignment'),
                if (gstin != null && gstin.isNotEmpty)
                  _readOnlyField('GSTIN', gstin),
                if (pan != null && pan.isNotEmpty)
                  _readOnlyField('PAN', pan),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity, height: AppSpacing.buttonXl,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _editableField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.labelMedium),
          const SizedBox(height: 6),
          TextFormField(controller: controller),
        ],
      ),
    );
  }

  Widget _readOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTextStyles.labelMedium),
              const Text('LOCKED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8))),
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            initialValue: value,
            readOnly: true,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Color(0xFFF1F5F9),
            ),
          ),
        ],
      ),
    );
  }
}
