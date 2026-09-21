import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/shared/app_button.dart';
import '../../core/utils/file_picker_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/network/api_config.dart';
import '../../core/network/api_endpoints.dart';
import '../../services/auction_service.dart';
import '../../services/pincode_service.dart';
import '../../services/template_service.dart';
import '../../models/auction_template.dart';
import '../../providers/seller_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/category_provider.dart';
import '../../models/category.dart';

class CreateAuctionScreen extends ConsumerStatefulWidget {
  const CreateAuctionScreen({super.key});

  @override
  ConsumerState<CreateAuctionScreen> createState() =>
      _CreateAuctionScreenState();
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
  final _pincodeService = PincodeService();
  Timer? _pincodeLookupTimer;
  int _pincodeLookupRequest = 0;
  bool _pincodeLoading = false;
  int _step = 0;
  bool _isSubmitting = false;
  String? _createdAuctionCode;

  // Step 1: Identification
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _plantController = TextEditingController();
  final _warehouseController = TextEditingController();
  final _warehouseAddressController = TextEditingController();
  final _warehouseCityController = TextEditingController();
  final _warehouseStateController = TextEditingController();
  final _warehousePincodeController = TextEditingController();
  final _warehouseContactController = TextEditingController();
  final _locationController = TextEditingController();
  Category? _selectedCategory;
  Category? _selectedSubcategory;
  String _direction = 'forward';

  // Template state
  final _templateService = TemplateService();
  AuctionTemplate? _templateInfo;
  bool _templateLoading = false;
  int? _lastTemplateCategoryId;
  String? _templateFilePath;
  String? _templateFileName;
  TemplateUploadResult? _templateUploadResult;
  bool _templateUploading = false;
  bool _templateDownloading = false;

  // Auction Document uploads (PDF)
  final Map<String, PickedAttachment?> _docFiles = {
    'catalog': null,
    'tnc': null,
    'photographs': null,
  };
  final Map<String, bool> _docUploading = {
    'catalog': false,
    'tnc': false,
    'photographs': false,
  };
  final Map<String, bool> _docUploaded = {
    'catalog': false,
    'tnc': false,
    'photographs': false,
  };

  // Step 2: Preparation
  String _auctionType = 'single'; // 'single' or 'lot_wise'
  final _materialTypeController = TextEditingController(
    text: 'MS Scrap Heavy Melting',
  );
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
  final _paymentTermsController = TextEditingController(
    text: '100% advance before lifting',
  );
  final _liftingPeriodController = TextEditingController(text: '7');
  String _liftingUnit = 'Days';
  final _termsController = TextEditingController(
    text: 'Standard auction terms & conditions apply.',
  );
  final _contactNameController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _initialSlotMinutesController = TextEditingController(text: '30');
  final _continuationSlotMinutesController = TextEditingController(text: '2');
  final _maximumDurationMinutesController = TextEditingController(text: '120');

  @override
  void initState() {
    super.initState();
    // Auto-fill company name from vendor profile
    final user = ref.read(authProvider).user;
    final vendorCompany = user?.companyName;
    if (vendorCompany != null && vendorCompany.isNotEmpty) {
      _companyController.text = vendorCompany;
    }

    // Default schedule: a maximum two-hour auction window.
    final now = DateTime.now();
    _scheduleStart = now.add(const Duration(hours: 24));
    _scheduleEnd = _scheduleStart!.add(const Duration(minutes: 120));
    _scheduleStartController.text = DateFormat(
      'yyyy-MM-dd HH:mm',
    ).format(_scheduleStart!);
    _scheduleEndController.text = DateFormat(
      'yyyy-MM-dd HH:mm',
    ).format(_scheduleEnd!);

    _inspectionDate = now.add(const Duration(hours: 12));
    _inspectionDateController.text = DateFormat(
      'yyyy-MM-dd',
    ).format(_inspectionDate!);
    _inspectionTimeController.text = '10:00 AM';
    _inspectionLocationController.text = _locationController.text;
  }

  @override
  void dispose() {
    _pincodeLookupTimer?.cancel();
    _titleController.dispose();
    _companyController.dispose();
    _plantController.dispose();
    _warehouseController.dispose();
    _warehouseAddressController.dispose();
    _warehouseCityController.dispose();
    _warehouseStateController.dispose();
    _warehousePincodeController.dispose();
    _warehouseContactController.dispose();
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
    _initialSlotMinutesController.dispose();
    _continuationSlotMinutesController.dispose();
    _maximumDurationMinutesController.dispose();
    for (final item in _subLots) {
      item.dispose();
    }
    super.dispose();
  }

