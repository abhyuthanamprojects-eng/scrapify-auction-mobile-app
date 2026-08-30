import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/constants/app_constants.dart';

class FilterBottomSheet extends StatefulWidget {
  final String? initialCategory;
  final String? initialDirection;
  final String? initialStatus;
  final bool initialEmdOnly;
  final Function({
    String? category,
    String? direction,
    String? status,
    bool emdOnly,
  }) onApply;

  const FilterBottomSheet({
    super.key,
    this.initialCategory,
    this.initialDirection,
    this.initialStatus,
    this.initialEmdOnly = false,
    required this.onApply,
  });

  static void show(
    BuildContext context, {
    String? category,
    String? direction,
    String? status,
    bool emdOnly = false,
    required Function({
      String? category,
      String? direction,
      String? status,
      bool emdOnly,
    }) onApply,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterBottomSheet(
        initialCategory: category,
        initialDirection: direction,
        initialStatus: status,
        initialEmdOnly: emdOnly,
        onApply: onApply,
      ),
    );
  }

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String? _selectedCategory;
  late String? _selectedDirection;
  late String? _selectedStatus;
  late bool _emdOnly;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _selectedDirection = widget.initialDirection;
    _selectedStatus = widget.initialStatus;
    _emdOnly = widget.initialEmdOnly;
  }

  void _reset() {
    setState(() {
      _selectedCategory = null;
      _selectedDirection = null;
      _selectedStatus = null;
      _emdOnly = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.navyWithOpacity(0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Auctions',
                    style: AppTextStyles.heading(size: 18, weight: FontWeight.w800),
                  ),
                  TextButton(
                    onPressed: _reset,
                    child: Text(
                      'Reset All',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accentBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.cardBorder),
            // Body
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  _sectionTitle('Auction Format'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _choiceChip('All Formats', _selectedDirection == null, () {
                        setState(() => _selectedDirection = null);
                      }),
                      _choiceChip('Forward Auction', _selectedDirection == 'forward', () {
                        setState(() => _selectedDirection = 'forward');
                      }, icon: Icons.trending_up),
                      _choiceChip('Reverse Auction', _selectedDirection == 'reverse', () {
                        setState(() => _selectedDirection = 'reverse');
                      }, icon: Icons.trending_down),
                      _choiceChip('RFQ / Tender', _selectedDirection == 'rfq', () {
                        setState(() => _selectedDirection = 'rfq');
                      }, icon: Icons.request_quote_outlined),
                      _choiceChip('Multi-Lot', _selectedDirection == 'lot_wise', () {
                        setState(() => _selectedDirection = 'lot_wise');
                      }, icon: Icons.layers_outlined),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _sectionTitle('Category'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AppConstants.categories.map((c) {
                      final isAll = c == 'All Categories';
                      final selected = isAll
                          ? _selectedCategory == null
                          : _selectedCategory == c;
                      return _choiceChip(c, selected, () {
                        setState(() => _selectedCategory = isAll ? null : c);
                      });
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  _sectionTitle('Status'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _choiceChip('All', _selectedStatus == null, () {
                        setState(() => _selectedStatus = null);
                      }),
                      _choiceChip('Live Now', _selectedStatus == 'live', () {
                        setState(() => _selectedStatus = 'live');
                      }),
                      _choiceChip('Upcoming', _selectedStatus == 'upcoming', () {
                        setState(() => _selectedStatus = 'upcoming');
                      }),
                      _choiceChip('Closed', _selectedStatus == 'closed', () {
                        setState(() => _selectedStatus = 'closed');
                      }),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _sectionTitle('Security Requirements'),
                  const SizedBox(height: 8),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Requires EMD Security Deposit',
                      style: AppTextStyles.body(size: 13, weight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Show only lots requiring upfront earnest money',
                      style: AppTextStyles.captionMuted,
                    ),
                    value: _emdOnly,
                    activeColor: AppColors.auction,
                    onChanged: (v) => setState(() => _emdOnly = v),
                  ),
                ],
              ),
            ),
            // Footer CTA
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(
                      category: _selectedCategory,
                      direction: _selectedDirection,
                      status: _selectedStatus,
                      emdOnly: _emdOnly,
                    );
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.auction,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Apply Filters',
                    style: AppTextStyles.heading(size: 15, weight: FontWeight.w700, color: AppColors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: AppColors.navy.withValues(alpha: 0.6),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _choiceChip(String label, bool isSelected, VoidCallback onTap, {IconData? icon}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7.5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.navy : AppColors.appBg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? AppColors.navy : AppColors.cardBorder,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 13,
                color: isSelected ? AppColors.white : AppColors.navyWithOpacity(0.7),
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.white : AppColors.navy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
