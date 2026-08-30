import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../providers/auth_provider.dart';

class SessionExpiredScreen extends ConsumerStatefulWidget {
  final String? returnPath;
  const SessionExpiredScreen({super.key, this.returnPath});

  @override
  ConsumerState<SessionExpiredScreen> createState() => _SessionExpiredScreenState();
}

class _SessionExpiredScreenState extends ConsumerState<SessionExpiredScreen> {
  final _passCtl = TextEditingController();
  bool _loading = false;

  void _relogin() {
    if (_passCtl.text.isEmpty) return;
    setState(() => _loading = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _loading = false);
      context.go(widget.returnPath ?? '/home');
    });
  }

  void _biometricRelogin() {
    setState(() => _loading = true);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() => _loading = false);
      context.go(widget.returnPath ?? '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
              border: Border.all(color: AppColors.cardBorder),
              boxShadow: AppColors.shadowLg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.destructive.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.timer_off_outlined, color: AppColors.destructive, size: 34),
                ),
                const SizedBox(height: 16),
                Text('Session Timed Out', style: AppTextStyles.heading(size: 20, weight: FontWeight.w900)),
                const SizedBox(height: 6),
                const Text(
                  'Your corporate session expired due to 15 minutes of inactivity. Please re-authenticate to continue.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
                ),
                const SizedBox(height: 20),

                // User Chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.appBg,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.navy,
                        child: Text((user?.name ?? 'R')[0], style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user?.name ?? 'Rahul Sharma', style: AppTextStyles.labelMedium),
                            Text(user?.email ?? 'rahul.sharma@devzign.in', style: AppTextStyles.captionMuted),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _passCtl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Enter Password / Corporate PIN',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _relogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusXl)),
                    ),
                    child: _loading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2))
                        : const Text('Unlock Session', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: _loading ? null : _biometricRelogin,
                    icon: const Icon(Icons.fingerprint, color: AppColors.auction, size: 22),
                    label: const Text('Fast Biometric Unlock', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.navy)),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusXl)),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Sign in with a different account', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
