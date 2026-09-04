import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/asset_paths.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _identifierController = TextEditingController(
    text: 'ankit@novusalloys.com',
  );
  final _passwordController = TextEditingController(text: 'password');
  bool _isBuyer = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_identifierController.text.isEmpty || _passwordController.text.isEmpty)
      return;
    ref.read(authProvider.notifier).clearError();
    await ref
        .read(authProvider.notifier)
        .login(
          identifier: _identifierController.text.trim(),
          password: _passwordController.text,
        );
    final state = ref.read(authProvider);
    if (state.isAuthenticated && mounted) {
      context.go('/home');
    }
  }

  void _loginWithOtp() {
    if (_identifierController.text.isEmpty) return;
    context.push('/otp', extra: _identifierController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
            child: Container(
              padding: const EdgeInsets.all(24),
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
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: AppColors.gradientGold,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: AppColors.shadowGold,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          child: Image.asset(
                            AssetPaths.appIcon,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppConstants.appName,
                            style: AppTextStyles.heading(
                              size: 20,
                              weight: FontWeight.w900,
                            ),
                          ),
                          const Text(
                            'Enterprise B2B Auction Platform',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Corporate Sign In',
                    style: AppTextStyles.heading(
                      size: 18,
                      weight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Access live forward auctions, reverse sourcing, and contract awards.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildRoleToggle(),
                  const SizedBox(height: 18),
                  Text(
                    'Corporate Email or Mobile',
                    style: AppTextStyles.labelMedium,
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _identifierController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'you@company.com or +91...',
                      prefixIcon: Icon(Icons.business_outlined, size: 18),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Password', style: AppTextStyles.labelMedium),
                      GestureDetector(
                        onTap: () => context.push('/forgot-password'),
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.auction,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Enter password',
                      prefixIcon: const Icon(Icons.lock_outline, size: 18),
                      suffixIcon: GestureDetector(
                        onTap: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        child: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 18,
                        ),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  if (authState.hasError) ...[
                    const SizedBox(height: 8),
                    Text(
                      authState.error,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.destructive,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: authState.authState == AuthState.loading
                          ? null
                          : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navy,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusXl,
                          ),
                        ),
                      ),
                      child: authState.authState == AuthState.loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                          : const Text(
                              'Sign In to Scrapify Auctions',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: OutlinedButton(
                            onPressed: _loginWithOtp,
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusLg,
                                ),
                              ),
                            ),
                            child: const Text(
                              'Sign in with OTP',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: AppColors.navy,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                context.push('/mfa', extra: '/home'),
                            icon: const Icon(
                              Icons.fingerprint,
                              color: AppColors.auction,
                              size: 20,
                            ),
                            label: const Text(
                              'Face ID / MFA',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: AppColors.navy,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusLg,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () => context.push('/vendor-onboarding'),
                      child: const Text.rich(
                        TextSpan(
                          text: 'New Vendor or Buyer? ',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF64748B),
                          ),
                          children: [
                            TextSpan(
                              text: 'Start Guided Onboarding',
                              style: TextStyle(
                                color: AppColors.auction,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleToggle() {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.appBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isBuyer = true;
                  _identifierController.text = 'ankit@novusalloys.com';
                  _passwordController.text = 'password';
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _isBuyer ? AppColors.navy : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: Center(
                  child: Text(
                    'Buyer / Bidder',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: _isBuyer ? AppColors.white : AppColors.navy,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isBuyer = false;
                  _identifierController.text = 'vikram@scrapify.test';
                  _passwordController.text = 'password';
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: !_isBuyer ? AppColors.navy : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: Center(
                  child: Text(
                    'Seller / Enterprise',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: !_isBuyer ? AppColors.white : AppColors.navy,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
