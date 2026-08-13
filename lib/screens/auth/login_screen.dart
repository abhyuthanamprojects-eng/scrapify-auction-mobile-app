import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/constants/asset_paths.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isBuyer = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_identifierController.text.isEmpty || _passwordController.text.isEmpty) return;
    ref.read(authProvider.notifier).clearError();
    await ref.read(authProvider.notifier).login(
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
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    AssetPaths.appIcon,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: AppColors.gradientGold,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.gavel, size: 24, color: AppColors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Welcome to Scrapify', style: AppTextStyles.displayMedium),
                const SizedBox(height: 4),
                Text(
                  'Sign in to start bidding on industrial scrap',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 32),
                _buildRoleToggle(),
                const SizedBox(height: 24),
                Text('Email or Phone', style: AppTextStyles.labelMedium),
                const SizedBox(height: 8),
                TextField(
                  controller: _identifierController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'you@company.com or +91...',
                    prefixIcon: Icon(Icons.person_outline, size: 18),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Password', style: AppTextStyles.labelMedium),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Enter password',
                    prefixIcon: const Icon(Icons.lock_outline, size: 18),
                    suffixIcon: GestureDetector(
                      onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                      child: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                if (authState.hasError) ...[
                  const SizedBox(height: 8),
                  Text(authState.error, style: TextStyle(fontSize: 12, color: AppColors.destructive)),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: AppSpacing.buttonXl,
                  child: ElevatedButton(
                    onPressed: authState.authState == AuthState.loading ? null : _login,
                    child: authState.authState == AuthState.loading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                        : const Text('Sign In'),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: _loginWithOtp,
                    child: Text(
                      'Sign in with OTP instead',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.auction,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () => context.push('/signup'),
                    child: Text.rich(
                      TextSpan(
                        text: 'New user? ',
                        style: AppTextStyles.bodySmall,
                        children: [
                          TextSpan(
                            text: 'Register here',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.auction,
                              fontWeight: FontWeight.w700,
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
    );
  }

  Widget _buildRoleToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.appBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Row(
        children: [
          _roleButton('I want to Bid', Icons.person_outline_rounded, _isBuyer, () => setState(() => _isBuyer = true)),
          _roleButton('I want to Sell', Icons.store_rounded, !_isBuyer, () => setState(() => _isBuyer = false)),
        ],
      ),
    );
  }

  Widget _roleButton(String label, IconData icon, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: selected ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: selected
                ? [BoxShadow(color: AppColors.blackWithOpacity(0.08), blurRadius: 8)]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? AppColors.navy : AppColors.navyWithOpacity(0.5),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? AppColors.navy : AppColors.navyWithOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
