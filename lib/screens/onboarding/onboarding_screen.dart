import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/constants/asset_paths.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  static const _slides = [
    _SlideData(
      tag: 'Discover',
      title: 'Discover Opportunities',
      body:
          'Participate in verified auctions from leading enterprises across metals, machinery, IT assets, vehicles, logistics & services.',
      imagePath: AssetPaths.onboardFind,
      icon: Icons.search_rounded,
      iconColor: Color(0xFF1565C0),
    ),
    _SlideData(
      tag: 'Live Bidding',
      title: 'Bid in Real Time',
      body:
          'Securely participate in forward & reverse auctions with real-time ranking, anti-snipe timer extensions, and auto-bid proxy.',
      imagePath: AssetPaths.onboardBid,
      icon: Icons.gavel_rounded,
      iconColor: Color(0xFFF97316),
    ),
    _SlideData(
      tag: 'Full Lifecycle',
      title: 'Manage Everything',
      body:
          'Track EMD security, digital gate passes, awards, payments, evidence capture, and fulfilment from one seamless app.',
      imagePath: AssetPaths.onboardSecure,
      icon: Icons.verified_user_rounded,
      iconColor: Color(0xFF22C55E),
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header: SCRAPIFY dot + Skip
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPaddingH,
                vertical: AppSpacing.xl,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.auction,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.auctionWithOpacity(0.6),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'SCRAPIFY AUCTIONS',
                        style: AppTextStyles.body(
                          size: 12,
                          weight: FontWeight.w800,
                          color: AppColors.navy,
                        ).copyWith(letterSpacing: 2.5),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: Text(
                      'Skip',
                      style: AppTextStyles.body(
                        size: 14,
                        weight: FontWeight.w600,
                        color: AppColors.navyWithOpacity(0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Image card area
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, i) => _buildSlide(_slides[i]),
              ),
            ),

            // Bottom section
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPaddingH,
                0,
                AppSpacing.screenPaddingH,
                AppSpacing.xxl,
              ),
              child: Column(
                children: [
                  // Dot indicators
                  Row(
                    children: List.generate(_slides.length, _buildDot),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Next / Get Started button row
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _next,
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusXl),
                              border: Border.all(
                                color: AppColors.blackWithOpacity(0.05),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.blackWithOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              isLast ? 'Get Started' : 'Next',
                              style: AppTextStyles.body(
                                size: 15,
                                weight: FontWeight.w700,
                                color: AppColors.navy,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: _next,
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.auction,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusXl),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.auctionWithOpacity(0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: AppColors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Browse without signing in
                  GestureDetector(
                    onTap: () => context.go('/home'),
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      child: Text(
                        'Browse auctions without signing in →',
                        style: AppTextStyles.body(
                          size: 12,
                          weight: FontWeight.w600,
                          color: AppColors.navyWithOpacity(0.6),
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

  Widget _buildSlide(_SlideData slide) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card with gradient background, tag badges, and icon placeholder
          Container(
            width: double.infinity,
            height: 340,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                begin: Alignment(-1, -1),
                end: Alignment(1, 1),
                colors: [Color(0xFFEAF1FB), Color(0xFFF6F0E6)],
              ),
              border: Border.all(color: AppColors.blackWithOpacity(0.05)),
            ),
            child: Stack(
              children: [
                // Grid pattern overlay
                CustomPaint(
                  size: const Size(double.infinity, 340),
                  painter: _GridPainter(),
                ),
                // Tag badge (top-left)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.whiteWithOpacity(0.95),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                    child: Text(
                      slide.tag.toUpperCase(),
                      style: AppTextStyles.body(
                        size: 10,
                        weight: FontWeight.w700,
                        color: AppColors.auction,
                      ).copyWith(letterSpacing: 0.8),
                    ),
                  ),
                ),
                // LIVE badge (top-right)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.only(left: 8, right: 12, top: 6, bottom: 6),
                    decoration: BoxDecoration(
                      color: AppColors.navy,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.auction,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'LIVE',
                          style: AppTextStyles.body(
                            size: 10,
                            weight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Image with fallback icon
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Image.asset(
                      slide.imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Center(
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.whiteWithOpacity(0.7),
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: slide.iconColor.withValues(alpha: 0.2),
                                blurRadius: 40,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            slide.icon,
                            size: 56,
                            color: slide.iconColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          // Title
          Text(
            slide.title,
            style: AppTextStyles.heading(
              size: 26,
              weight: FontWeight.w900,
              color: AppColors.navy,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          // Body text
          Text(
            slide.body,
            style: AppTextStyles.body(
              size: 14,
              color: AppColors.navyWithOpacity(0.6),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    final isActive = index == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 6),
      width: isActive ? 32 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: isActive ? AppColors.auction : AppColors.navyWithOpacity(0.15),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class _SlideData {
  final String tag;
  final String title;
  final String body;
  final String imagePath;
  final IconData icon;
  final Color iconColor;

  const _SlideData({
    required this.tag,
    required this.title,
    required this.body,
    required this.imagePath,
    required this.icon,
    required this.iconColor,
  });
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0B1F3A).withValues(alpha: 0.05)
      ..strokeWidth = 1;
    const spacing = 32.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
