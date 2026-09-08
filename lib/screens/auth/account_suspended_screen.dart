import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';

class AccountSuspendedScreen extends StatelessWidget {
  final String? reason;
  final String? ticketRef;

  const AccountSuspendedScreen({super.key, this.reason, this.ticketRef});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: AppBar(
        title: const Text('Account Status Notice'),
        backgroundColor: AppColors.destructive,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
                border: Border.all(
                  color: AppColors.destructive.withValues(alpha: 0.2),
                ),
                boxShadow: AppColors.shadowSm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.destructive.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.gavel_rounded,
                        color: AppColors.destructive,
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Account Suspended',
                      style: AppTextStyles.heading(
                        size: 20,
                        weight: FontWeight.w900,
                        color: AppColors.destructive,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Center(
                    child: Text(
                      'Participation in live events and contract awards has been temporarily halted.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Reason Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'REASON FOR SUSPENSION',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.destructive,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reason ??
                              'The server did not provide a suspension reason.',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navy,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (ticketRef != null)
                          Text(
                            'Case Reference: $ticketRef',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Required Remedial Actions:',
                    style: AppTextStyles.heading(
                      size: 14,
                      weight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _remedyItem(
                    '1. Upload latest audited GST annual returns (GSTR-9) in Document Centre.',
                  ),
                  _remedyItem(
                    '2. Verify Board Resolution / Authorized Signatory letter.',
                  ),
                  _remedyItem(
                    '3. Submit formal compliance appeal letter via Grievance Desk.',
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/documents'),
                      icon: const Icon(Icons.upload_file, size: 20),
                      label: const Text(
                        'Go to Document Centre',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navy,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusXl,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () => context.push('/support'),
                      icon: const Icon(
                        Icons.headset_mic_outlined,
                        size: 20,
                        color: AppColors.navy,
                      ),
                      label: const Text(
                        'Contact Compliance Desk',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusXl,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: TextButton.icon(
                onPressed: () => context.go('/login'),
                icon: const Icon(
                  Icons.logout,
                  size: 16,
                  color: Color(0xFF64748B),
                ),
                label: const Text(
                  'Sign Out',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _remedyItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.arrow_right, color: AppColors.destructive, size: 20),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.navy,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
