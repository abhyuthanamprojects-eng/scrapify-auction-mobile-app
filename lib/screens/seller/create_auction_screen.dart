import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/shared/app_button.dart';
import '../../core/utils/file_picker_service.dart';

class CreateAuctionScreen extends StatefulWidget {
  const CreateAuctionScreen({super.key});

  @override
  State<CreateAuctionScreen> createState() => _CreateAuctionScreenState();
}

class _CreateAuctionScreenState extends State<CreateAuctionScreen> {
  int _step = 0;
  String? _selectedCategory;
  String _auctionType = 'normal';
  final List<PickedAttachment> _auctionPhotos = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildProgressBar(),
            Expanded(child: _buildStepContent()),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final titles = ['Identification', 'Preparation', 'Inspection', 'Details'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenPaddingH, 8, AppSpacing.screenPaddingH, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _step > 0 ? setState(() => _step--) : context.pop(),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: AppColors.navyWithOpacity(0.05), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.arrow_back, size: 18, color: AppColors.navy),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create Auction', style: AppTextStyles.titleSmall),
              Text('Step ${_step + 1}: ${titles[_step]}', style: AppTextStyles.captionMuted),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenPaddingH, 16, AppSpacing.screenPaddingH, 8),
      child: Row(
        children: List.generate(4, (i) => Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
            decoration: BoxDecoration(
              color: i <= _step ? AppColors.auction : AppColors.navyWithOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        )),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 0:
        return _step1Identification();
      case 1:
        return _step2Preparation();
      case 2:
        return _step3Inspection();
      case 3:
        return _step4Details();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _step1Identification() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
      children: [
        Text('Select Company', style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        _dropdown('Sharma MetalWorks'),
        const SizedBox(height: 16),
        Text('Select Plant', style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        _dropdown('Jaipur Plant'),
        const SizedBox(height: 16),
        Text('Select Warehouse', style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        _dropdown('Warehouse A'),
        const SizedBox(height: 24),
        Text('Scrap Category', style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: AppConstants.categories.map((c) => _categoryTile(c)).toList(),
        ),
      ],
    );
  }

  Widget _step2Preparation() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
      children: [
        Text('Auction Type', style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            _typeCard('Normal', 'Single lot auction', 'normal'),
            const SizedBox(width: 8),
            _typeCard('Lot-wise', 'Multiple sub-lots', 'lotwise'),
          ],
        ),
        const SizedBox(height: 16),
        Text('Material Type', style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        const TextField(decoration: InputDecoration(hintText: 'e.g., MS Scrap, Copper Wire')),
        const SizedBox(height: 16),
        Text('Quantity', style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            const Expanded(child: TextField(decoration: InputDecoration(hintText: 'Amount'), keyboardType: TextInputType.number)),
            const SizedBox(width: 8),
            SizedBox(width: 100, child: _dropdown('MT')),
          ],
        ),
      ],
    );
  }

  Widget _step3Inspection() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
      children: [
        Text('Inspection Date & Time', style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        const TextField(decoration: InputDecoration(hintText: 'Select date', suffixIcon: Icon(Icons.calendar_today, size: 18))),
        const SizedBox(height: 16),
        Text('Location', style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        const TextField(decoration: InputDecoration(hintText: 'Inspection location')),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Lot & Inspection Photos (${_auctionPhotos.length}/6)', style: AppTextStyles.labelMedium),
            TextButton.icon(
              onPressed: () async {
                final photos = await AppFilePicker.pickMultiImages();
                if (photos.isNotEmpty) {
                  setState(() {
                    _auctionPhotos.addAll(photos);
                    if (_auctionPhotos.length > 6) {
                      _auctionPhotos.removeRange(6, _auctionPhotos.length);
                    }
                  });
                }
              },
              icon: const Icon(Icons.add_photo_alternate_outlined, size: 16, color: AppColors.auction),
              label: const Text('Add Photos', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.auction)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 90,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ..._auctionPhotos.map((p) => Stack(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: p.path != null
                        ? Image.file(File(p.path!), fit: BoxFit.cover)
                        : const Center(child: Icon(Icons.image, color: AppColors.navy)),
                  ),
                  Positioned(
                    top: 4,
                    right: 12,
                    child: GestureDetector(
                      onTap: () => setState(() => _auctionPhotos.remove(p)),
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 14),
                      ),
                    ),
                  ),
                ],
              )),
              if (_auctionPhotos.length < 6)
                GestureDetector(
                  onTap: () async {
                    final photo = await AppFilePicker.showPickerBottomSheet(context, title: 'Add Auction Photo');
                    if (photo != null) {
                      setState(() => _auctionPhotos.add(photo));
                    }
                  },
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: AppColors.navyWithOpacity(0.04),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: AppColors.navyWithOpacity(0.15), style: BorderStyle.solid),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined, size: 24, color: AppColors.navyWithOpacity(0.5)),
                        const SizedBox(height: 4),
                        Text('Add Photo', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.navyWithOpacity(0.6))),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('Guidelines', style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        const TextField(decoration: InputDecoration(hintText: 'Any special inspection guidelines...'), maxLines: 3),
      ],
    );
  }

  Widget _step4Details() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
      children: [
        Text('Auction Schedule', style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        const TextField(decoration: InputDecoration(hintText: 'Auction date & time', suffixIcon: Icon(Icons.calendar_today, size: 18))),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reserve Price', style: AppTextStyles.labelMedium),
                  const SizedBox(height: 8),
                  const TextField(decoration: InputDecoration(hintText: '₹ Amount', prefixText: '₹ '), keyboardType: TextInputType.number),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bid Increment', style: AppTextStyles.labelMedium),
                  const SizedBox(height: 8),
                  const TextField(decoration: InputDecoration(hintText: '₹ Amount', prefixText: '₹ '), keyboardType: TextInputType.number),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('EMD Amount', style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        const TextField(decoration: InputDecoration(hintText: '₹ Amount', prefixText: '₹ '), keyboardType: TextInputType.number),
        const SizedBox(height: 16),
        Text('Payment Terms', style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        const TextField(decoration: InputDecoration(hintText: 'e.g., 100% within 7 days of award')),
        const SizedBox(height: 16),
        Text('Terms & Conditions', style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        const TextField(decoration: InputDecoration(hintText: 'Additional terms...'), maxLines: 3),
      ],
    );
  }

  Widget _dropdown(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.appBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.blackWithOpacity(0.05)),
      ),
      child: Row(
        children: [
          Text(value, style: AppTextStyles.bodyMedium),
          const Spacer(),
          Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.navyWithOpacity(0.5)),
        ],
      ),
    );
  }

  Widget _categoryTile(String category) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = category),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.auction.withValues(alpha: 0.1) : AppColors.navyWithOpacity(0.03),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: isSelected ? AppColors.auction : AppColors.blackWithOpacity(0.05)),
        ),
        child: Center(
          child: Text(
            category,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isSelected ? AppColors.auction : AppColors.navy),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _typeCard(String title, String desc, String value) {
    final isSelected = _auctionType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _auctionType = value),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.auction.withValues(alpha: 0.05) : AppColors.appBg,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: isSelected ? AppColors.auction : AppColors.blackWithOpacity(0.05), width: isSelected ? 2 : 1),
          ),
          child: Column(
            children: [
              Text(title, style: AppTextStyles.labelMedium.copyWith(color: isSelected ? AppColors.auction : AppColors.navy)),
              Text(desc, style: AppTextStyles.captionMuted, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
      child: AppButton(
        label: _step < 3 ? 'Continue' : 'Submit for Review',
        onPressed: () {
          if (_step < 3) {
            setState(() => _step++);
          } else {
            _showConfirmation();
          }
        },
      ),
    );
  }

  void _showConfirmation() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Submit Auction?'),
        content: const Text('Your auction will be reviewed by admin before going live.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Auction submitted for review'), backgroundColor: AppColors.success),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
