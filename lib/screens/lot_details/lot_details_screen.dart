import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../models/auction.dart';
import '../../providers/auction_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/shared/status_chip.dart';
import '../../widgets/shared/price_display.dart';
import '../../widgets/lot_details/clarifications_sheet.dart';

class LotDetailsScreen extends ConsumerStatefulWidget {
  final String lotId;
  const LotDetailsScreen({super.key, required this.lotId});

  @override
  ConsumerState<LotDetailsScreen> createState() => _LotDetailsScreenState();
}

class _LotDetailsScreenState extends ConsumerState<LotDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _tabs = const [
    'Overview',
    'Lots / Items',
    'Commercial',
    'Eligibility',
    'Timeline',
    'Docs',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auctionAsync = ref.watch(auctionDetailProvider(widget.lotId));
    final isWatchlisted = ref.watch(watchlistProvider).contains(widget.lotId);

    return auctionAsync.when(
      data: (auction) => _buildBody(context, auction, isWatchlisted),
      loading: () => Scaffold(
        backgroundColor: AppColors.appBg,
        appBar: AppBar(
          leading: const BackButton(),
          title: Text(widget.lotId, style: AppTextStyles.titleMedium),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.auction),
        ),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.appBg,
        appBar: AppBar(
          leading: const BackButton(),
          title: Text(widget.lotId, style: AppTextStyles.titleMedium),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 52,
                  color: AppColors.destructive,
                ),
                const SizedBox(height: 14),
                Text(
                  'Auction Not Found',
                  style: AppTextStyles.heading(
                    size: 18,
                    weight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'The requested auction "${widget.lotId}" could not be found or has ended.',
                  style: AppTextStyles.body(
                    size: 13,
                    color: AppColors.navyWithOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back, size: 16),
                      label: const Text('Go Back'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () =>
                          ref.invalidate(auctionDetailProvider(widget.lotId)),
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, Auction auction, bool isWatchlisted) {
    final isReverse = auction.isReverse;

    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Sliver App Bar with Media Carousel
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                backgroundColor: AppColors.navy,
                leading: Consumer(
                  builder: (context, ref, _) {
                    final isAuthenticated = ref
                        .watch(authProvider)
                        .isAuthenticated;
                    return isAuthenticated
                        ? GestureDetector(
                            onTap: () => context.pop(),
                            child: Container(
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.white.withValues(alpha: 0.9),
                                shape: BoxShape.circle,
                                boxShadow: AppColors.shadowSm,
                              ),
                              child: const Icon(
                                Icons.arrow_back,
                                size: 18,
                                color: AppColors.navy,
                              ),
                            ),
                          )
                        : const SizedBox.shrink();
                  },
                ),
                actions: [
                  GestureDetector(
                    onTap: () {
                      final isAuth = ref.read(authProvider).isAuthenticated;
                      if (!isAuth) {
                        _showLoginRequiredDialog(context);
                        return;
                      }
                      ref.read(watchlistProvider.notifier).toggle(auction.code);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 4,
                      ),
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isWatchlisted ? Icons.bookmark : Icons.bookmark_border,
                        size: 18,
                        color: isWatchlisted
                            ? AppColors.auction
                            : AppColors.navy,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Auction link copied: ${auction.code}'),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(
                        top: 8,
                        bottom: 8,
                        right: 14,
                        left: 4,
                      ),
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.share_outlined,
                        size: 18,
                        color: AppColors.navy,
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      auction.photos.isNotEmpty
                          ? Image.network(
                              auction.photos.first,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _mediaPlaceholder(),
                            )
                          : _mediaPlaceholder(),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.45),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 14,
                        left: 20,
                        right: 20,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.white.withValues(alpha: 0.95),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                auction.code,
                                style: AppTextStyles.mono,
                              ),
                            ),
                            AuctionTypeChip(direction: auction.direction),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Title & Core Summary Card
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(18),
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
                          if (auction.category != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.navy.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                auction.category!,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.navy,
                                ),
                              ),
                            ),
                          const Spacer(),
                          if (auction.isLive)
                            StatusChip.live()
                          else
                            StatusChip.fromStatus(auction.status.name),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        auction.title,
                        style: AppTextStyles.heading(
                          size: 18,
                          weight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.business,
                            size: 14,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 5),
                          Text(auction.company, style: AppTextStyles.caption),
                          if (auction.location != null) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: Color(0xFF64748B),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              auction.location!,
                              style: AppTextStyles.captionMuted,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Price & Countdown Banner
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.appBg,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusLg,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            PriceDisplay(
                              label: isReverse
                                  ? 'CURRENT L1 OFFER'
                                  : 'CURRENT HIGHEST BID',
                              amount: auction.currentHighestInr > 0
                                  ? auction.currentHighestInr
                                  : auction.startingPriceInr,
                              isReverse: isReverse,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'CLOSING IN',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.timer_outlined,
                                      size: 14,
                                      color: AppColors.auction,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      Formatters.formatCountdown(
                                        auction.secondsRemaining,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.auction,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Tab Selector Strip
              SliverToBoxAdapter(
                child: Container(
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0).withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    labelColor: AppColors.white,
                    unselectedLabelColor: AppColors.navyWithOpacity(0.6),
                    labelStyle: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                    indicator: BoxDecoration(
                      color: AppColors.navy,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerHeight: 0,
                    tabs: _tabs.map((t) => Tab(text: t)).toList(),
                  ),
                ),
              ),

              // Tab Content Area
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 14, 16, 120),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
                    border: Border.all(color: AppColors.cardBorder),
                    boxShadow: AppColors.shadowSm,
                  ),
                  child: AnimatedBuilder(
                    animation: _tabController,
                    builder: (ctx, _) {
                      switch (_tabController.index) {
                        case 0:
                          return _buildOverviewTab(auction);
                        case 1:
                          return _buildLotsTab(auction);
                        case 2:
                          return _buildCommercialTab(auction);
                        case 3:
                          return _buildEligibilityTab(auction);
                        case 4:
                          return _buildTimelineTab(auction);
                        case 5:
                          return _buildDocumentsTab(auction);
                        default:
                          return _buildOverviewTab(auction);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),

          // Contextual Bottom CTA
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildStickyBottomCTA(context, auction),
          ),
        ],
      ),
    );
  }

  Widget _mediaPlaceholder() {
    return Container(
      color: AppColors.navyDark,
      child: const Center(
        child: Icon(Icons.gavel_rounded, size: 60, color: AppColors.white),
      ),
    );
  }

  Widget _buildOverviewTab(Auction a) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tabSectionTitle('Event Description & Scope'),
        const SizedBox(height: 8),
        Text(
          a.description.isNotEmpty
              ? a.description
              : 'Detailed industrial auction lot. Inspection encouraged before participation. Material sold strictly on as-is where-is basis.',
          style: AppTextStyles.body(
            size: 13.5,
            color: AppColors.navy.withValues(alpha: 0.8),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 18),
        _tabSectionTitle('Key Parameters'),
        const SizedBox(height: 8),
        _keyValRow('Event ID', a.code),
        _keyValRow('Category', a.category ?? 'Industrial Asset'),
        _keyValRow('Auction Format', a.direction.toUpperCase()),
        _keyValRow('Quantity / Unit', '${a.quantity ?? '1'} ${a.uom ?? 'Lot'}'),
        _keyValRow('Plant / Location', a.location ?? 'Pan-India'),
        _keyValRow(
          'Inspection',
          a.inspectionRequired
              ? 'Mandatory Site Inspection'
              : 'Optional / Online BOQ',
        ),
        if (a.inspectionDate != null)
          _keyValRow('Inspection Window', a.inspectionDate!),
      ],
    );
  }

  Widget _buildLotsTab(Auction a) {
    if (a.subLots.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _tabSectionTitle('Single Consolidated Lot'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.appBg,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.inventory_2_outlined,
                  color: AppColors.navy,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.title, style: AppTextStyles.labelLarge),
                      const SizedBox(height: 2),
                      Text(
                        'Quantity: ${a.quantity ?? '1'} ${a.uom ?? 'Units'}',
                        style: AppTextStyles.captionMuted,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tabSectionTitle('Sub-Lots Breakdown (${a.subLots.length} Items)'),
        const SizedBox(height: 10),
        ...a.subLots.map(
          (sl) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.appBg,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.navy,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    sl.code,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(sl.name, style: AppTextStyles.labelMedium),
                      Text(
                        'Qty: ${sl.quantity ?? "1"} ${sl.uom ?? "Units"}',
                        style: AppTextStyles.captionMuted,
                      ),
                    ],
                  ),
                ),
                Text(
                  Formatters.formatINR(sl.currentBidInr),
                  style: AppTextStyles.labelLarge,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommercialTab(Auction a) {
    final isReverse = a.isReverse;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tabSectionTitle(
          isReverse ? 'Reverse Pricing Structure' : 'Forward Bidding Rules',
        ),
        const SizedBox(height: 10),
        _keyValRow(
          isReverse ? 'Opening Ceiling Price' : 'Starting Price',
          Formatters.formatINR(a.startingPriceInr),
        ),
        _keyValRow(
          isReverse ? 'Minimum Decrement Step' : 'Minimum Increment Step',
          Formatters.formatINR(isReverse ? a.decrementInr : a.bidIncrementInr),
        ),
        _keyValRow(
          'EMD Security Deposit',
          Formatters.formatINR(a.emdAmountInr),
        ),
        _keyValRow(
          'Reserve / Target Visibility',
          a.reserveNa ? 'Not Applicable' : 'Confidential (Admin Evaluated)',
        ),
        if (a.landedCosts.isNotEmpty) ...[
          const SizedBox(height: 14),
          _tabSectionTitle('Landed Cost Components'),
          const SizedBox(height: 6),
          ...a.landedCosts.map(
            (lc) => _keyValRow(lc.label, Formatters.formatINR(lc.amount)),
          ),
        ],
      ],
    );
  }

  Widget _buildEligibilityTab(Auction a) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tabSectionTitle('Bidder Qualification Checklist'),
        const SizedBox(height: 12),
        _eligibilityItem(
          'Company Registration & GST Verified',
          true,
          'Verified via GSTIN Portal',
        ),
        _eligibilityItem(
          'Category Authorization',
          true,
          'Eligible for ${a.category ?? "General Auctions"}',
        ),
        _eligibilityItem(
          'Auction Terms & Conditions',
          a.termsAccepted,
          a.termsAccepted
              ? 'Accepted v1.2'
              : 'Action Required: Acceptance Pending',
        ),
        _eligibilityItem(
          'EMD Security Escrow',
          a.emdPaid,
          a.emdPaid
              ? 'Locked in Escrow'
              : 'Deposit required before live bidding',
        ),
        if (a.inspectionRequired)
          _eligibilityItem(
            'Physical Site Inspection',
            false,
            'Book inspection slot prior to event',
          ),
      ],
    );
  }

  Widget _buildTimelineTab(Auction a) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tabSectionTitle('Event Schedule & Deadlines'),
        const SizedBox(height: 12),
        _timelineStep(
          'Inspection Window',
          a.inspectionDate ?? 'Not scheduled',
          true,
        ),
        _timelineStep(
          'Registration & EMD Cutoff',
          '2 hours prior to live start',
          true,
        ),
        _timelineStep(
          'Live Auction Start',
          a.scheduleStart ?? 'Not scheduled',
          a.isLive,
        ),
        _timelineStep(
          'Auction Closure & Sniping Extension',
          a.scheduleEnd ?? 'Not scheduled',
          false,
        ),
        _timelineStep(
          'Award Acceptance & 100% Settlement',
          'Within 48h of closure',
          false,
        ),
      ],
    );
  }

  Widget _buildDocumentsTab(Auction a) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tabSectionTitle('Tender Documents & Addenda'),
        const SizedBox(height: 10),
        _docTile(
          'Full Technical Specification & BOQ.pdf',
          '2.4 MB • Verified',
          Icons.picture_as_pdf,
        ),
        _docTile(
          'General Auction Terms & Lifting Policy.pdf',
          '1.1 MB • Legal Version 1.2',
          Icons.description,
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: () => ClarificationsSheet.show(
            context,
            auctionCode: a.code,
            auctionTitle: a.title,
          ),
          icon: const Icon(
            Icons.forum_outlined,
            size: 18,
            color: AppColors.navy,
          ),
          label: const Text(
            'Pre-Bid Clarifications & Q&A (2 Published)',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
            ),
          ),
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
          ),
        ),
        if (a.addenda.isNotEmpty) ...[
          const SizedBox(height: 14),
          _tabSectionTitle('Addenda & Corrigenda'),
          const SizedBox(height: 6),
          ...a.addenda.map(
            (ad) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.warning,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Addendum #${ad.number}: ${ad.title}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navy,
                          ),
                        ),
                        Text(
                          ad.description,
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: AppColors.navy,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _tabSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: AppColors.navy.withValues(alpha: 0.7),
        letterSpacing: 0.4,
      ),
    );
  }

  Widget _keyValRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _eligibilityItem(String title, bool isComplete, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isComplete
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked,
            color: isComplete ? AppColors.success : AppColors.auction,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelMedium),
                Text(subtitle, style: AppTextStyles.captionMuted),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _timelineStep(String label, String time, bool isDone) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDone
                  ? AppColors.success
                  : AppColors.navy.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: AppTextStyles.labelMedium)),
          Text(time, style: AppTextStyles.captionMuted),
        ],
      ),
    );
  }

  Widget _docTile(String name, String meta, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.appBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accentBlue, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                ),
                Text(meta, style: AppTextStyles.captionMuted),
              ],
            ),
          ),
          const Icon(Icons.download_rounded, size: 18, color: AppColors.navy),
        ],
      ),
    );
  }

  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.lock_outline, color: AppColors.auction, size: 24),
            const SizedBox(width: 10),
            const Text('Login Required'),
          ],
        ),
        titleTextStyle: AppTextStyles.heading(
          size: 18,
          weight: FontWeight.w800,
        ),
        content: const Text(
          'Please login or register to proceed with this action. You need an account to bid, accept terms, or participate in auctions.',
        ),
        contentTextStyle: const TextStyle(
          fontSize: 14,
          color: Color(0xFF64748B),
          height: 1.5,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.navyWithOpacity(0.6)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go('/onboarding');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.auction,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Login / Register'),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyBottomCTA(BuildContext context, Auction a) {
    final auth = ref.watch(authProvider);
    final isAuthenticated = auth.isAuthenticated;

    if (!isAuthenticated) {
      return Container(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          MediaQuery.of(context).padding.bottom + 12,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: const Border(top: BorderSide(color: AppColors.cardBorder)),
          boxShadow: AppColors.shadowLg,
        ),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => _showLoginRequiredDialog(context),
                  icon: const Icon(Icons.login, size: 18),
                  label: Text(
                    'Login to Proceed',
                    style: AppTextStyles.heading(
                      size: 14.5,
                      weight: FontWeight.w800,
                      color: AppColors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.auction,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (auth.isSeller) {
      return Container(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          MediaQuery.of(context).padding.bottom + 12,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: const Border(top: BorderSide(color: AppColors.cardBorder)),
          boxShadow: AppColors.shadowLg,
        ),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'Seller view: participation and bidding actions are unavailable.',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: () => context.push('/seller/auctions'),
              child: const Text('My auctions'),
            ),
          ],
        ),
      );
    }

    final isLive = a.isLive;

    String ctaLabel;
    VoidCallback onCta;
    Color buttonColor = AppColors.auction;

    if (!a.termsAccepted) {
      ctaLabel = 'Accept Terms & Conditions';
      onCta = () => context.push('/terms/${a.code}');
    } else if (a.inspectionRequired) {
      ctaLabel = 'Book Physical Inspection';
      onCta = () => context.push('/inspection/${a.code}');
    } else if (!a.emdPaid && a.emdAmountInr > 0) {
      ctaLabel = 'Lock EMD (${Formatters.formatINR(a.emdAmountInr)})';
      onCta = () => context.push('/emd/${a.code}');
    } else if (a.direction == 'rfq') {
      ctaLabel = 'Submit RFx / Technical Prequalification';
      buttonColor = AppColors.purple;
      onCta = () => context.push('/rfx/${a.code}');
    } else if (isLive) {
      ctaLabel = a.isReverse
          ? 'Enter Live Reverse Auction'
          : 'Enter Live Bidding Room';
      buttonColor = a.isReverse ? AppColors.accentBlue : AppColors.auction;
      onCta = () => context.push(
        a.isReverse ? '/live-reverse/${a.code}' : '/live/${a.code}',
      );
    } else {
      ctaLabel = 'View Auction Result';
      buttonColor = AppColors.navy;
      onCta = () => context.push('/won');
    }

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: const Border(top: BorderSide(color: AppColors.cardBorder)),
        boxShadow: AppColors.shadowLg,
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: onCta,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  ctaLabel,
                  style: AppTextStyles.heading(
                    size: 14.5,
                    weight: FontWeight.w800,
                    color: AppColors.white,
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
