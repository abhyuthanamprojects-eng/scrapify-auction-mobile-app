import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/asset_paths.dart';
import '../../providers/auth_provider.dart';
import '../../core/network/api_client.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _scaleUp;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _fadeIn = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.7, curve: Curves.easeOut),
      ),
    );
    _scaleUp = Tween(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.7, curve: Curves.easeOutBack),
      ),
    );
    _controller.forward();

    _restoreSessionAndNavigate();
  }

  Future<void> _restoreSessionAndNavigate() async {
    await Future.wait([
      ref.read(authProvider.notifier).checkSession(),
      Future<void>.delayed(const Duration(milliseconds: 2400)),
    ]);
    if (!mounted) return;
    final shouldContinue = await _checkForUpdate();
    if (!shouldContinue || !mounted) return;
    context.go(
      ref.read(authProvider).isAuthenticated ? '/home' : '/onboarding',
    );
  }

  Future<bool> _checkForUpdate() async {
    try {
      final config = await ApiClient().get('/platform-config');
      final latest = '${config['mobile_latest_version'] ?? '1.0.0'}';
      final minimum = '${config['mobile_min_version'] ?? '1.0.0'}';
      final current = '1.0.0';
      int compare(String a, String b) {
        final aa = a.split('.').map((v) => int.tryParse(v) ?? 0).toList();
        final bb = b.split('.').map((v) => int.tryParse(v) ?? 0).toList();
        for (var i = 0; i < 3; i++) { final d = (aa[i] - bb[i]); if (d != 0) return d; }
        return 0;
      }
      if (compare(current, latest) >= 0) return true;
      final url = '${config['mobile_update_url'] ?? ''}';
      if (url.isEmpty) return true;
      final force = config['mobile_force_update'] == true && compare(current, minimum) < 0;
      if (!mounted) return !force;
      final update = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 28, offset: Offset(0, 12))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 190,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFFD9DCFF), Color(0xFFB8C4FF)]),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Center(child: Image.asset(AssetPaths.appIcon, width: 112, height: 112)),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  child: Column(
                    children: [
                      const Text('App Update Required!', textAlign: TextAlign.center, style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: Colors.black87)),
                      const SizedBox(height: 14),
                      Text('${config['mobile_update_notes'] ?? 'We have added new features and fixed some bugs to make your experience seamless.'}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, height: 1.45, color: Color(0xFF424242))),
                      const SizedBox(height: 26),
                      SizedBox(width: double.infinity, height: 58, child: ElevatedButton(
                        onPressed: () async { await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication); },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5659BD), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 8, shadowColor: const Color(0x665659BD)),
                        child: const Text('Update App', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      return update ?? !force;
    } catch (_) { return true; }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradientNoir),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, _) => Opacity(
              opacity: _fadeIn.value,
              child: Transform.scale(
                scale: _scaleUp.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Brand Icon
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: AppColors.shadowGold,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.asset(
                          AssetPaths.appIcon,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          AppColors.goldSoft,
                          AppColors.white,
                          AppColors.auction,
                        ],
                      ).createShader(bounds),
                      child: Text(
                        AppConstants.appName,
                        style: AppTextStyles.heading(
                          size: 38,
                          weight: FontWeight.w900,
                          color: AppColors.white,
                          letterSpacing: -0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'ENTERPRISE AUCTION & PROCUREMENT',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.goldSoft.withValues(alpha: 0.9),
                        letterSpacing: 2.5,
                      ),
                    ),
                    const SizedBox(height: 48),
                    _LoadingDots(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingDots extends StatefulWidget {
  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final delay = i * 0.25;
          final value = (_ctrl.value - delay).clamp(0.0, 1.0);
          final opacity = (value < 0.5 ? value * 2 : 2 - value * 2).clamp(
            0.2,
            1.0,
          );
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.auction.withValues(alpha: opacity),
            ),
          );
        }),
      ),
    );
  }
}
