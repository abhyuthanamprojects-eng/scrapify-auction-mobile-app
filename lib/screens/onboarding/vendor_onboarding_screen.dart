import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/constants/app_constants.dart';

class VendorOnboardingScreen extends StatefulWidget {
  const VendorOnboardingScreen({super.key});

  @override
  State<VendorOnboardingScreen> createState() => _VendorOnboardingScreenState();
}

class _VendorOnboardingScreenState extends State<VendorOnboardingScreen> {
  int _currentStep = 0; // 0 to 9 (10 total steps)

  // Step 1: Company Info
  final _legalNameCtl = TextEditingController(text: 'Devzign Solutions Pvt Ltd');
  final _tradeNameCtl = TextEditingController(text: 'Devzign Industrial');
  String _companyType = 'Private Limited (Pvt Ltd)';
  final _cinCtl = TextEditingController(text: 'U72200MH2021PTC362810');
  final _incorpDateCtl = TextEditingController(text: '15/06/2021');

  // Step 2: Tax & Identifiers
  final _gstinCtl = TextEditingController(text: '27AABCD1234F1Z5');
  final _panCtl = TextEditingController(text: 'AABCD1234F');
  final _udyamCtl = TextEditingController(text: 'UDYAM-MH-12-0048192');
  bool _gstVerified = true;

  // Step 3: Address & Operating Hubs
  final _addressLine1Ctl = TextEditingController(text: 'Plot 48, MIDC Industrial Area');
  final _cityCtl = TextEditingController(text: 'Mumbai');
  String _state = 'Maharashtra';
  final _pincodeCtl = TextEditingController(text: '400093');
  final List<String> _operatingStates = ['Maharashtra', 'Gujarat', 'Jharkhand', 'Karnataka'];

  // Step 4: Categories
  final Set<String> _selectedCategories = {
    'Metals & Industrial Scrap',
    'Industrial Machinery & Plants',
    'Logistics & Fleet Contracts',
  };

  // Step 5: Bank Details
  final _bankNameCtl = TextEditingController(text: 'HDFC Bank Ltd');
  final _accountNoCtl = TextEditingController(text: '50200049281729');
  final _ifscCtl = TextEditingController(text: 'HDFC0000240');
  String _accountType = 'Current Account';
  bool _pennyDropVerified = true;

  // Step 6: Authorized Signatory
  final _signatoryNameCtl = TextEditingController(text: 'Rahul Sharma');
  final _designationCtl = TextEditingController(text: 'Managing Director');
  final _signatoryEmailCtl = TextEditingController(text: 'rahul.sharma@devzign.in');
  final _signatoryPhoneCtl = TextEditingController(text: '+91 98765 43210');

  // Step 7: Capabilities & Turnover
  String _turnoverBand = '₹25 Cr – ₹100 Cr';
  String _yearsInBusiness = '5+ Years';
  final _annualCapacityCtl = TextEditingController(text: '12,000 Metric Tonnes / Year');

  // Step 8: Compliance & Certificates
  final Map<String, bool> _complianceDocs = {
    'GST Registration Certificate': true,
    'Company PAN Card': true,
    'MSME Udyam Certificate': true,
    'Pollution Control Board (PCB) Consent': true,
    'Cancelled Cheque / Bank Letter': true,
    'Board Resolution / PoA': true,
  };

  // Step 9: Terms & Undertaking
  bool _acceptIntegrityPact = true;
  bool _acceptH1Commitment = true;
  bool _acceptPlatformFees = true;

  // Step 10: Submission State
  bool _submitting = false;

