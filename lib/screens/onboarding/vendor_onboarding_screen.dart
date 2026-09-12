import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../providers/auth_provider.dart';
import '../../services/vendor_service.dart';
import '../../services/pincode_service.dart';
import '../../core/utils/file_picker_service.dart';
import '../../core/validation/input_validators.dart';

class VendorOnboardingScreen extends ConsumerStatefulWidget {
  const VendorOnboardingScreen({super.key});

  @override
  ConsumerState<VendorOnboardingScreen> createState() =>
      _VendorOnboardingScreenState();
}

class _VendorOnboardingScreenState
    extends ConsumerState<VendorOnboardingScreen> {
  final _vendorService = VendorService();
  final _pincodeService = PincodeService();
  bool _pincodeLookupLoading = false;
  int _currentStep = 0; // 0 to 9 (10 total steps)

  // Step 1: Company Info
  final _legalNameCtl = TextEditingController();
  final _tradeNameCtl = TextEditingController();
  String _companyType = 'Private Limited (Pvt Ltd)';
  final _cinCtl = TextEditingController();

  // Step 2: Tax & Identifiers
  final _gstinCtl = TextEditingController();
  final _panCtl = TextEditingController();
  final _udyamCtl = TextEditingController();

  // Step 3: Address & Operating Hubs
  final _addressLine1Ctl = TextEditingController();
  final _cityCtl = TextEditingController();
  String _state = '';
  final _pincodeCtl = TextEditingController();
  bool _pincodeResolved = false;

  // Step 4: Categories
  final Set<String> _selectedCategories = {};

  // Step 5: Bank Details
  final _bankNameCtl = TextEditingController();
  final _accountNoCtl = TextEditingController();
  final _ifscCtl = TextEditingController();
  String _accountType = 'Current Account';

  // Step 6: Authorized Signatory
  final _signatoryNameCtl = TextEditingController();
  final _designationCtl = TextEditingController();
  final _signatoryEmailCtl = TextEditingController();
  final _signatoryPhoneCtl = TextEditingController();

  // Step 7: Capabilities & Turnover
  String _turnoverBand = '< ₹5 Cr';
  String _yearsInBusiness = '1 - 3 Years';
  final _annualCapacityCtl = TextEditingController();

  // Step 8: Compliance & Certificates
  final Map<String, bool> _complianceDocs = {
    'GST Registration Certificate': true,
    'Company PAN Card': true,
    'MSME Udyam Certificate': false,
    'Pollution Control Board (PCB) Consent': true,
    'Cancelled Cheque / Bank Letter': true,
    'Board Resolution / PoA': false,
  };

  // Step 9: Terms & Undertaking
  bool _acceptIntegrityPact = true;
  bool _acceptH1Commitment = true;
  bool _acceptPlatformFees = true;

  // Step 10: Submission State
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider).user;
      if (user != null) {
        if (_legalNameCtl.text.isEmpty) {
          _legalNameCtl.text = user.companyName ?? user.name;
        }
        if (_signatoryNameCtl.text.isEmpty) {
          _signatoryNameCtl.text = user.name;
        }
        if (_signatoryEmailCtl.text.isEmpty) {
          _signatoryEmailCtl.text = user.email;
        }
        if (_signatoryPhoneCtl.text.isEmpty) {
          _signatoryPhoneCtl.text = user.phone;
        }
        if (user.vendor != null) {
          final v = user.vendor!;
          if (v.gstNumber != null && _gstinCtl.text.isEmpty)
            _gstinCtl.text = v.gstNumber!;
          if (v.panNumber != null && _panCtl.text.isEmpty)
            _panCtl.text = v.panNumber!;
          if (v.bankName != null && _bankNameCtl.text.isEmpty)
            _bankNameCtl.text = v.bankName!;
          if (v.accountNumber != null && _accountNoCtl.text.isEmpty)
            _accountNoCtl.text = v.accountNumber!;
          if (v.ifscCode != null && _ifscCtl.text.isEmpty)
            _ifscCtl.text = v.ifscCode!;
          if (v.city != null && _cityCtl.text.isEmpty) _cityCtl.text = v.city!;
          if (v.state != null) _state = v.state!;
          if (v.pincode != null && _pincodeCtl.text.isEmpty)
            _pincodeCtl.text = v.pincode!;
          if (v.pincode != null && isIndianPincode(v.pincode!)) {
            _onPincodeChanged(v.pincode!);
          }
        }
      }
    });
  }

  Future<void> _nextStep() async {
    final validationError = _validateCurrentStep();
    if (validationError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(validationError)));
      return;
    }

    // Save draft step progress to server
    try {
      final stepMap = <String, dynamic>{
        'step': _currentStep + 1,
        'company_name': _legalNameCtl.text.isNotEmpty
            ? _legalNameCtl.text
            : null,
        'trade_name': _tradeNameCtl.text.isNotEmpty ? _tradeNameCtl.text : null,
        'business_type': _companyType,
        'cin_number': _cinCtl.text.isNotEmpty ? _cinCtl.text : null,
        'gst_number': _gstinCtl.text.isNotEmpty ? _gstinCtl.text : null,
        'pan_number': _panCtl.text.isNotEmpty ? _panCtl.text : null,
        'address_line1': _addressLine1Ctl.text.isNotEmpty
            ? _addressLine1Ctl.text
            : null,
        'city': _cityCtl.text.isNotEmpty ? _cityCtl.text : null,
        'state': _state,
        'pincode': _pincodeCtl.text.isNotEmpty ? _pincodeCtl.text : null,
        'bank_name': _bankNameCtl.text.isNotEmpty ? _bankNameCtl.text : null,
        'account_number': _accountNoCtl.text.isNotEmpty
            ? _accountNoCtl.text
            : null,
        'ifsc_code': _ifscCtl.text.isNotEmpty ? _ifscCtl.text : null,
        'account_type': _accountType,
        'signatory_name': _signatoryNameCtl.text.isNotEmpty
            ? _signatoryNameCtl.text
            : null,
        'signatory_designation': _designationCtl.text.isNotEmpty
            ? _designationCtl.text
            : null,
        'signatory_email': _signatoryEmailCtl.text.isNotEmpty
            ? _signatoryEmailCtl.text
            : null,
        'signatory_phone': _signatoryPhoneCtl.text.isNotEmpty
            ? _signatoryPhoneCtl.text
            : null,
        'turnover_band': _turnoverBand,
        'years_in_business': _yearsInBusiness,
        'annual_capacity': _annualCapacityCtl.text.isNotEmpty
            ? _annualCapacityCtl.text
            : null,
        'material_interest': _selectedCategories.toList(),
        'terms_accepted':
            _acceptIntegrityPact && _acceptH1Commitment && _acceptPlatformFees,
      };
      await _vendorService.saveStep(stepMap);
    } catch (_) {}

    if (_currentStep < 9) {
      setState(() => _currentStep++);
    } else {
      _submitApplication();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _submitApplication() async {
    setState(() => _submitting = true);
    try {
      final user = ref.read(authProvider).user;
      final vendorCode = user?.vendorCode ?? user?.vendor?.code;
      if (vendorCode == null || vendorCode.isEmpty) {
        throw StateError(
          'Vendor profile is unavailable. Please refresh your session and try again.',
        );
      }

      await _vendorService.submitKyc(vendorCode);
      await ref.read(authProvider.notifier).refreshUser();

      if (!mounted) return;
      context.go(
        '/reg-status',
        extra: {
          'status': 'under_verification',
          'reason': null,
          'kycDetails': {
            'Legal Name': _legalNameCtl.text,
            'GSTIN': _gstinCtl.text,
            'PAN': _panCtl.text,
            'Bank': _bankNameCtl.text,
            'Signatory': _signatoryNameCtl.text,
          },
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Submission: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stepTitles = [
      'Company Info',
      'Tax & GSTIN',
      'Operating Hubs',
      'Categories',
      'Bank Account',
      'Signatory',
      'Capabilities',
      'Compliance',
      'Terms & Pact',
      'Review & Submit',
    ];

    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: AppBar(
        title: Text('Enterprise Onboarding (${_currentStep + 1}/10)'),
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Step Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: AppColors.navy,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      stepTitles[_currentStep].toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.auction,
                      ),
                    ),
                    Text(
                      'Step ${_currentStep + 1} of 10',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (_currentStep + 1) / 10,
                    backgroundColor: AppColors.white.withValues(alpha: 0.15),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.auction,
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),

          // Step Form Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildStepContent(),
            ),
          ),

          // Bottom Step Navigation Bar
          Container(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              MediaQuery.of(context).padding.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border(
                top: BorderSide(color: AppColors.black.withValues(alpha: 0.08)),
              ),
            ),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: _submitting ? null : _prevStep,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusLg,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Back',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentStep == 9
                          ? AppColors.success
                          : AppColors.auction,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusLg,
                        ),
                      ),
                    ),
                    child: _submitting
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              color: AppColors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _currentStep == 9
                                ? 'Submit for Verification'
                                : 'Save & Continue',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _stepCompanyInfo();
      case 1:
        return _stepTaxIdentifiers();
      case 2:
        return _stepAddressHubs();
      case 3:
        return _stepCategories();
      case 4:
        return _stepBankAccount();
      case 5:
        return _stepAuthorizedSignatory();
      case 6:
        return _stepCapabilities();
      case 7:
        return _stepCompliance();
      case 8:
        return _stepTermsPact();
      case 9:
        return _stepReviewSubmit();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _cardContainer({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _stepCompanyInfo() {
    return _cardContainer(
      children: [
        Text(
          'Legal Entity Profile',
          style: AppTextStyles.heading(size: 17, weight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        const Text(
          'Enter registered company name matching incorporation records.',
          style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _legalNameCtl,
          decoration: const InputDecoration(
            labelText: 'Registered Legal Name *',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _tradeNameCtl,
          decoration: const InputDecoration(
            labelText: 'Trade Name / Operating Brand (Optional)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _companyType,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Entity Constitution *',
            border: OutlineInputBorder(),
          ),
          items:
              [
                    'Private Limited (Pvt Ltd)',
                    'Public Limited (Ltd)',
                    'Limited Liability Partnership (LLP)',
                    'Partnership Firm',
                    'Sole Proprietorship',
                  ]
                  .map(
                    (t) => DropdownMenuItem(
                      value: t,
                      child: Text(t, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
          onChanged: (v) => setState(() => _companyType = v ?? _companyType),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _cinCtl,
          decoration: const InputDecoration(
            labelText: 'CIN / LLPIN (Corporate Reg No.) *',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _stepTaxIdentifiers() {
    return _cardContainer(
      children: [
        Text(
          'Tax Identifiers & GSTIN',
          style: AppTextStyles.heading(size: 17, weight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        const Text(
          'GSTIN will be cross-validated against the government GSTN gateway.',
          style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _gstinCtl,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            labelText: '15-Digit GSTIN *',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _panCtl,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            labelText: '10-Digit Company PAN *',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _udyamCtl,
          decoration: const InputDecoration(
            labelText: 'MSME Udyam Registration (Optional)',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Future<void> _onPincodeChanged(String value) async {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    final pincode = digits.substring(0, digits.length.clamp(0, 6));
    if (pincode != value) {
      _pincodeCtl.value = _pincodeCtl.value.copyWith(
        text: pincode,
        selection: TextSelection.collapsed(offset: pincode.length),
      );
    }
    if (!isIndianPincode(pincode)) {
      if (mounted) {
        setState(() {
          _pincodeResolved = false;
          _cityCtl.clear();
          _state = '';
        });
      }
      return;
    }
    setState(() {
      _pincodeResolved = false;
      _cityCtl.clear();
      _state = '';
    });
    setState(() => _pincodeLookupLoading = true);
    try {
      final result = await _pincodeService.lookup(pincode);
      if (result != null && mounted) {
        setState(() {
          _cityCtl.text = result.city;
          _state = result.state;
          _pincodeResolved = true;
        });
      }
    } finally {
      if (mounted) setState(() => _pincodeLookupLoading = false);
    }
  }

  Widget _stepAddressHubs() {
    return _cardContainer(
      children: [
        Text(
          'Registered Yard & Operating Hubs',
          style: AppTextStyles.heading(size: 17, weight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _addressLine1Ctl,
          decoration: const InputDecoration(
            labelText: 'Registered Yard Address *',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _pincodeCtl,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: InputDecoration(
            labelText: 'PIN Code *',
            border: const OutlineInputBorder(),
            counterText: '',
            suffixIcon: _pincodeLookupLoading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
          ),
          onChanged: _onPincodeChanged,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _cityCtl,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'City (from PIN API) *',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'State *',
                  border: const OutlineInputBorder(),
                ),
                controller: TextEditingController(text: _state),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _stepCategories() {
    final categories = [
      'Heavy Ferrous Scrap',
      'Non-Ferrous Alloys & Copper',
      'Industrial E-Waste & Circuit Boards',
      'Automotive Shredded Scrap',
      'Paper & Cardboard Bales',
      'Polymers & Engineering Plastics',
    ];

    return _cardContainer(
      children: [
        Text(
          'Material Specialization',
          style: AppTextStyles.heading(size: 17, weight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        const Text(
          'Select all commodity categories you are authorized to trade.',
          style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((cat) {
            final selected = _selectedCategories.contains(cat);
            return FilterChip(
              label: Text(cat),
              selected: selected,
              selectedColor: AppColors.navy,
              checkmarkColor: AppColors.white,
              labelStyle: TextStyle(
                color: selected ? AppColors.white : AppColors.navy,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 12,
              ),
              onSelected: (val) {
                setState(() {
                  if (val) {
                    _selectedCategories.add(cat);
                  } else {
                    _selectedCategories.remove(cat);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _stepBankAccount() {
    return _cardContainer(
      children: [
        Text(
          'Settlement Bank Account',
          style: AppTextStyles.heading(size: 17, weight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        const Text(
          'Used for automated EMD escrow refunds and auction settlements.',
          style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _bankNameCtl,
          decoration: const InputDecoration(
            labelText: 'Bank Name *',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _accountNoCtl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Bank Account Number *',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _ifscCtl,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            labelText: 'IFSC Code *',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _accountType,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Account Type *',
            border: OutlineInputBorder(),
          ),
          items: [
            'Current Account',
            'Cash Credit (CC) / OD Account',
            'Savings Account',
          ].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
          onChanged: (v) => setState(() => _accountType = v ?? _accountType),
        ),
      ],
    );
  }

  Widget _stepAuthorizedSignatory() {
    return _cardContainer(
      children: [
        Text(
          'Authorized Key Signatory',
          style: AppTextStyles.heading(size: 17, weight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _signatoryNameCtl,
          decoration: const InputDecoration(
            labelText: 'Signatory Full Name *',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _designationCtl,
          decoration: const InputDecoration(
            labelText: 'Designation (Director / Partner / Head) *',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _signatoryEmailCtl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Official Corporate Email *',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _signatoryPhoneCtl,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Mobile Number for OTP *',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _stepCapabilities() {
    return _cardContainer(
      children: [
        Text(
          'Turnover & Processing Capacity',
          style: AppTextStyles.heading(size: 17, weight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _turnoverBand,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Annual Scrap Turnover *',
            border: OutlineInputBorder(),
          ),
          items: ['< ₹5 Cr', '₹5 Cr - ₹25 Cr', '₹25 Cr - ₹100 Cr', '₹100 Cr+']
              .map(
                (b) => DropdownMenuItem(
                  value: b,
                  child: Text(b, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _turnoverBand = v ?? _turnoverBand),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _yearsInBusiness,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Years in Commercial Operation *',
            border: OutlineInputBorder(),
          ),
          items: ['1 - 3 Years', '3 - 5 Years', '5+ Years', '10+ Years']
              .map(
                (y) => DropdownMenuItem(
                  value: y,
                  child: Text(y, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (v) =>
              setState(() => _yearsInBusiness = v ?? _yearsInBusiness),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _annualCapacityCtl,
          decoration: const InputDecoration(
            labelText: 'Handling / Processing Capacity *',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _stepCompliance() {
    final uploadedCount = _complianceDocs.values.where((v) => v).length;
    final totalCount = _complianceDocs.length;

    return _cardContainer(
      children: [
        Text(
          'Compliance & Documents',
          style: AppTextStyles.heading(size: 17, weight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          uploadedCount == totalCount
              ? 'All $totalCount essential documents uploaded for instant Tier clearance.'
              : 'Upload $totalCount essential documents for Tier clearance. ($uploadedCount of $totalCount uploaded)',
          style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: totalCount > 0 ? uploadedCount / totalCount : 0,
            backgroundColor: AppColors.navy.withValues(alpha: 0.08),
            color: uploadedCount == totalCount
                ? AppColors.success
                : AppColors.auction,
            minHeight: 4,
          ),
        ),
        const SizedBox(height: 16),
        ..._complianceDocs.entries.map((e) {
          final uploaded = e.value;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                Icon(
                  uploaded ? Icons.task_alt : Icons.cloud_upload_outlined,
                  color: uploaded
                      ? AppColors.success
                      : AppColors.navy.withValues(alpha: 0.4),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    e.key,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: uploaded
                          ? AppColors.navy
                          : AppColors.navy.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final file = await AppFilePicker.showPickerBottomSheet(
                      context,
                      title: 'Upload ${e.key}',
                    );
                    if (file != null) {
                      setState(() {
                        _complianceDocs[e.key] = true;
                      });
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '✓ ${file.name} attached for ${e.key}',
                            ),
                          ),
                        );
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: uploaded
                          ? AppColors.success.withValues(alpha: 0.12)
                          : AppColors.navy.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: uploaded
                            ? AppColors.success.withValues(alpha: 0.3)
                            : AppColors.navy.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!uploaded)
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(
                              Icons.upload_file,
                              size: 12,
                              color: AppColors.navy.withValues(alpha: 0.6),
                            ),
                          ),
                        Text(
                          uploaded ? 'Attached' : 'Upload',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: uploaded
                                ? AppColors.success
                                : AppColors.navy.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _stepTermsPact() {
    return _cardContainer(
      children: [
        Text(
          'Platform Integrity Pact & Undertakings',
          style: AppTextStyles.heading(size: 17, weight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        CheckboxListTile(
          value: _acceptIntegrityPact,
          activeColor: AppColors.navy,
          title: const Text(
            'Anti-Collusion & Fair Bidding Undertaking',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          subtitle: const Text(
            'I confirm zero cartelization or bid-rigging with competitor vendors.',
            style: TextStyle(fontSize: 11.5),
          ),
          contentPadding: EdgeInsets.zero,
          onChanged: (v) => setState(() => _acceptIntegrityPact = v ?? false),
        ),
        const Divider(),
        CheckboxListTile(
          value: _acceptH1Commitment,
          activeColor: AppColors.navy,
          title: const Text(
            'H1 / L1 Binding Award Commitment',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          subtitle: const Text(
            'Bids placed during live auctions are irrevocable commercial commitments.',
            style: TextStyle(fontSize: 11.5),
          ),
          contentPadding: EdgeInsets.zero,
          onChanged: (v) => setState(() => _acceptH1Commitment = v ?? false),
        ),
        const Divider(),
        CheckboxListTile(
          value: _acceptPlatformFees,
          activeColor: AppColors.navy,
          title: const Text(
            'Success Fee & EMD Forfeiture Conditions',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          subtitle: const Text(
            'I agree to the standard platform success fee schedule and EMD escrow terms.',
            style: TextStyle(fontSize: 11.5),
          ),
          contentPadding: EdgeInsets.zero,
          onChanged: (v) => setState(() => _acceptPlatformFees = v ?? false),
        ),
      ],
    );
  }

  Widget _stepReviewSubmit() {
    return _cardContainer(
      children: [
        Center(
          child: const Icon(
            Icons.verified_user_rounded,
            color: AppColors.navy,
            size: 48,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Review & Final Submission',
            style: AppTextStyles.heading(size: 18, weight: FontWeight.w900),
          ),
        ),
        const SizedBox(height: 4),
        const Center(
          child: Text(
            'Verify your enterprise credentials before transmitting to compliance desk.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
          ),
        ),
        const SizedBox(height: 20),
        _reviewRow('Legal Entity', _legalNameCtl.text),
        _reviewRow('Constitution', _companyType),
        _reviewRow(
          'GSTIN',
          _gstinCtl.text.isNotEmpty ? _gstinCtl.text : 'Not provided',
        ),
        _reviewRow('Operating State', _state),
        _reviewRow(
          'Categories',
          '${_selectedCategories.length} Sectors Selected',
        ),
        _reviewRow(
          'Settlement Bank',
          _bankNameCtl.text.isNotEmpty ? _bankNameCtl.text : 'Not provided',
        ),
        _reviewRow(
          'Authorized Signatory',
          '${_signatoryNameCtl.text} (${_designationCtl.text.isNotEmpty ? _designationCtl.text : "Director"})',
        ),
        _reviewRow('Turnover Band', _turnoverBand),
        _reviewRow(
          'Compliance Docs',
          '${_complianceDocs.values.where((v) => v).length} of ${_complianceDocs.length} Uploaded',
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.auction.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: const Text(
            'Upon submission, our compliance desk will verify your CIN and GST credentials within 4 business hours.',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.auction,
            ),
          ),
        ),
      ],
    );
  }

  Widget _reviewRow(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            k,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          Flexible(
            child: Text(
              v,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        if (_legalNameCtl.text.trim().length < 2) {
          return 'Enter the registered legal name.';
        }
        if (!RegExp(
          r'^[A-Za-z0-9 .,&()\-/]{8,30}$',
        ).hasMatch(_cinCtl.text.trim())) {
          return 'Enter a valid CIN or LLPIN.';
        }
        return null;
      case 1:
        if (!isGstin(_gstinCtl.text)) {
          return 'Enter a valid 15-character GSTIN.';
        }
        if (!isPan(_panCtl.text)) {
          return 'Enter a valid 10-character PAN.';
        }
        return null;
      case 2:
        if (_addressLine1Ctl.text.trim().length < 5) {
          return 'Enter the registered yard address.';
        }
        if (!isIndianPincode(_pincodeCtl.text) || !_pincodeResolved) {
          return 'Enter a valid PIN code and wait for the location lookup.';
        }
        return null;
      case 3:
        return _selectedCategories.isEmpty
            ? 'Select at least one material category.'
            : null;
      case 4:
        if (_bankNameCtl.text.trim().length < 2) {
          return 'Enter the bank name.';
        }
        if (!RegExp(r'^\d{6,30}$').hasMatch(_accountNoCtl.text.trim())) {
          return 'Enter a valid bank account number.';
        }
        if (!isIfsc(_ifscCtl.text)) {
          return 'Enter a valid IFSC code.';
        }
        return null;
      case 5:
        if (_signatoryNameCtl.text.trim().length < 2) {
          return 'Enter the signatory name.';
        }
        if (_designationCtl.text.trim().length < 2) {
          return 'Enter the signatory designation.';
        }
        if (!isEmail(_signatoryEmailCtl.text)) {
          return 'Enter a valid signatory email.';
        }
        if (!isIndianMobile(_signatoryPhoneCtl.text)) {
          return 'Enter a valid signatory mobile number.';
        }
        return null;
      case 6:
        return _annualCapacityCtl.text.trim().isEmpty
            ? 'Enter the handling capacity.'
            : null;
      case 8:
        return _acceptIntegrityPact &&
                _acceptH1Commitment &&
                _acceptPlatformFees
            ? null
            : 'Accept all terms before continuing.';
      case 9:
        for (var step = 0; step < 9; step++) {
          final error = _validateStepNumber(step);
          if (error != null) return error;
        }
        return null;
      default:
        return null;
    }
  }

  String? _validateStepNumber(int step) {
    final currentStep = _currentStep;
    _currentStep = step;
    final error = _validateCurrentStep();
    _currentStep = currentStep;
    return error;
  }
}