  void _lookupWarehousePincode(String value) {
    _pincodeLookupTimer?.cancel();
    final pincode = value.trim();
    if (pincode.length != 6 || !RegExp(r'^[1-9]\d{5}$').hasMatch(pincode)) {
      if (_pincodeLoading && mounted) {
        setState(() => _pincodeLoading = false);
      }
      return;
    }

    final request = ++_pincodeLookupRequest;
    setState(() => _pincodeLoading = true);
    _pincodeLookupTimer = Timer(const Duration(milliseconds: 400), () async {
      final result = await _pincodeService.lookup(pincode);
      if (!mounted || request != _pincodeLookupRequest) return;
      setState(() => _pincodeLoading = false);
      if (result == null) return;

      _warehouseCityController.text = result.city;
      _warehouseStateController.text = result.state;
      _locationController.text = '${result.city}, ${result.state}';
      if (_inspectionLocationController.text.trim().isEmpty ||
          _inspectionLocationController.text == _locationController.text) {
        _inspectionLocationController.text = _locationController.text;
      }
    });
  }

  void _fetchTemplateForCategory() {
    final catId = _selectedSubcategory?.id ?? _selectedCategory?.id;
    if (catId == null || catId == _lastTemplateCategoryId) return;
    _lastTemplateCategoryId = catId;
    setState(() {
      _templateLoading = true;
      _templateInfo = null;
      _templateFilePath = null;
      _templateFileName = null;
      _templateUploadResult = null;
    });
    _templateService
        .getTemplate(catId, direction: _direction)
        .then((t) {
      if (mounted) setState(() => _templateInfo = t);
    }).catchError((_) {
      // No template for this category — that's OK
    }).whenComplete(() {
      if (mounted) setState(() => _templateLoading = false);
    });
  }