  void _nextStep() {
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

  void _submitApplication() {
    setState(() => _submitting = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _submitting = false);
      context.go('/reg-status', extra: {
        'status': 'under_verification',
        'reason': null,
        'kycDetails': {
          'Legal Name': _legalNameCtl.text,
          'GSTIN': _gstinCtl.text,
          'PAN': _panCtl.text,
          'Bank': _bankNameCtl.text,
          'Signatory': _signatoryNameCtl.text,
        },
      });
    });
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
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.auction),
                    ),
                    Text(
                      'Step ${_currentStep + 1} of 10',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (_currentStep + 1) / 10,
                    backgroundColor: AppColors.white.withValues(alpha: 0.15),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.auction),
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
            padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: const Border(top: BorderSide(color: AppColors.cardBorder)),
              boxShadow: AppColors.shadowLg,
            ),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: _prevStep,
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusXl)),
                        ),
                        child: const Text('Back', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.navy)),
                      ),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentStep == 9 ? AppColors.success : AppColors.navy,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusXl)),
                      ),
                      child: _submitting
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2))
                          : Text(_currentStep == 9 ? 'Submit Application' : 'Continue', style: const TextStyle(fontWeight: FontWeight.w800)),
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
        return _stepTaxInfo();
      case 2:
        return _stepAddressHubs();
      case 3:
        return _stepCategories();
      case 4:
        return _stepBankDetails();
      case 5:
        return _stepSignatory();
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
        borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppColors.shadowSm,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _stepCompanyInfo() {
    return _cardContainer(children: [
      Text('Company & Entity Details', style: AppTextStyles.heading(size: 17, weight: FontWeight.w800)),
      const SizedBox(height: 4),
      const Text('Enter legal entity details as per Ministry of Corporate Affairs (MCA).', style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B))),
      const SizedBox(height: 16),
      TextField(controller: _legalNameCtl, decoration: const InputDecoration(labelText: 'Legal Entity Name *', border: OutlineInputBorder())),
      const SizedBox(height: 12),
      TextField(controller: _tradeNameCtl, decoration: const InputDecoration(labelText: 'Trade / Brand Name', border: OutlineInputBorder())),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        value: _companyType,
        decoration: const InputDecoration(labelText: 'Company Constitution *', border: OutlineInputBorder()),
        items: [
          'Private Limited (Pvt Ltd)',
          'Public Limited (Ltd)',
          'Partnership Firm',
          'Limited Liability Partnership (LLP)',
          'Sole Proprietorship',
        ].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
        onChanged: (v) => setState(() => _companyType = v ?? _companyType),
      ),
      const SizedBox(height: 12),
      TextField(controller: _cinCtl, decoration: const InputDecoration(labelText: 'CIN / LLPIN Number *', border: OutlineInputBorder())),
      const SizedBox(height: 12),
      TextField(controller: _incorpDateCtl, decoration: const InputDecoration(labelText: 'Date of Incorporation (DD/MM/YYYY)', border: OutlineInputBorder())),
    ]);
  }

  Widget _stepTaxInfo() {
    return _cardContainer(children: [
      Text('Tax & Identifiers', style: AppTextStyles.heading(size: 17, weight: FontWeight.w800)),
      const SizedBox(height: 4),
      const Text('GSTIN will be validated against the National GST Portal API.', style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B))),
      const SizedBox(height: 16),
      TextField(
        controller: _gstinCtl,
        decoration: InputDecoration(
          labelText: 'Corporate GSTIN *',
          suffixIcon: _gstVerified ? const Icon(Icons.verified, color: AppColors.success) : null,
          border: const OutlineInputBorder(),
        ),
      ),
      if (_gstVerified) ...[
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
          child: const Text('✓ Active GSTIN verified with MCA matching', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success)),
        ),
      ],
      const SizedBox(height: 14),
      TextField(controller: _panCtl, decoration: const InputDecoration(labelText: 'Company PAN *', border: OutlineInputBorder())),
      const SizedBox(height: 14),
      TextField(controller: _udyamCtl, decoration: const InputDecoration(labelText: 'MSME / Udyam Number (Optional)', border: OutlineInputBorder())),
    ]);
  }

  Widget _stepAddressHubs() {
    return _cardContainer(children: [
      Text('Registered Office & Operating Hubs', style: AppTextStyles.heading(size: 17, weight: FontWeight.w800)),
      const SizedBox(height: 16),
      TextField(controller: _addressLine1Ctl, decoration: const InputDecoration(labelText: 'Registered Address Line *', border: OutlineInputBorder())),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(child: TextField(controller: _cityCtl, decoration: const InputDecoration(labelText: 'City *', border: OutlineInputBorder()))),
          const SizedBox(width: 12),
          Expanded(child: TextField(controller: _pincodeCtl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'PIN Code *', border: OutlineInputBorder()))),
        ],
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        value: _state,
        decoration: const InputDecoration(labelText: 'State *', border: OutlineInputBorder()),
        items: AppConstants.states.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
        onChanged: (v) => setState(() => _state = v ?? _state),
      ),
      const SizedBox(height: 16),
      const Text('Operating / Delivery Hubs:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.navy)),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: ['Maharashtra', 'Gujarat', 'Jharkhand', 'Karnataka', 'Tamil Nadu', 'Delhi NCR', 'Odisha'].map((st) {
          final selected = _operatingStates.contains(st);
          return FilterChip(
            label: Text(st),
            selected: selected,
            selectedColor: AppColors.navy.withValues(alpha: 0.12),
            onSelected: (v) {
              setState(() {
                if (v) {
                  _operatingStates.add(st);
                } else {
                  _operatingStates.remove(st);
                }
              });
            },
          );
        }).toList(),
      ),
    ]);
  }

  Widget _stepCategories() {
    return _cardContainer(children: [
      Text('Category & Sector Selection', style: AppTextStyles.heading(size: 17, weight: FontWeight.w800)),
      const SizedBox(height: 4),
      const Text('Select sectors in which your enterprise bids or provides supplies.', style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B))),
      const SizedBox(height: 16),
      ...AppConstants.categories.map((cat) {
        final selected = _selectedCategories.contains(cat);
        return CheckboxListTile(
          value: selected,
          activeColor: AppColors.navy,
          title: Text(cat, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
          contentPadding: EdgeInsets.zero,
          onChanged: (v) {
            setState(() {
              if (v == true) {
                _selectedCategories.add(cat);
              } else {
                _selectedCategories.remove(cat);
              }
            });
          },
        );
      }),
    ]);
  }

  Widget _stepBankDetails() {
    return _cardContainer(children: [
      Text('Settlement Bank Details', style: AppTextStyles.heading(size: 17, weight: FontWeight.w800)),
      const SizedBox(height: 4),
      const Text('Used for EMD refunds, balance payouts, and reverse procurement settlements.', style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B))),
      const SizedBox(height: 16),
      TextField(controller: _bankNameCtl, decoration: const InputDecoration(labelText: 'Bank Name *', border: OutlineInputBorder())),
      const SizedBox(height: 12),
      TextField(controller: _accountNoCtl, decoration: const InputDecoration(labelText: 'Account Number *', border: OutlineInputBorder())),
      const SizedBox(height: 12),
      TextField(controller: _ifscCtl, decoration: const InputDecoration(labelText: 'IFSC Code *', border: OutlineInputBorder())),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        value: _accountType,
        decoration: const InputDecoration(labelText: 'Account Type *', border: OutlineInputBorder()),
        items: ['Current Account', 'Cash Credit / Overdraft', 'Escrow Account']
            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
            .toList(),
        onChanged: (v) => setState(() => _accountType = v ?? _accountType),
      ),
      const SizedBox(height: 14),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 20),
            const SizedBox(width: 8),
            const Expanded(
              child: Text('Penny-Drop ₹1.00 verification successful: Account active in name of Devzign Solutions Pvt Ltd',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.success)),
            ),
          ],
        ),
      ),
    ]);
  }

  Widget _stepSignatory() {
    return _cardContainer(children: [
      Text('Authorised Signatory & Key Contact', style: AppTextStyles.heading(size: 17, weight: FontWeight.w800)),
      const SizedBox(height: 16),
      TextField(controller: _signatoryNameCtl, decoration: const InputDecoration(labelText: 'Signatory Full Name *', border: OutlineInputBorder())),
      const SizedBox(height: 12),
      TextField(controller: _designationCtl, decoration: const InputDecoration(labelText: 'Official Designation *', border: OutlineInputBorder())),
      const SizedBox(height: 12),
      TextField(controller: _signatoryEmailCtl, decoration: const InputDecoration(labelText: 'Corporate Email *', border: OutlineInputBorder())),
      const SizedBox(height: 12),
      TextField(controller: _signatoryPhoneCtl, decoration: const InputDecoration(labelText: 'Direct Mobile *', border: OutlineInputBorder())),
    ]);
  }

  Widget _stepCapabilities() {
    return _cardContainer(children: [
      Text('Business Capabilities & Turnover', style: AppTextStyles.heading(size: 17, weight: FontWeight.w800)),
      const SizedBox(height: 16),
      DropdownButtonFormField<String>(
        value: _turnoverBand,
        decoration: const InputDecoration(labelText: 'Annual Turnover Band *', border: OutlineInputBorder()),
        items: ['< ₹5 Cr', '₹5 Cr – ₹25 Cr', '₹25 Cr – ₹100 Cr', '> ₹100 Cr (Tier 1)']
            .map((b) => DropdownMenuItem(value: b, child: Text(b)))
            .toList(),
        onChanged: (v) => setState(() => _turnoverBand = v ?? _turnoverBand),
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        value: _yearsInBusiness,
        decoration: const InputDecoration(labelText: 'Years in Commercial Operation *', border: OutlineInputBorder()),
        items: ['1 - 3 Years', '3 - 5 Years', '5+ Years', '10+ Years']
            .map((y) => DropdownMenuItem(value: y, child: Text(y)))
            .toList(),
        onChanged: (v) => setState(() => _yearsInBusiness = v ?? _yearsInBusiness),
      ),
      const SizedBox(height: 12),
      TextField(controller: _annualCapacityCtl, decoration: const InputDecoration(labelText: 'Handling / Processing Capacity *', border: OutlineInputBorder())),
    ]);
  }

  Widget _stepCompliance() {
    return _cardContainer(children: [
      Text('Compliance & Documents', style: AppTextStyles.heading(size: 17, weight: FontWeight.w800)),
      const SizedBox(height: 4),
      const Text('All 6 essential documents verified for instant Tier clearance.', style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B))),
      const SizedBox(height: 16),
      ..._complianceDocs.entries.map((e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                const Icon(Icons.task_alt, color: AppColors.success, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text(e.key, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.navy))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)),
                  child: const Text('Uploaded', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.success)),
                ),
              ],
            ),
          )),
    ]);
  }

  Widget _stepTermsPact() {
    return _cardContainer(children: [
      Text('Platform Integrity Pact & Undertakings', style: AppTextStyles.heading(size: 17, weight: FontWeight.w800)),
      const SizedBox(height: 16),
      CheckboxListTile(
        value: _acceptIntegrityPact,
        activeColor: AppColors.navy,
        title: const Text('Anti-Collusion & Fair Bidding Undertaking', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        subtitle: const Text('I confirm zero cartelization or bid-rigging with competitor vendors.', style: TextStyle(fontSize: 11.5)),
        contentPadding: EdgeInsets.zero,
        onChanged: (v) => setState(() => _acceptIntegrityPact = v ?? false),
      ),
      const Divider(),
      CheckboxListTile(
        value: _acceptH1Commitment,
        activeColor: AppColors.navy,
        title: const Text('H1 / L1 Binding Award Commitment', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        subtitle: const Text('Bids placed during live auctions are irrevocable commercial commitments.', style: TextStyle(fontSize: 11.5)),
        contentPadding: EdgeInsets.zero,
        onChanged: (v) => setState(() => _acceptH1Commitment = v ?? false),
      ),
      const Divider(),
      CheckboxListTile(
        value: _acceptPlatformFees,
        activeColor: AppColors.navy,
        title: const Text('Success Fee & EMD Forfeiture Conditions', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        subtitle: const Text('I agree to the standard platform success fee schedule and EMD escrow terms.', style: TextStyle(fontSize: 11.5)),
        contentPadding: EdgeInsets.zero,
        onChanged: (v) => setState(() => _acceptPlatformFees = v ?? false),
      ),
    ]);
  }

  Widget _stepReviewSubmit() {
    return _cardContainer(children: [
      Center(child: const Icon(Icons.verified_user_rounded, color: AppColors.navy, size: 48)),
      const SizedBox(height: 12),
      Center(child: Text('Review & Final Submission', style: AppTextStyles.heading(size: 18, weight: FontWeight.w900))),
      const SizedBox(height: 4),
      const Center(child: Text('Verify your enterprise credentials before transmitting to compliance desk.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)))),
      const SizedBox(height: 20),
      _reviewRow('Legal Entity', _legalNameCtl.text),
      _reviewRow('Constitution', _companyType),
      _reviewRow('GSTIN', _gstinCtl.text),
      _reviewRow('Operating State', _state),
      _reviewRow('Categories', '${_selectedCategories.length} Sectors Selected'),
      _reviewRow('Settlement Bank', _bankNameCtl.text),
      _reviewRow('Authorized Signatory', '${_signatoryNameCtl.text} (${_designationCtl.text})'),
      _reviewRow('Turnover Band', _turnoverBand),
      _reviewRow('Compliance Docs', '6 of 6 Verified'),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.auction.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
        child: const Text(
          'Upon submission, our compliance desk will verify your CIN and GST credentials within 4 business hours.',
          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.auction),
        ),
      ),
    ]);
  }

  Widget _reviewRow(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
          Flexible(child: Text(v, textAlign: TextAlign.right, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.navy))),
        ],
      ),
    );
  }
}
