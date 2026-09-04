import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/shared/app_button.dart';
import '../../core/utils/file_picker_service.dart';
import '../../services/auction_service.dart';
import '../../providers/seller_provider.dart';

class CreateAuctionScreen extends ConsumerStatefulWidget {
  const CreateAuctionScreen({super.key});

  @override
  ConsumerState<CreateAuctionScreen> createState() => _CreateAuctionScreenState();
}

class _SubLotItem {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController reservePriceController = TextEditingController();
  String uom = 'MT';

  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    reservePriceController.dispose();
  }
}

class _CreateAuctionScreenState extends ConsumerState<CreateAuctionScreen> {
  final _auctionService = AuctionService();
  int _step = 0;
  bool _isSubmitting = false;

  // Step 1: Identification
  final _titleController = TextEditingController();
  final _companyController = TextEditingController(text: 'Sharma MetalWorks');
  final _plantController = TextEditingController(text: 'Jaipur Plant');
  final _warehouseController = TextEditingController(text: 'Warehouse A');
  final _locationController = TextEditingController(text: 'Jaipur, Rajasthan');
  String? _selectedCategory = 'Ferrous';

  // Step 2: Preparation
  String _auctionType = 'single'; // 'single' or 'lot_wise'
  final _materialTypeController = TextEditingController(text: 'MS Scrap Heavy Melting');
  final _quantityController = TextEditingController(text: '25');
  String _uom = 'MT';
  final List<_SubLotItem> _subLots = [];

  // Step 3: Inspection
  DateTime? _inspectionDate;
  final _inspectionDateController = TextEditingController();
  final _inspectionTimeController = TextEditingController();
  final _inspectionLocationController = TextEditingController();
  final _guidelinesController = TextEditingController();
  final List<PickedAttachment> _auctionPhotos = [];

  // Step 4: Details & Pricing
  DateTime? _scheduleStart;
  DateTime? _scheduleEnd;
  final _scheduleStartController = TextEditingController();
  final _scheduleEndController = TextEditingController();
  final _startingPriceController = TextEditingController(text: '500000');
  final _reservePriceController = TextEditingController(text: '550000');
  final _bidIncrementController = TextEditingController(text: '5000');
  final _emdAmountController = TextEditingController(text: '25000');
  final _paymentTermsController = TextEditingController(text: '100% advance before lifting');
  final _liftingPeriodController = TextEditingController(text: '7');
  String _liftingUnit = 'Days';
  final _termsController = TextEditingController(text: 'Standard auction terms & conditions apply.');
  final _contactNameController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _contactEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Default schedules: start in 24 hours, end in 48 hours
    final now = DateTime.now();
    _scheduleStart = now.add(const Duration(hours: 24));
    _scheduleEnd = now.add(const Duration(hours: 48));
    _scheduleStartController.text = DateFormat('yyyy-MM-dd HH:mm').format(_scheduleStart!);
    _scheduleEndController.text = DateFormat('yyyy-MM-dd HH:mm').format(_scheduleEnd!);

