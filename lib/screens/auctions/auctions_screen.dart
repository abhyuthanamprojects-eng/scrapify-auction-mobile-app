import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../providers/auction_provider.dart';
import '../../widgets/cards/auction_card.dart';
import '../../widgets/shared/filter_bottom_sheet.dart';
import '../../widgets/shared/loading_skeleton.dart';
import '../../widgets/shared/empty_state.dart';

class AuctionsScreen extends ConsumerStatefulWidget {
  const AuctionsScreen({super.key});

  @override
  ConsumerState<AuctionsScreen> createState() => _AuctionsScreenState();
}

class _AuctionsScreenState extends ConsumerState<AuctionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _filterCategory;
  String? _filterDirection;
  String? _filterStatus;
  bool _filterEmdOnly = false;

  final _tabs = const ['All', 'Live', 'Upcoming', 'Invited', 'Completed'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  int get _activeFiltersCount {
    int count = 0;
    if (_filterCategory != null) count++;
    if (_filterDirection != null) count++;
    if (_filterStatus != null) count++;
    if (_filterEmdOnly) count++;
    return count;
  }

  void _openFilters() {
    FilterBottomSheet.show(
      context,
      category: _filterCategory,
      direction: _filterDirection,
      status: _filterStatus,
      emdOnly: _filterEmdOnly,
      onApply: ({category, direction, status, emdOnly = false}) {
        setState(() {
          _filterCategory = category;
          _filterDirection = direction;
          _filterStatus = status;
          _filterEmdOnly = emdOnly;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Explore Auctions',
                    style: AppTextStyles.heading(size: 22, weight: FontWeight.w900),
                  ),
                  GestureDetector(
                    onTap: _openFilters,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: _activeFiltersCount > 0 ? AppColors.auction : AppColors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: _activeFiltersCount > 0 ? AppColors.auction : AppColors.cardBorder,
                        ),
                        boxShadow: AppColors.shadowSm,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.tune_rounded,
                            size: 15,
                            color: _activeFiltersCount > 0 ? AppColors.white : AppColors.navy,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _activeFiltersCount > 0 ? 'Filters ($_activeFiltersCount)' : 'Filter',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _activeFiltersCount > 0 ? AppColors.white : AppColors.navy,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(color: AppColors.cardBorder),
                  boxShadow: AppColors.shadowSm,
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: const TextStyle(fontSize: 13.5, color: AppColors.navy),
                  decoration: InputDecoration(
                    hintText: 'Search by title, event ID, material...',
                    hintStyle: TextStyle(fontSize: 13, color: AppColors.navyWithOpacity(0.4)),
                    prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF64748B)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                            child: const Icon(Icons.clear, size: 16, color: Color(0xFF64748B)),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0).withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(999),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.white,
                unselectedLabelColor: AppColors.navyWithOpacity(0.65),
                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                indicator: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: AppColors.shadowSm,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerHeight: 0,
                tabs: _tabs.map((t) => Tab(text: t)).toList(),
              ),
            ),
            const SizedBox(height: 10),
            // Tab View List
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTabList(status: null),
                  _buildTabList(status: 'live'),
                  _buildTabList(status: 'upcoming'),
                  _buildTabList(isInvited: true),
                  _buildTabList(status: 'closed'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabList({String? status, bool isInvited = false}) {
    final filter = AuctionFilter(
      status: _filterStatus ?? status,
      category: _filterCategory,
      direction: _filterDirection,
      search: _searchQuery,
      emdOnly: _filterEmdOnly,
    );

    final auctionsAsync = ref.watch(auctionsProvider(filter));

    return auctionsAsync.when(
      data: (auctions) {
        var list = auctions;
        if (isInvited) {
          list = auctions.where((a) => a.isInvited || a.code.contains('1048') || a.code.contains('0872')).toList();
        }
        if (list.isEmpty) {
          return Center(
            child: EmptyState(
              icon: Icons.gavel_rounded,
              title: 'No auctions found',
              subtitle: 'Try adjusting your search query or removing active filters',
              actionLabel: _activeFiltersCount > 0 ? 'Clear Filters' : null,
              onAction: _activeFiltersCount > 0
                  ? () => setState(() {
                        _filterCategory = null;
                        _filterDirection = null;
                        _filterStatus = null;
                        _filterEmdOnly = false;
                        _searchController.clear();
                        _searchQuery = '';
                      })
                  : null,
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 90),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (ctx, i) {
            final a = list[i];
            return AuctionCard(
              auction: a,
              onTap: () => context.push(
                a.direction == 'reverse'
                    ? '/live-reverse/${a.code}'
                    : '/lot/${a.code}',
              ),
            );
          },
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: ListSkeleton(count: 3),
      ),
      error: (e, _) => Center(
        child: Text('Failed to load events: $e', style: AppTextStyles.caption),
      ),
    );
  }
}
