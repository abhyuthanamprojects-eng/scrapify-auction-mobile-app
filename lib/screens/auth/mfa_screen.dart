import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';

class MfaScreen extends StatefulWidget {
  final String? redirectPath;
  const MfaScreen({super.key, this.redirectPath});

  @override
  State<MfaScreen> createState() => _MfaScreenState();
}

class _MfaScreenState extends State<MfaScreen> {
  final _codeCtl = TextEditingController();
  bool _trustDevice = true;
  bool _verifying = false;
  int _resendTimer = 45;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _resendTimer = 45);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendTimer > 0) {
        setState(() => _resendTimer--);
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeCtl.dispose();
    super.dispose();
  }

  void _verifyCode() {
    if (_codeCtl.text.trim().length < 6) return;
    setState(() => _verifying = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _verifying = false);
      context.go(widget.redirectPath ?? '/home');
    });
  }

  void _biometricAuth() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.fingerprint, size: 64, color: AppColors.auction),
            const SizedBox(height: 12),
            Text('Biometric Verification', style: AppTextStyles.heading(size: 18, weight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text('Touch sensor or look at screen for Face ID authentication', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.go(widget.redirectPath ?? '/home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusXl)),
                ),
                child: const Text('Simulate Biometric Success', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: AppBar(
        title: const Text('Enterprise Two-Factor Auth'),
        backgroundColor: AppColors.navy,
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
                border: Border.all(color: AppColors.cardBorder),
                boxShadow: AppColors.shadowSm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.navy.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shield_outlined, color: AppColors.navy, size: 32),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text('Enter Security Code', style: AppTextStyles.heading(size: 18, weight: FontWeight.w800)),
                  ),
                  const SizedBox(height: 6),
                  const Center(
                    child: Text(
                      'Enter the 6-digit code from Google Authenticator, Microsoft Authenticator, or registered SMS.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B), height: 1.4),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _codeCtl,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 8),
                    decoration: const InputDecoration(
                      counterText: '',
                      hintText: '• • • • • •',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Checkbox(
                        value: _trustDevice,
                        activeColor: AppColors.navy,
                        onChanged: (v) => setState(() => _trustDevice = v ?? true),
                      ),
                      const Expanded(
                        child: Text('Trust this corporate device for 30 days', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.navy)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _verifying ? null : _verifyCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navy,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusXl)),
                      ),
                      child: _verifying
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2))
                          : const Text('Verify & Proceed', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: _biometricAuth,
                      icon: const Icon(Icons.fingerprint, color: AppColors.auction, size: 22),
                      label: const Text('Use Face ID / Fingerprint', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.navy)),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusXl)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: _resendTimer == 0 ? _startTimer : null,
                      child: Text(
                        _resendTimer == 0 ? 'Resend Code via SMS' : 'Resend code in ${_resendTimer}s',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _resendTimer == 0 ? AppColors.auction : const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