    _inspectionDate = now.add(const Duration(hours: 12));
    _inspectionDateController.text = DateFormat('yyyy-MM-dd').format(_inspectionDate!);
    _inspectionTimeController.text = '10:00 AM';
    _inspectionLocationController.text = _locationController.text;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _plantController.dispose();
    _warehouseController.dispose();
    _locationController.dispose();
    _materialTypeController.dispose();
    _quantityController.dispose();
    _inspectionDateController.dispose();
    _inspectionTimeController.dispose();
    _inspectionLocationController.dispose();
    _guidelinesController.dispose();
    _scheduleStartController.dispose();
    _scheduleEndController.dispose();
    _startingPriceController.dispose();
    _reservePriceController.dispose();
    _bidIncrementController.dispose();
    _emdAmountController.dispose();
    _paymentTermsController.dispose();
    _liftingPeriodController.dispose();
    _termsController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    _contactEmailController.dispose();
    for (final item in _subLots) {
      item.dispose();
    }
    super.dispose();
  }

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
              width: 36,
              height: 36,
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
        Text('Auction Title *', style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            hintText: 'e.g., Heavy Melting Scrap (HMS 1&2) - 25 MT',
          ),
        ),
        const SizedBox(height: 16),
        Text('Company / Entity Name *', style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        TextField(
          controller: _companyController,
          decoration: const InputDecoration(hintText: 'Operating company name'),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Plant / Facility', style: AppTextStyles.labelMedium),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _plantController,
                    decoration: const InputDecoration(hintText: 'e.g., Plant 1'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Warehouse / Yard', style: AppTextStyles.labelMedium),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _warehouseController,
                    decoration: const InputDecoration(hintText: 'e.g., Yard A'),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('City / State Location', style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        TextField(
          controller: _locationController,
          decoration: const InputDecoration(hintText: 'e.g., Jaipur, Rajasthan'),
        ),
        const SizedBox(height: 24),
        Text('Scrap Category *', style: AppTextStyles.labelMedium),
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
        Text('Auction Lot Structure', style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            _typeCard('Single Lot', 'Entire quantity in one single lot', 'single'),
            const SizedBox(width: 8),
            _typeCard('Lot-wise', 'Split material into multiple sub-lots', 'lot_wise'),
          ],
        ),
        const SizedBox(height: 16),
        Text('Material Description *', style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        TextField(
          controller: _materialTypeController,
          decoration: const InputDecoration(hintText: 'e.g., MS Scrap, Copper Wire, Mixed Ferrous'),
        ),
        const SizedBox(height: 16),
        if (_auctionType == 'single') ...[
          Text('Total Quantity & Unit *', style: AppTextStyles.labelMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _quantityController,
                  decoration: const InputDecoration(hintText: 'Quantity'),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 110,
                child: DropdownButtonFormField<String>(
                  value: _uom,
                  items: const [
                    DropdownMenuItem(value: 'MT', child: Text('MT')),
                    DropdownMenuItem(value: 'KG', child: Text('KG')),
                    DropdownMenuItem(value: 'Nos.', child: Text('Nos.')),
                  ],
                  onChanged: (v) => setState(() => _uom = v ?? 'MT'),
                  decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
                ),
              ),
            ],
          ),
        ] else ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sub-Lots (${_subLots.length})', style: AppTextStyles.labelMedium),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _subLots.add(_SubLotItem());
                  });
                },
                icon: const Icon(Icons.add, size: 16, color: AppColors.auction),
                label: const Text('Add Sub-Lot', style: TextStyle(color: AppColors.auction, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_subLots.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.navyWithOpacity(0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Center(
                child: Text('Click "Add Sub-Lot" to define multiple lots for this auction.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ),
            )
          else
            ...List.generate(_subLots.length, (i) {
              final item = _subLots[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.appBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Lot #${i + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.navy)),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                          onPressed: () => setState(() => _subLots.removeAt(i).dispose()),
                        ),
                      ],
                    ),
                    TextField(
                      controller: item.nameController,
                      decoration: const InputDecoration(hintText: 'Lot Name (e.g. Lot A: Clean Copper)'),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: item.quantityController,
                            decoration: const InputDecoration(hintText: 'Quantity'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 90,
                          child: DropdownButtonFormField<String>(
                            value: item.uom,
                            items: const [
                              DropdownMenuItem(value: 'MT', child: Text('MT')),
                              DropdownMenuItem(value: 'KG', child: Text('KG')),
                              DropdownMenuItem(value: 'Nos.', child: Text('Nos.')),
                            ],
                            onChanged: (v) => setState(() => item.uom = v ?? 'MT'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: item.reservePriceController,
                            decoration: const InputDecoration(hintText: 'Reserve ₹', prefixText: '₹'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ],
    );
  }

  Widget _step3Inspection() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Inspection Date', style: AppTextStyles.labelMedium),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _inspectionDateController,
                    readOnly: true,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _inspectionDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 90)),
                      );
                      if (picked != null) {
                        setState(() {
                          _inspectionDate = picked;
                          _inspectionDateController.text = DateFormat('yyyy-MM-dd').format(picked);
                        });
                      }
                    },
                    decoration: const InputDecoration(hintText: 'Select date', suffixIcon: Icon(Icons.calendar_today, size: 18)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Inspection Time', style: AppTextStyles.labelMedium),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _inspectionTimeController,
                    decoration: const InputDecoration(hintText: 'e.g. 10:00 AM - 4:00 PM'),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Inspection Location / Address', style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        TextField(
          controller: _inspectionLocationController,
          decoration: const InputDecoration(hintText: 'Exact premises or yard location for buyer inspection'),
        ),
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
        Text('Inspection Guidelines & Safety Protocols', style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        TextField(
          controller: _guidelinesController,
          decoration: const InputDecoration(hintText: 'Entry requirements, PPE rules, gate entry rules...'),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _step4Details() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Start Date & Time *', style: AppTextStyles.labelMedium),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _scheduleStartController,
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _scheduleStart ?? DateTime.now().add(const Duration(hours: 1)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 90)),
                      );
                      if (date != null && mounted) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(_scheduleStart ?? DateTime.now()),
                        );
                        if (time != null) {
                          setState(() {
                            _scheduleStart = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                            _scheduleStartController.text = DateFormat('yyyy-MM-dd HH:mm').format(_scheduleStart!);
                          });
                        }
                      }
                    },
                    decoration: const InputDecoration(hintText: 'Start time', suffixIcon: Icon(Icons.calendar_today, size: 18)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('End Date & Time *', style: AppTextStyles.labelMedium),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _scheduleEndController,
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _scheduleEnd ?? (_scheduleStart ?? DateTime.now()).add(const Duration(hours: 4)),
                        firstDate: _scheduleStart ?? DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 90)),
                      );
                      if (date != null && mounted) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: const TimeOfDay(hour: 17, minute: 0),
                        );
                        if (time != null) {
                          setState(() {
                            _scheduleEnd = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                            _scheduleEndController.text = DateFormat('yyyy-MM-dd HH:mm').format(_scheduleEnd!);
                          });
                        }
                      }
                    },
                    decoration: const InputDecoration(hintText: 'End time', suffixIcon: Icon(Icons.calendar_today, size: 18)),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Starting Price *', style: AppTextStyles.labelMedium),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _startingPriceController,
                    decoration: const InputDecoration(hintText: '₹ Amount', prefixText: '₹ '),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reserve Price', style: AppTextStyles.labelMedium),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _reservePriceController,
                    decoration: const InputDecoration(hintText: '₹ Amount', prefixText: '₹ '),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bid Increment *', style: AppTextStyles.labelMedium),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _bidIncrementController,
                    decoration: const InputDecoration(hintText: '₹ Amount', prefixText: '₹ '),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('EMD Deposit *', style: AppTextStyles.labelMedium),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emdAmountController,
                    decoration: const InputDecoration(hintText: '₹ Amount', prefixText: '₹ '),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Lifting Period', style: AppTextStyles.labelMedium),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _liftingPeriodController,
                    decoration: const InputDecoration(hintText: 'e.g., 7'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 110,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Unit', style: AppTextStyles.labelMedium),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _liftingUnit,
                    items: const [
                      DropdownMenuItem(value: 'Days', child: Text('Days')),
                      DropdownMenuItem(value: 'Weeks', child: Text('Weeks')),
                    ],
                    onChanged: (v) => setState(() => _liftingUnit = v ?? 'Days'),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Payment Terms', style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        TextField(
          controller: _paymentTermsController,
          decoration: const InputDecoration(hintText: 'e.g., 100% within 7 days of award'),
        ),
        const SizedBox(height: 16),
        Text('Terms & Conditions', style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        TextField(
          controller: _termsController,
          decoration: const InputDecoration(hintText: 'Additional terms...'),
          maxLines: 3,
        ),
      ],
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
              const SizedBox(height: 4),
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
        isLoading: _isSubmitting,
        onPressed: _isSubmitting ? null : () {
          if (_step == 0) {
            final title = _titleController.text.trim();
            final company = _companyController.text.trim();
            if (title.isEmpty || company.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter auction title and company name.')),
              );
              return;
            }
          }
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
        content: const Text('Your auction will be reviewed and approved by the compliance team before going live.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _submitAuction();
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitAuction() async {
    setState(() => _isSubmitting = true);
    try {
      final body = <String, dynamic>{
        'title': _titleController.text.trim().isNotEmpty
            ? _titleController.text.trim()
            : '${_materialTypeController.text.trim()} Scrap Disposal',
        'company': _companyController.text.trim().isNotEmpty
            ? _companyController.text.trim()
            : 'Enterprise Seller',
        'category': _selectedCategory ?? 'Ferrous',
        'direction': 'forward',
        'lot_type': _auctionType,
        'plant': _plantController.text.trim(),
        'warehouse': _warehouseController.text.trim(),
        'location': _locationController.text.trim(),
        'material_type': _materialTypeController.text.trim(),
        'quantity': _quantityController.text.trim(),
        'uom': _uom,
        'starting_price': double.tryParse(_startingPriceController.text.trim()) ?? 0,
        'reserve_price': double.tryParse(_reservePriceController.text.trim()),
        'bid_increment': double.tryParse(_bidIncrementController.text.trim()) ?? 1000,
        'emd_amount': double.tryParse(_emdAmountController.text.trim()) ?? 10000,
        'schedule_start': _scheduleStart?.toIso8601String() ?? DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
        'schedule_end': _scheduleEnd?.toIso8601String() ?? DateTime.now().add(const Duration(hours: 48)).toIso8601String(),
        'inspection_date': _inspectionDateController.text.trim(),
        'inspection_time': _inspectionTimeController.text.trim(),
        'inspection_location': _inspectionLocationController.text.trim(),
        'guidelines_doc': _guidelinesController.text.trim(),
        'terms': _termsController.text.trim(),
        'payment_terms': _paymentTermsController.text.trim(),
        'lifting_period': _liftingPeriodController.text.trim(),
        'lifting_unit': _liftingUnit,
        'status': 'pending_approval',
      };

      if (_auctionType == 'lot_wise' && _subLots.isNotEmpty) {
        body['sub_lots'] = _subLots.map((item) => {
          'name': item.nameController.text.trim().isNotEmpty ? item.nameController.text.trim() : 'Lot Material',
          'quantity': item.quantityController.text.trim().isNotEmpty ? item.quantityController.text.trim() : '1',
          'uom': item.uom,
          'reserve_price': double.tryParse(item.reservePriceController.text.trim()),
        }).toList();
      }

      final created = await _auctionService.create(body);

      // Invalidate seller auctions provider to refresh list
      ref.invalidate(sellerAuctionsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Auction #${created.code} submitted successfully for review!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit auction: $e'),
            backgroundColor: AppColors.destructive,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