  Future<void> _downloadTemplate() async {
    if (_templateInfo == null || _templateDownloading) return;
    setState(() => _templateDownloading = true);
    try {
      final url = Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}${Endpoints.templateDownload(_templateInfo!.id)}',
      );
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open download link.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e'), backgroundColor: AppColors.destructive),
        );
      }
    } finally {
      if (mounted) setState(() => _templateDownloading = false);
    }
  }

  Future<void> _pickAndUploadTemplate() async {
    if (_templateUploading || _templateInfo == null || _createdAuctionCode == null) return;
    setState(() => _templateUploading = true);

    final picked = await AppFilePicker.pickDocument(
      allowedExtensions: ['xlsx', 'xls', 'csv'],
    );
    if (picked == null || picked.path == null) {
      if (mounted) setState(() => _templateUploading = false);
      return;
    }

    _templateFilePath = picked.path;
    _templateFileName = picked.name;
    setState(() => _templateUploadResult = null);

    try {
      final result = await _templateService.uploadTemplate(
        auctionCode: _createdAuctionCode!,
        templateId: _templateInfo!.id,
        filePath: picked.path!,
        fileName: picked.name,
      );
      if (mounted) setState(() => _templateUploadResult = result);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e'), backgroundColor: AppColors.destructive),
        );
      }
    } finally {
      if (mounted) setState(() => _templateUploading = false);
    }
  }

  double _parseNum(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    final cleaned = value.toString().replaceAll(RegExp(r'[,₹$ ]'), '');
    return double.tryParse(cleaned) ?? 0;
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
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPaddingH,
        8,
        AppSpacing.screenPaddingH,
        0,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _step > 0 ? setState(() => _step--) : context.pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.navyWithOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back,
                size: 18,
                color: AppColors.navy,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create Auction', style: AppTextStyles.titleSmall),
              Text(
                'Step ${_step + 1}: ${titles[_step]}',
                style: AppTextStyles.captionMuted,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPaddingH,
        16,
        AppSpacing.screenPaddingH,
        8,
      ),
      child: Row(
        children: List.generate(
          4,
          (i) => Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
              decoration: BoxDecoration(
                color: i <= _step
                    ? AppColors.auction
                    : AppColors.navyWithOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
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
          readOnly: ref.read(authProvider).user?.companyName?.isNotEmpty == true,
          enabled: ref.read(authProvider).user?.companyName?.isNotEmpty != true,
          decoration: InputDecoration(
            hintText: 'Operating company name',
            helperText: ref.read(authProvider).user?.companyName?.isNotEmpty == true
                ? 'From your registered profile'
                : null,
            helperStyle: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(height: 16),
        Text('Auction Direction *', style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _direction,
          items: const [
            DropdownMenuItem(value: 'forward', child: Text('Forward auction')),
            DropdownMenuItem(value: 'reverse', child: Text('Reverse auction')),
          ],
          onChanged: (value) => setState(() => _direction = value ?? 'forward'),
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
                    decoration: const InputDecoration(
                      hintText: 'e.g., Plant 1',
                    ),
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
          decoration: const InputDecoration(
            hintText: 'e.g., Jaipur, Rajasthan',
          ),
        ),
        const SizedBox(height: 16),
        Text('Warehouse Details', style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        TextField(
          controller: _warehouseAddressController,
          decoration: const InputDecoration(
            hintText: 'Full warehouse / yard address',
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _warehousePincodeController,
                decoration: const InputDecoration(hintText: 'Pincode'),
                keyboardType: TextInputType.number,
                maxLength: 6,
                onChanged: _lookupWarehousePincode,
                buildCounter:
                    (
                      _, {
                      required currentLength,
                      required isFocused,
                      maxLength,
                    }) => _pincodeLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _warehouseContactController,
                decoration: const InputDecoration(
                  hintText: 'Contact',
                ),
                keyboardType: TextInputType.phone,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _warehouseCityController,
                decoration: const InputDecoration(hintText: 'City'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _warehouseStateController,
                decoration: const InputDecoration(hintText: 'State'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text('Scrap Category *', style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        _buildCategoryDropdowns(),
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
            _typeCard(
              'Single Lot',
              'Entire quantity in one single lot',
              'single',
            ),
            const SizedBox(width: 8),
            _typeCard(
              'Lot-wise',
              'Split material into multiple sub-lots',
              'lot_wise',
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Material Description *', style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        TextField(
          controller: _materialTypeController,
          decoration: const InputDecoration(
            hintText: 'e.g., MS Scrap, Copper Wire, Mixed Ferrous',
          ),
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
                  initialValue: _uom,
                  items: const [
                    DropdownMenuItem(value: 'MT', child: Text('MT')),
                    DropdownMenuItem(value: 'KG', child: Text('KG')),
                    DropdownMenuItem(value: 'Nos.', child: Text('Nos.')),
                  ],
                  onChanged: (v) => setState(() => _uom = v ?? 'MT'),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ] else ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sub-Lots (${_subLots.length})',
                style: AppTextStyles.labelMedium,
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _subLots.add(_SubLotItem());
                  });
                },
                icon: const Icon(Icons.add, size: 16, color: AppColors.auction),
                label: const Text(
                  'Add Sub-Lot',
                  style: TextStyle(
                    color: AppColors.auction,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
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
                child: Text(
                  'Click "Add Sub-Lot" to define multiple lots for this auction.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
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
                        Text(
                          'Lot #${i + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.navy,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Colors.red,
                          ),
                          onPressed: () =>
                              setState(() => _subLots.removeAt(i).dispose()),
                        ),
                      ],
                    ),
                    TextField(
                      controller: item.nameController,
                      decoration: const InputDecoration(
                        hintText: 'Lot Name (e.g. Lot A: Clean Copper)',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: item.quantityController,
                            decoration: const InputDecoration(
                              hintText: 'Quantity',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 86,
                          child: DropdownButtonFormField<String>(
                            initialValue: item.uom,
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(value: 'MT', child: Text('MT')),
                              DropdownMenuItem(value: 'KG', child: Text('KG')),
                              DropdownMenuItem(
                                value: 'Nos.',
                                child: Text('Nos.'),
                              ),
                            ],
                            onChanged: (v) =>
                                setState(() => item.uom = v ?? 'MT'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: item.reservePriceController,
                            decoration: const InputDecoration(
                              hintText: 'Reserve ₹',
                              prefixText: '₹',
                            ),
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

        // ---- Template Download / Upload Section ----
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        Text('Import from Template', style: AppTextStyles.labelMedium),
        const SizedBox(height: 4),
        Text(
          'Download the Excel template for your selected category, fill in your product details & prices, then upload it here.',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),

        if (_templateLoading)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.navyWithOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: const Row(
              children: [
                SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                SizedBox(width: 12),
                Text('Checking for category template...', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),

        if (!_templateLoading && _selectedCategory != null && _templateInfo == null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.amber.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'No official template available for ${_selectedCategory?.name ?? 'this category'}. Add lots manually above.',
                    style: TextStyle(fontSize: 12, color: Colors.amber.shade800),
                  ),
                ),
              ],
            ),
          ),

        if (_templateInfo != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.navyWithOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.navyWithOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.description_outlined, size: 18, color: AppColors.navy),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _templateInfo!.name,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.navy),
                          ),
                          if (_templateInfo!.version.isNotEmpty)
                            Text('v${_templateInfo!.version}', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Download button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _templateDownloading ? null : _downloadTemplate,
                    icon: _templateDownloading
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.download, size: 16),
                    label: Text(_templateDownloading ? 'Opening...' : 'Download Template'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.navy,
                      side: const BorderSide(color: AppColors.navy),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Upload button
                if (_createdAuctionCode != null) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _templateUploading ? null : _pickAndUploadTemplate,
                      icon: _templateUploading
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.upload_file, size: 16),
                      label: Text(_templateUploading ? 'Uploading...' : 'Upload Completed Template'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navy,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 14, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Download the template, fill it with your product details. You can upload it after completing all steps and submitting the auction.',
                            style: TextStyle(fontSize: 11, color: Colors.blue.shade800),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Selected file name
                if (_templateFileName != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.appBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.insert_drive_file, size: 16, color: AppColors.navy),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(_templateFileName!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                        GestureDetector(
                          onTap: () => setState(() {
                            _templateFilePath = null;
                            _templateFileName = null;
                            _templateUploadResult = null;
                          }),
                          child: const Icon(Icons.close, size: 16, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],

                // Upload result — errors
                if (_templateUploadResult != null && !_templateUploadResult!.valid && _templateUploadResult!.errors.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.error_outline, size: 16, color: Colors.red.shade700),
                            const SizedBox(width: 6),
                            Text(
                              'Validation Errors (${_templateUploadResult!.errors.length})',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red.shade700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ..._templateUploadResult!.errors.take(10).map((e) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                '${e['row'] != null && e['row'] != 0 ? "Row ${e['row']}: " : ""}${e['error'] ?? e['message'] ?? 'Unknown error'}',
                                style: TextStyle(fontSize: 11, color: Colors.red.shade800),
                              ),
                            )),
                        if (_templateUploadResult!.errors.length > 10)
                          Text(
                            '+${_templateUploadResult!.errors.length - 10} more errors',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red.shade700),
                          ),
                      ],
                    ),
                  ),
                ],

                // Upload result — success preview
                if (_templateUploadResult != null && _templateUploadResult!.valid && _templateUploadResult!.rows.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.check_circle, size: 16, color: AppColors.success),
                      const SizedBox(width: 6),
                      Text(
                        '${_templateUploadResult!.rowCount} item(s) parsed successfully',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.success),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Summary stats
                  Row(
                    children: [
                      _statChip('Items', '${_templateUploadResult!.rowCount}'),
                      const SizedBox(width: 8),
                      _statChip('Total Qty', _templateUploadResult!.totalQuantity.toStringAsFixed(
                        _templateUploadResult!.totalQuantity == _templateUploadResult!.totalQuantity.roundToDouble() ? 0 : 2,
                      )),
                      const SizedBox(width: 8),
                      _statChip('Ref. Value', '₹${NumberFormat('#,##,###', 'en_IN').format(_templateUploadResult!.totalReferenceValue)}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Item list preview
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.cardBorder),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _templateUploadResult!.rows.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final row = _templateUploadResult!.rows[i];
                        final d = row['data'] as Map<String, dynamic>? ?? row;
                        final name = d['item_name'] ?? d['product_name'] ?? d['name'] ?? 'Item ${i + 1}';
                        final qty = _parseNum(d['quantity']);
                        final refVal = _parseNum(d['reference_value'] ?? d['reserve_value']);
                        return ListTile(
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          title: Text(name.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            'Qty: ${qty.toStringAsFixed(qty == qty.roundToDouble() ? 0 : 2)} ${d['unit'] ?? 'PCS'}',
                            style: const TextStyle(fontSize: 11),
                          ),
                          trailing: refVal > 0
                              ? Text('₹${NumberFormat('#,##,###', 'en_IN').format(refVal)}',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.navy))
                              : null,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Confirm import button
                  if (_templateUploadResult!.uploadId != null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _confirmTemplateImport(),
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Confirm Import'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _statChip(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.navyWithOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.navyWithOpacity(0.15)),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.navy)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmTemplateImport() async {
    if (_createdAuctionCode == null || _templateUploadResult?.uploadId == null) return;
    try {
      await _templateService.confirmUpload(
        auctionCode: _createdAuctionCode!,
        uploadId: _templateUploadResult!.uploadId!,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_templateUploadResult!.rowCount} items imported successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Confirm failed: $e'), backgroundColor: AppColors.destructive),
        );
      }
    }
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
                          _inspectionDateController.text = DateFormat(
                            'yyyy-MM-dd',
                          ).format(picked);
                        });
                      }
                    },
                    decoration: const InputDecoration(
                      hintText: 'Select date',
                      suffixIcon: Icon(Icons.calendar_today, size: 18),
                    ),
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
                    decoration: const InputDecoration(
                      hintText: 'e.g. 10:00 AM - 4:00 PM',
                    ),
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
          decoration: const InputDecoration(
            hintText: 'Exact premises or yard location for buyer inspection',
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Lot & Inspection Photos (${_auctionPhotos.length}/6)',
              style: AppTextStyles.labelMedium,
            ),
            TextButton.icon(
              onPressed: () async {
                final photos = await AppFilePicker.pickMultiImages(
                  context: context,
                );
                if (photos.isNotEmpty) {
                  setState(() {
                    _auctionPhotos.addAll(photos);
                    if (_auctionPhotos.length > 6) {
                      _auctionPhotos.removeRange(6, _auctionPhotos.length);
                    }
                  });
                }
              },
              icon: const Icon(
                Icons.add_photo_alternate_outlined,
                size: 16,
                color: AppColors.auction,
              ),
              label: const Text(
                'Add Photos',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.auction,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 90,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ..._auctionPhotos.map(
                (p) => Stack(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: p.path != null
                          ? Image.file(File(p.path!), fit: BoxFit.cover)
                          : const Center(
                              child: Icon(Icons.image, color: AppColors.navy),
                            ),
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
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_auctionPhotos.length < 6)
                GestureDetector(
                  onTap: () async {
                    final photo = await AppFilePicker.showPickerBottomSheet(
                      context,
                      title: 'Add Auction Photo',
                    );
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
                      border: Border.all(
                        color: AppColors.navyWithOpacity(0.15),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo_outlined,
                          size: 24,
                          color: AppColors.navyWithOpacity(0.5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Add Photo',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.navyWithOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Inspection Guidelines & Safety Protocols',
          style: AppTextStyles.labelMedium,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _guidelinesController,
          decoration: const InputDecoration(
            hintText: 'Entry requirements, PPE rules, gate entry rules...',
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        Text('Auction Documents (PDF)', style: AppTextStyles.labelMedium),
        const SizedBox(height: 4),
        Text(
          'Upload PDF documents for this auction. Required documents depend on auction direction.',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        _buildDocUploadSlot(
          label: 'Auction Notice / Catalog',
          docType: 'catalog',
          required: _direction == 'forward',
        ),
        const SizedBox(height: 12),
        _buildDocUploadSlot(
          label: 'Terms & Conditions',
          docType: 'tnc',
          required: false,
        ),
        const SizedBox(height: 12),
        _buildDocUploadSlot(
          label: 'Photographs',
          docType: 'photographs',
          required: _direction == 'forward',
        ),
      ],
    );
  }

  Widget _buildDocUploadSlot({
    required String label,
    required String docType,
    required bool required,
  }) {
    final file = _docFiles[docType];
    final uploading = _docUploading[docType] ?? false;
    final uploaded = _docUploaded[docType] ?? false;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.navyWithOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: uploaded
              ? AppColors.success.withValues(alpha: 0.4)
              : AppColors.cardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                uploaded ? Icons.check_circle : Icons.picture_as_pdf,
                size: 18,
                color: uploaded ? AppColors.success : AppColors.navy,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.navy,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: required
                      ? Colors.red.shade50
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  required ? 'Required' : 'Optional',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: required
                        ? Colors.red.shade700
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (file != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.appBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.insert_drive_file, size: 16, color: AppColors.navy),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          file.name,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          file.formattedSize,
                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  if (uploaded)
                    const Icon(Icons.check_circle, size: 16, color: AppColors.success)
                  else if (uploading)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    GestureDetector(
                      onTap: () => setState(() {
                        _docFiles[docType] = null;
                        _docUploaded[docType] = false;
                      }),
                      child: const Icon(Icons.close, size: 16, color: AppColors.textSecondary),
                    ),
                ],
              ),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: uploading ? null : () => _pickDocumentFile(docType),
                icon: const Icon(Icons.upload_file, size: 16),
                label: const Text('Select PDF'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.navy,
                  side: const BorderSide(color: AppColors.navy),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickDocumentFile(String docType) async {
    final picked = await AppFilePicker.pickDocument(
      allowedExtensions: ['pdf'],
    );
    if (picked == null || picked.path == null) return;
    if (!mounted) return;
    setState(() {
      _docFiles[docType] = picked;
      _docUploaded[docType] = false;
    });
  }

  Future<void> _uploadAllDocuments(String auctionCode) async {
    for (final entry in _docFiles.entries) {
      final docType = entry.key;
      final file = entry.value;
      if (file == null || file.path == null || _docUploaded[docType] == true) {
        continue;
      }
      setState(() => _docUploading[docType] = true);
      try {
        await _auctionService.uploadAuctionDocument(
          auctionCode,
          docType,
          File(file.path!),
        );
        if (mounted) setState(() => _docUploaded[docType] = true);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to upload $docType: $e'),
              backgroundColor: AppColors.destructive,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _docUploading[docType] = false);
      }
    }
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
                        initialDate:
                            _scheduleStart ??
                            DateTime.now().add(const Duration(hours: 1)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 90)),
                      );
                      if (date != null && mounted) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(
                            _scheduleStart ?? DateTime.now(),
                          ),
                        );
                        if (time != null) {
                          setState(() {
                            _scheduleStart = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );
                            _scheduleStartController.text = DateFormat(
                              'yyyy-MM-dd HH:mm',
                            ).format(_scheduleStart!);
                          });
                        }
                      }
                    },
                    decoration: const InputDecoration(
                      hintText: 'Start time',
                      suffixIcon: Icon(Icons.calendar_today, size: 18),
                    ),
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
                        initialDate:
                            _scheduleEnd ??
                            (_scheduleStart ?? DateTime.now()).add(
                              const Duration(hours: 4),
                            ),
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
                            _scheduleEnd = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );
                            _scheduleEndController.text = DateFormat(
                              'yyyy-MM-dd HH:mm',
                            ).format(_scheduleEnd!);
                          });
                        }
                      }
                    },
                    decoration: const InputDecoration(
                      hintText: 'End time',
                      suffixIcon: Icon(Icons.calendar_today, size: 18),
                    ),
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
                    decoration: const InputDecoration(
                      hintText: '₹ Amount',
                      prefixText: '₹ ',
                    ),
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
                    decoration: const InputDecoration(
                      hintText: '₹ Amount',
                      prefixText: '₹ ',
                    ),
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
                    decoration: const InputDecoration(
                      hintText: '₹ Amount',
                      prefixText: '₹ ',
                    ),
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
                    decoration: const InputDecoration(
                      hintText: '₹ Amount',
                      prefixText: '₹ ',
                    ),
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
                    initialValue: _liftingUnit,
                    items: const [
                      DropdownMenuItem(value: 'Days', child: Text('Days')),
                      DropdownMenuItem(value: 'Weeks', child: Text('Weeks')),
                    ],
                    onChanged: (v) =>
                        setState(() => _liftingUnit = v ?? 'Days'),
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
          decoration: const InputDecoration(
            hintText: 'e.g., 100% within 7 days of award',
          ),
        ),
        const SizedBox(height: 16),
        Text('Auction Contact', style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        TextField(
          controller: _contactNameController,
          decoration: const InputDecoration(hintText: 'Contact person name'),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _contactPhoneController,
                decoration: const InputDecoration(hintText: 'Phone number'),
                keyboardType: TextInputType.phone,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _contactEmailController,
                decoration: const InputDecoration(hintText: 'Email address'),
                keyboardType: TextInputType.emailAddress,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Terms & Conditions', style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        TextField(
          controller: _termsController,
          decoration: const InputDecoration(hintText: 'Additional terms...'),
          maxLines: 3,
        ),
        const SizedBox(height: 24),
        Text('Live Auction Timing Policy', style: AppTextStyles.labelMedium),
        const SizedBox(height: 6),
        Text(
          'The first slot runs for 30 minutes by default. Each continuation slot is 2 minutes, and the complete auction cannot exceed 120 minutes.',
          style: AppTextStyles.captionMuted,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _initialSlotMinutesController,
                decoration: const InputDecoration(
                  labelText: 'Initial slot (minutes)',
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _continuationSlotMinutesController,
                decoration: const InputDecoration(
                  labelText: 'Next slot (minutes)',
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _maximumDurationMinutesController,
          decoration: const InputDecoration(
            labelText: 'Maximum auction duration (minutes)',
          ),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildCategoryDropdowns() {
    final categoriesAsync = ref.watch(categoriesProvider);
    return categoriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text(
        'Failed to load categories',
        style: TextStyle(color: Colors.red.shade700),
      ),
      data: (categories) {
        return DropdownButtonFormField<Category>(
          initialValue: _selectedCategory,
          decoration: const InputDecoration(hintText: 'Select category'),
          isExpanded: true,
          items: categories
              .map(
                (c) => DropdownMenuItem(
                  value: c,
                  child: Row(
                    children: [
                      Expanded(child: Text(c.name)),
                      if (c.templateRequired)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.description_outlined,
                            size: 16,
                            color: AppColors.auction,
                          ),
                        ),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: (val) {
            setState(() {
              _selectedCategory = val;
              _selectedSubcategory = null;
            });
            _fetchTemplateForCategory();
          },
        );
      },
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
            color: isSelected
                ? AppColors.auction.withValues(alpha: 0.05)
                : AppColors.appBg,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: isSelected
                  ? AppColors.auction
                  : AppColors.blackWithOpacity(0.05),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: AppTextStyles.labelMedium.copyWith(
                  color: isSelected ? AppColors.auction : AppColors.navy,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: AppTextStyles.captionMuted,
                textAlign: TextAlign.center,
              ),
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
        onPressed: _isSubmitting
            ? null
            : () {
                if (_step == 0) {
                  final title = _titleController.text.trim();
                  final company = _companyController.text.trim();
                  if (title.isEmpty || company.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please enter auction title and company name.',
                        ),
                      ),
                    );
                    return;
                  }
                  if (_selectedCategory == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select a category.'),
                      ),
                    );
                    return;
                  }
                }
                if (_step == 1) {
                  if (_materialTypeController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a material description.'),
                      ),
                    );
                    return;
                  }
                  final qty = double.tryParse(_quantityController.text.trim());
                  if (qty == null || qty <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid quantity.'),
                      ),
                    );
                    return;
                  }
                }
                if (_step == 2 && _direction == 'forward') {
                  if (_docFiles['catalog'] == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Auction Notice / Catalog PDF is required for forward auctions.'),
                      ),
                    );
                    return;
                  }
                  if (_docFiles['photographs'] == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Photographs PDF is required for forward auctions.'),
                      ),
                    );
                    return;
                  }
                }
                if (_step == 3) {
                  final reserve = double.tryParse(
                    _reservePriceController.text.trim(),
                  );
                  final starting = double.tryParse(
                    _startingPriceController.text.trim(),
                  );
                  final increment = double.tryParse(
                    _bidIncrementController.text.trim(),
                  );
                  if (reserve == null || reserve <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a reserve price.'),
                      ),
                    );
                    return;
                  }
                  if (starting == null || starting <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a starting price.'),
                      ),
                    );
                    return;
                  }
                  if (increment == null || increment <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a bid increment.'),
                      ),
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
        content: const Text(
          'Your auction will be reviewed and approved by the compliance team before going live.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
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
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category.')),
      );
      return;
    }

    final start = _scheduleStart;
    final end = _scheduleEnd;
    final initialSlotMinutes =
        int.tryParse(_initialSlotMinutesController.text.trim()) ?? 0;
    final continuationSlotMinutes =
        int.tryParse(_continuationSlotMinutesController.text.trim()) ?? 0;
    final maximumDurationMinutes =
        int.tryParse(_maximumDurationMinutesController.text.trim()) ?? 0;

    if (start == null || end == null || !end.isAfter(start)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please choose a valid auction start and end time.'),
        ),
      );
      return;
    }
    if (start.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Auction start time cannot be in the past.'),
        ),
      );
      return;
    }
    if (maximumDurationMinutes < 1 || maximumDurationMinutes > 120) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Maximum auction duration must be between 1 and 120 minutes.',
          ),
        ),
      );
      return;
    }
    if (end.difference(start).inMinutes > maximumDurationMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'The selected auction window cannot exceed the maximum duration.',
          ),
        ),
      );
      return;
    }
    if (initialSlotMinutes < 1 || continuationSlotMinutes < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Slot durations must be greater than zero.'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final body = <String, dynamic>{
        'title': _titleController.text.trim().isNotEmpty
            ? _titleController.text.trim()
            : '${_materialTypeController.text.trim()} Scrap Disposal',
        'description': _materialTypeController.text.trim(),
        'company': _companyController.text.trim().isNotEmpty
            ? _companyController.text.trim()
            : 'Enterprise Seller',
        'category': _selectedCategory?.name ?? 'Ferrous',
        if (_selectedCategory != null) 'category_id': _selectedCategory!.id,
        'direction': _direction,
        'lot_type': _auctionType,
        'plant': _plantController.text.trim(),
        'warehouse': _warehouseController.text.trim(),
        'warehouse_details': {
          'address': _warehouseAddressController.text.trim(),
          'city': _warehouseCityController.text.trim(),
          'state': _warehouseStateController.text.trim(),
          'pincode': _warehousePincodeController.text.trim(),
          'contact': _warehouseContactController.text.trim(),
        },
        'location': _locationController.text.trim(),
        'material_type': _materialTypeController.text.trim(),
        'quantity': _quantityController.text.trim(),
        'uom': _uom,
        'starting_price':
            double.tryParse(_startingPriceController.text.trim()) ?? 0,
        'reserve_price': double.tryParse(_reservePriceController.text.trim()),
        'bid_increment':
            double.tryParse(_bidIncrementController.text.trim()) ?? 1000,
        'emd_amount':
            double.tryParse(_emdAmountController.text.trim()) ?? 10000,
        'schedule_start':
            _scheduleStart?.toIso8601String() ??
            DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
        'schedule_end':
            _scheduleEnd?.toIso8601String() ??
            DateTime.now().add(const Duration(hours: 48)).toIso8601String(),
        'inspection_date': _inspectionDateController.text.trim(),
        'inspection_time': _inspectionTimeController.text.trim(),
        'inspection_location': _inspectionLocationController.text.trim(),
        'guidelines_doc': _guidelinesController.text.trim(),
        'terms': _termsController.text.trim(),
        'payment_terms': _paymentTermsController.text.trim(),
        'lifting_period': _liftingPeriodController.text.trim(),
        'lifting_unit': _liftingUnit,
        'contact_name': _contactNameController.text.trim(),
        'contact_phone': _contactPhoneController.text.trim(),
        'contact_email': _contactEmailController.text.trim(),
        'warehouse_contact': _warehouseContactController.text.trim(),
        'status': 'pending_approval',
      };

      if (_auctionType == 'lot_wise' && _subLots.isNotEmpty) {
        body['sub_lots'] = _subLots
            .map(
              (item) => {
                'name': item.nameController.text.trim().isNotEmpty
                    ? item.nameController.text.trim()
                    : 'Lot Material',
                'quantity': item.quantityController.text.trim().isNotEmpty
                    ? item.quantityController.text.trim()
                    : '1',
                'uom': item.uom,
                'reserve_price': double.tryParse(
                  item.reservePriceController.text.trim(),
                ),
              },
            )
            .toList();
      }

      String auctionCode;
      if (_createdAuctionCode != null) {
        auctionCode = _createdAuctionCode!;
      } else {
        final created = await _auctionService.create(body);
        auctionCode = created.code;
        _createdAuctionCode = auctionCode;
      }
      await _auctionService.updateConfiguration(auctionCode, {
        'emd_required':
            (double.tryParse(_emdAmountController.text.trim()) ?? 0) > 0,
        'emd_type': 'FIXED',
        'emd_fixed_amount':
            double.tryParse(_emdAmountController.text.trim()) ?? 0,
        'initial_slot_minutes': initialSlotMinutes,
        'continuation_slot_minutes': continuationSlotMinutes,
        'maximum_auction_duration_minutes': maximumDurationMinutes,
        'bid_cutoff_ms': 500,
        'continuation_mode': 'MANUAL_ADMIN',
      });

      // Upload template file if one was selected
      if (_templateFilePath != null && _templateInfo != null) {
        final uploadResult = await _templateService.uploadTemplate(
          auctionCode: auctionCode,
          templateId: _templateInfo!.id,
          filePath: _templateFilePath!,
          fileName: _templateFileName ?? 'template.xlsx',
        );
        if (uploadResult.valid && uploadResult.uploadId != null) {
          await _templateService.confirmUpload(
            auctionCode: auctionCode,
            uploadId: uploadResult.uploadId!,
          );
        }
      }

      // Upload auction documents (PDF)
      await _uploadAllDocuments(auctionCode);

      // Invalidate is already called above but call again after template
      ref.invalidate(sellerAuctionsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Auction #$auctionCode submitted successfully!',
            ),
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
