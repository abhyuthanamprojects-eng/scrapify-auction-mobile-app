import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/asset_paths.dart';
import '../../core/validation/input_validators.dart';
import '../../providers/auth_provider.dart';
import '../../services/biometric_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isBuyer = true;
  bool _useOtp = false;
  bool _loginByEmail = true;
  bool _obscurePassword = true;
  bool _biometricAvailable = false;
  String? _identifierError;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final show = await BiometricService.shouldShowLockScreen;
    if (mounted) setState(() => _biometricAvailable = show);
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final identifier = _identifierController.text.trim();
    if (identifier.isEmpty || _passwordController.text.isEmpty) {
      setState(
        () => _identifierError = _loginByEmail
            ? 'Enter your email address and password.'
            : 'Enter your 10-digit mobile number and password.',
      );
      return;
    }
    if (!_isValidSelectedIdentifier(identifier)) {
      setState(
        () => _identifierError = _loginByEmail
            ? 'Enter a valid email address.'
            : 'Enter a valid 10-digit Indian mobile number.',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _loginByEmail
                ? 'Enter a valid email address.'
                : 'Enter a valid 10-digit Indian mobile number.',
          ),
        ),
      );
      return;
    }
    setState(() => _identifierError = null);
    ref.read(authProvider.notifier).clearError();
    await ref
        .read(authProvider.notifier)
        .login(
          identifier: _identifierController.text.trim(),
          password: _passwordController.text,
          loginContext: _isBuyer ? 'buyer' : 'seller',
        );
    final state = ref.read(authProvider);
    if (state.isAuthenticated && mounted) {
      await _offerBiometricOptIn();
      if (!mounted) return;
      // Keep every authenticated role inside the shared shell so pending
      // users retain access to Profile, Settings, logout, and account deletion.
      context.go('/home');
    }
  }

  Future<void> _offerBiometricOptIn() async {
    final alreadyEnabled = await BiometricService.isEnabled;
    if (alreadyEnabled) return;
    final available = await BiometricService.isAvailable;
    if (!available || !mounted) return;

    final enable = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.auction.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.face_unlock_rounded,
                  size: 32,
                  color: AppColors.auction.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Enable Face ID?',
                style: AppTextStyles.heading(size: 20, weight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'Use Face ID to quickly unlock Scrapify Auctions next time you open the app.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Enable Face ID',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text(
                  'Not now',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (enable == true) {
      final authenticated = await BiometricService.authenticate();
      if (authenticated) {
        await BiometricService.setEnabled(true);
      }
    }
  }

  void _loginWithOtp() {
    final identifier = _identifierController.text.trim();
    if (!_isValidSelectedIdentifier(identifier)) {
      setState(
        () => _identifierError = _loginByEmail
            ? 'Enter a valid email address.'
            : 'Enter a valid 10-digit Indian mobile number.',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _loginByEmail
                ? 'Enter a valid email address.'
                : 'Enter a valid 10-digit Indian mobile number.',
          ),
        ),
      );
      return;
    }
    setState(() => _identifierError = null);
    context.push('/otp', extra: identifier);
  }

  bool _isValidSelectedIdentifier(String value) =>
      _loginByEmail ? isEmail(value) : isIndianMobile(value);

  Future<void> _loginWithBiometric() async {
    final authenticated = await BiometricService.authenticate();
    if (!authenticated || !mounted) return;
    await ref.read(authProvider.notifier).refreshUser();
    final state = ref.read(authProvider);
    if (state.isAuthenticated && mounted) {
      context.go('/home');
    }
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
                  const SizedBox(height: 14),
                  _buildLoginModeToggle(),
                  const SizedBox(height: 18),
                  _buildIdentifierModeToggle(),
                  const SizedBox(height: 18),
                  Text(
                    _loginByEmail ? 'Corporate Email' : 'Mobile Number',
                    style: AppTextStyles.labelMedium,
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _identifierController,
                    keyboardType: _loginByEmail
                        ? TextInputType.emailAddress
                        : TextInputType.phone,
                    maxLength: _loginByEmail ? 254 : 10,
                    inputFormatters: _loginByEmail
                        ? null
                        : [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) {
                      if (_identifierError != null) {
                        setState(() => _identifierError = null);
                      }
                    },
                    decoration: InputDecoration(
                      hintText: _loginByEmail
                          ? 'you@company.com'
                          : '10-digit mobile number',
                      prefixIcon: Icon(Icons.business_outlined, size: 18),
                      border: OutlineInputBorder(),
                    ).copyWith(errorText: _identifierError),
                  ),
                  if (!_useOtp) ...[
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
                  ] else ...[
                    const SizedBox(height: 8),
                    const Text(
                      'We\'ll send a one-time code to your email or mobile number.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
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
                          : _useOtp
                          ? _loginWithOtp
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
                          : Text(
                              _useOtp ? 'Send OTP' : 'Sign In',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),
                  if (_biometricAvailable) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: _loginWithBiometric,
                        icon: const Icon(
                          Icons.fingerprint,
                          color: AppColors.auction,
                          size: 20,
                        ),
                        label: const Text(
                          'Sign in with Face ID',
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
                  ],
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

  Widget _buildLoginModeToggle() {
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
              onTap: () => setState(() {
                _useOtp = true;
                _passwordController.clear();
                ref.read(authProvider.notifier).clearError();
              }),
              child: Container(
                decoration: BoxDecoration(
                  color: _useOtp ? AppColors.auction : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: Center(
                  child: Text(
                    'Login with OTP',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: _useOtp ? AppColors.white : AppColors.navy,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _useOtp = false;
                ref.read(authProvider.notifier).clearError();
              }),
              child: Container(
                decoration: BoxDecoration(
                  color: !_useOtp ? AppColors.auction : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: Center(
                  child: Text(
                    'Login with Password',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: !_useOtp ? AppColors.white : AppColors.navy,
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

  Widget _buildIdentifierModeToggle() {
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
              onTap: () => setState(() {
                _loginByEmail = true;
                _identifierController.clear();
                _identifierError = null;
                ref.read(authProvider.notifier).clearError();
              }),
              child: Container(
                decoration: BoxDecoration(
                  color: _loginByEmail ? AppColors.auction : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: Center(
                  child: Text(
                    'Email',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: _loginByEmail ? AppColors.white : AppColors.navy,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _loginByEmail = false;
                _identifierController.clear();
                _identifierError = null;
                ref.read(authProvider.notifier).clearError();
              }),
              child: Container(
                decoration: BoxDecoration(
                  color: !_loginByEmail
                      ? AppColors.auction
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: Center(
                  child: Text(
                    'Mobile',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: !_loginByEmail ? AppColors.white : AppColors.navy,
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
                  _identifierController.clear();
                  _passwordController.clear();
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
                  _identifierController.clear();
                  _passwordController.clear();
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
