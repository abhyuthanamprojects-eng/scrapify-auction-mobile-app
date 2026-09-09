import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/asset_paths.dart';
import '../../providers/auth_provider.dart';
import '../../services/vendor_service.dart';

class SignupScreen extends ConsumerStatefulWidget {
  final String? prefillIdentifier;
  const SignupScreen({super.key, this.prefillIdentifier});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  int _step = 1;
  String _registrationRole = 'buyer';

  // Step 1
  final _mobileCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _otpCtl = TextEditingController();
  bool _otpSent = false;
  int _timer = 0;
  String? _debugCode;

  // Step 2
  bool _useEmail = true;
  final _passwordCtl = TextEditingController();
  final _password2Ctl = TextEditingController();

  // Step 3
  final _companyCtl = TextEditingController();
  final _addressCtl = TextEditingController();
  final _gstCtl = TextEditingController();
  final _panCtl = TextEditingController();
  final _licenseCtl = TextEditingController();
  final _contactCtl = TextEditingController();
  final _bizMobileCtl = TextEditingController();
  final _bizEmailCtl = TextEditingController();
  final _bankAccountCtl = TextEditingController();
  final _bankIfscCtl = TextEditingController();
  final _bankNameCtl = TextEditingController();
  final Set<String> _materials = {};
  final Map<String, bool> _docs = {
    'license': false,
    'gst': false,
    'pan': false,
    'cheque': false,
  };
  bool _termsAccepted = false;

  // Step 4
  String? _paymentMethod;
  String _phase = 'review'; // review | payment | pending | approved

  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final id = widget.prefillIdentifier ?? '';
    if (id.contains('@')) {
      _emailCtl.text = id;
    } else if (id.isNotEmpty) {
      _mobileCtl.text = id;
    }
  }

  @override
  void dispose() {
    _mobileCtl.dispose();
    _emailCtl.dispose();
    _otpCtl.dispose();
    _passwordCtl.dispose();
    _password2Ctl.dispose();
    _companyCtl.dispose();
    _addressCtl.dispose();
    _gstCtl.dispose();
    _panCtl.dispose();
    _licenseCtl.dispose();
    _contactCtl.dispose();
    _bizMobileCtl.dispose();
    _bizEmailCtl.dispose();
    _bankAccountCtl.dispose();
    _bankIfscCtl.dispose();
    _bankNameCtl.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() => _timer = 30);
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _timer = max(0, _timer - 1));
      return _timer > 0;
    });
  }

  void _setError(String? e) => setState(() => _error = e);
  void _setLoading(bool v) => setState(() => _loading = v);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
              child: Column(
                children: [
                  if (_step == 1) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'How will you use Scrapify?',
                        style: AppTextStyles.heading(size: 18),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Buyer'),
                            selected: _registrationRole == 'buyer',
                            onSelected: (_) =>
                                setState(() => _registrationRole = 'buyer'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Seller'),
                            selected: _registrationRole == 'seller',
                            onSelected: (_) =>
                                setState(() => _registrationRole = 'seller'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                  ],
                  _buildStep(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── HEADER ───────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      color: AppColors.navy,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            children: [
              Row(
                children: [
                  _headerIconBtn(Icons.arrow_back, () {
                    if (_step > 1) {
                      setState(() {
                        _step--;
                        _error = null;
                      });
                    } else {
                      context.pop();
                    }
                  }),
                  const SizedBox(width: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 32,
                      height: 32,
                      color: AppColors.white,
                      padding: const EdgeInsets.all(3),
                      child: Image.asset(
                        AssetPaths.appIcon,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.gavel,
                          size: 18,
                          color: AppColors.auction,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_registrationRole.toUpperCase()} REGISTRATION',
                          style: AppTextStyles.body(
                            size: 10,
                            weight: FontWeight.w700,
                            color: AppColors.whiteWithOpacity(0.6),
                          ).copyWith(letterSpacing: 1.5),
                        ),
                        Text(
                          'Step $_step of 4',
                          style: AppTextStyles.body(
                            size: 14,
                            weight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildProgressBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerIconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.whiteWithOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Icon(icon, size: 16, color: AppColors.white),
      ),
    );
  }

  Widget _buildProgressBar() {
    const labels = ['Verify', 'Login', 'Company', 'Complete'];
    return Row(
      children: List.generate(4, (i) {
        final stepNum = i + 1;
        final active = _step == stepNum;
        final done = _step > stepNum;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < 3 ? 4 : 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              decoration: BoxDecoration(
                color: active
                    ? AppColors.auction
                    : done
                    ? AppColors.successWithOpacity(0.2)
                    : AppColors.whiteWithOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: active
                          ? AppColors.white
                          : done
                          ? AppColors.success
                          : AppColors.whiteWithOpacity(0.2),
                    ),
                    child: Center(
                      child: done
                          ? const Icon(
                              Icons.check,
                              size: 10,
                              color: AppColors.white,
                            )
                          : Text(
                              '$stepNum',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: active
                                    ? AppColors.auction
                                    : AppColors.whiteWithOpacity(0.6),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      labels[i],
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                        color: active
                            ? AppColors.white
                            : done
                            ? AppColors.success
                            : AppColors.whiteWithOpacity(0.6),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // ─── STEP ROUTER ──────────────────────────────────────────
  Widget _buildStep() {
    return switch (_step) {
      1 => _step1Verify(),
      2 => _step2Login(),
      3 => _step3Company(),
      4 => _step4Complete(),
      _ => const SizedBox.shrink(),
    };
  }

  // ─── STEP 1: VERIFY ──────────────────────────────────────
  Widget _step1Verify() {
    final mobileValid = RegExp(
      r'^\d{10}$',
    ).hasMatch(_mobileCtl.text.replaceAll(RegExp(r'\D'), ''));
    final emailValid =
        _emailCtl.text.contains('@') && _emailCtl.text.contains('.');
    final canSend = mobileValid && emailValid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Verify your identity', style: AppTextStyles.titleMedium),
        const SizedBox(height: 4),
        Text(
          'A one-time code will be sent to both your mobile number and email.',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: 20),
        _fieldLabel('Mobile Number', required: true),
        const SizedBox(height: 6),
        _inputField(
          controller: _mobileCtl,
          hint: '98765 43210',
          keyboardType: TextInputType.phone,
          prefix: Padding(
            padding: const EdgeInsets.only(left: 12, right: 4),
            child: Text(
              '+91',
              style: AppTextStyles.body(size: 14, weight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _fieldLabel(
          'Email ID',
          required: true,
          hint: 'OTP will be sent to both mobile & email.',
        ),
        const SizedBox(height: 6),
        _inputField(
          controller: _emailCtl,
          hint: 'you@company.com',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        if (_error != null) ...[
          _errorBanner(_error!),
          const SizedBox(height: 12),
        ],
        if (!_otpSent) ...[
          _primaryButton(
            label: 'Send OTP to mobile & email',
            enabled: canSend && !_loading,
            loading: _loading,
            onTap: _sendOtp,
          ),
        ] else ...[
          _infoBanner(
            'OTP sent to +91 ${_mobileCtl.text} and ${_emailCtl.text}. Enter the code below.',
          ),
          const SizedBox(height: 16),
          if (_debugCode != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.successWithOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.successWithOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.bug_report,
                    size: 14,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Debug OTP: $_debugCode',
                    style: AppTextStyles.body(
                      size: 12,
                      weight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          _fieldLabel('Enter OTP', required: true),
          const SizedBox(height: 6),
          _inputField(
            controller: _otpCtl,
            hint: '4–6 digit code',
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            letterSpacing: 8,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Didn't get it?", style: AppTextStyles.caption),
              GestureDetector(
                onTap: _timer > 0 ? null : _sendOtp,
                child: Text(
                  _timer > 0 ? 'Resend in ${_timer}s' : 'Resend OTP',
                  style: AppTextStyles.body(
                    size: 11,
                    weight: FontWeight.w700,
                    color: _timer > 0
                        ? AppColors.navyWithOpacity(0.3)
                        : AppColors.accentBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _primaryButton(
            label: 'Verify & Continue',
            color: AppColors.auction,
            icon: Icons.arrow_forward,
            enabled: _otpCtl.text.length >= 4 && !_loading,
            loading: _loading,
            onTap: _verifyOtp,
          ),
        ],
      ],
    );
  }

  Future<void> _sendOtp() async {
    _setError(null);
    _setLoading(true);
    final result = await ref
        .read(authProvider.notifier)
        .requestOtp(_emailCtl.text.trim(), purpose: 'registration');
    if (!mounted) return;
    _setLoading(false);
    setState(() {
      _otpSent = true;
      _debugCode = result.debugCode;
    });
    _startTimer();
  }

  Future<void> _verifyOtp() async {
    _setError(null);
    _setLoading(true);
    final success = await ref
        .read(authProvider.notifier)
        .verifyOtp(_emailCtl.text.trim(), _otpCtl.text.trim());
    if (!mounted) return;
    _setLoading(false);
    if (success) {
      setState(() {
        _step = 2;
        _error = null;
      });
    } else {
      final err = ref.read(authProvider).error;
      _setError(err.isNotEmpty ? err : 'Invalid OTP. Please try again.');
    }
  }

  // ─── STEP 2: LOGIN ───────────────────────────────────────
  Widget _step2Login() {
    final pw = _passwordCtl.text;
    final strong =
        pw.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(pw) &&
        RegExp(r'\d').hasMatch(pw);
    final match = pw.isNotEmpty && pw == _password2Ctl.text;
    final username = _useEmail ? _emailCtl.text : '+91${_mobileCtl.text}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Create your login', style: AppTextStyles.titleMedium),
        const SizedBox(height: 4),
        Text(
          'Your username is your verified email or mobile — we don\'t create a separate one.',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.blackWithOpacity(0.05)),
          ),
          child: Row(
            children: [
              _toggleBtn(
                'Use Email',
                _useEmail,
                () => setState(() => _useEmail = true),
              ),
              _toggleBtn(
                'Use Mobile',
                !_useEmail,
                () => setState(() => _useEmail = false),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _fieldLabel('Username (auto-filled)', required: true),
        const SizedBox(height: 6),
        _inputField(
          controller: TextEditingController(text: username),
          readOnly: true,
        ),
        const SizedBox(height: 16),
        _fieldLabel(
          'Create Password',
          required: true,
          hint: 'Min 8 characters, 1 uppercase, 1 number.',
        ),
        const SizedBox(height: 6),
        _inputField(
          controller: _passwordCtl,
          hint: '••••••••',
          obscure: true,
          onChanged: (_) => setState(() {}),
        ),
        if (pw.isNotEmpty && !strong) ...[
          const SizedBox(height: 4),
          Text(
            'Password too weak.',
            style: TextStyle(
              fontSize: 10,
              color: AppColors.destructive,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const SizedBox(height: 16),
        _fieldLabel('Confirm Password', required: true),
        const SizedBox(height: 6),
        _inputField(
          controller: _password2Ctl,
          hint: 'Re-enter password',
          obscure: true,
          onChanged: (_) => setState(() {}),
        ),
        if (_password2Ctl.text.isNotEmpty && !match) ...[
          const SizedBox(height: 4),
          Text(
            'Passwords do not match.',
            style: TextStyle(
              fontSize: 10,
              color: AppColors.destructive,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const SizedBox(height: 8),
        if (_error != null) ...[
          _errorBanner(_error!),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 16),
        _primaryButton(
          label: 'Save & Continue',
          color: AppColors.auction,
          icon: Icons.arrow_forward,
          enabled: strong && match && !_loading,
          loading: _loading,
          onTap: () async {
            _setError(null);
            _setLoading(true);
            try {
              await ref
                  .read(authProvider.notifier)
                  .register(
                    name: _contactCtl.text.isNotEmpty
                        ? _contactCtl.text
                        : _emailCtl.text.split('@').first,
                    email: _emailCtl.text.trim(),
                    phone: _mobileCtl.text.trim(),
                    password: _passwordCtl.text,
                    role: _registrationRole,
                  );
              if (!mounted) return;
              final state = ref.read(authProvider);
              if (state.isAuthenticated) {
                setState(() {
                  _step = 3;
                  _error = null;
                });
              } else if (state.hasError) {
                _setError(state.error);
              }
            } finally {
              if (mounted) _setLoading(false);
            }
          },
        ),
      ],
    );
  }

  Widget _toggleBtn(String label, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: selected ? AppColors.navy : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.blackWithOpacity(0.1),
                      blurRadius: 4,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected
                    ? AppColors.white
                    : AppColors.navyWithOpacity(0.6),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── STEP 3: COMPANY ─────────────────────────────────────
  Widget _step3Company() {
    final allDocsUploaded = _docs.values.every((v) => v);
    final complete =
        _companyCtl.text.isNotEmpty &&
        _addressCtl.text.isNotEmpty &&
        _gstCtl.text.isNotEmpty &&
        _panCtl.text.isNotEmpty &&
        _licenseCtl.text.isNotEmpty &&
        _materials.isNotEmpty &&
        _contactCtl.text.isNotEmpty &&
        _bizMobileCtl.text.isNotEmpty &&
        _bizEmailCtl.text.isNotEmpty &&
        _bankAccountCtl.text.isNotEmpty &&
        _bankIfscCtl.text.isNotEmpty &&
        _bankNameCtl.text.isNotEmpty &&
        allDocsUploaded &&
        _termsAccepted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Company information', style: AppTextStyles.titleMedium),
        const SizedBox(height: 4),
        Text('All fields required for KYC.', style: AppTextStyles.caption),
        const SizedBox(height: 20),

        _fieldLabel('Company Name', required: true),
        const SizedBox(height: 6),
        _inputField(controller: _companyCtl),
        const SizedBox(height: 16),

        _fieldLabel('Registered Address', required: true),
        const SizedBox(height: 6),
        _inputField(controller: _addressCtl, maxLines: 2),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('GST Number', required: true),
                  const SizedBox(height: 6),
                  _inputField(controller: _gstCtl, hint: '29ABCDE1234F1Z5'),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('PAN Number', required: true),
                  const SizedBox(height: 6),
                  _inputField(controller: _panCtl, hint: 'ABCDE1234F'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        _fieldLabel('Recycler / Trade Licence Number', required: true),
        const SizedBox(height: 6),
        _inputField(controller: _licenseCtl, hint: 'TN/REC/2026/00812'),
        const SizedBox(height: 20),

        _fieldLabel('Material Interest', required: true),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppConstants.categories.map((m) {
            final on = _materials.contains(m);
            return GestureDetector(
              onTap: () =>
                  setState(() => on ? _materials.remove(m) : _materials.add(m)),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: on ? AppColors.navy : AppColors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  border: Border.all(
                    color: on
                        ? AppColors.navy
                        : AppColors.blackWithOpacity(0.1),
                  ),
                ),
                child: Text(
                  m,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: on
                        ? AppColors.white
                        : AppColors.navyWithOpacity(0.7),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        _fieldLabel('Contact Person Name', required: true),
        const SizedBox(height: 6),
        _inputField(controller: _contactCtl),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('Business Mobile', required: true),
                  const SizedBox(height: 6),
                  _inputField(
                    controller: _bizMobileCtl,
                    hint: '+91 …',
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('Business Email', required: true),
                  const SizedBox(height: 6),
                  _inputField(
                    controller: _bizEmailCtl,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        _fieldLabel('Bank Details (for EMD refunds)'),
        const SizedBox(height: 8),
        _inputField(controller: _bankAccountCtl, hint: 'Account number'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _inputField(controller: _bankIfscCtl, hint: 'IFSC'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _inputField(controller: _bankNameCtl, hint: 'Bank name'),
            ),
          ],
        ),
        const SizedBox(height: 20),

        _fieldLabel('Documents (all 4 required)'),
        const SizedBox(height: 8),
        _docRow('Recycler / Trade Licence', 'license'),
        const SizedBox(height: 8),
        _docRow('GST Certificate', 'gst'),
        const SizedBox(height: 8),
        _docRow('PAN Card', 'pan'),
        const SizedBox(height: 8),
        _docRow('Cancelled Cheque / Bank Details', 'cheque'),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            border: Border.all(color: AppColors.blackWithOpacity(0.05)),
            boxShadow: [
              BoxShadow(color: AppColors.blackWithOpacity(0.03), blurRadius: 8),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Checkbox(
                  value: _termsAccepted,
                  onChanged: (v) => setState(() => _termsAccepted = v ?? false),
                  activeColor: AppColors.navy,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showTerms(),
                  child: Text.rich(
                    TextSpan(
                      text: 'I have read and accept the ',
                      style: AppTextStyles.body(size: 11),
                      children: [
                        TextSpan(
                          text: 'Terms & Conditions',
                          style: AppTextStyles.body(
                            size: 11,
                            weight: FontWeight.w700,
                            color: AppColors.accentBlue,
                          ),
                        ),
                        const TextSpan(text: '.'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (_error != null) ...[
          _errorBanner(_error!),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 16),
        _primaryButton(
          label: 'Continue',
          color: AppColors.auction,
          icon: Icons.arrow_forward,
          enabled: complete && !_loading,
          loading: _loading,
          onTap: () async {
            _setError(null);
            _setLoading(true);
            try {
              final vendorService = VendorService();
              await vendorService.register(
                companyName: _companyCtl.text.trim(),
                contactName: _contactCtl.text.trim(),
                email: _bizEmailCtl.text.trim(),
                phone: _bizMobileCtl.text.trim(),
                address: _addressCtl.text.trim(),
                gstNumber: _gstCtl.text.trim(),
                panNumber: _panCtl.text.trim(),
                licenseNumber: _licenseCtl.text.trim(),
                materialInterest: _materials.toList(),
                termsAccepted: _termsAccepted,
              );
              if (!mounted) return;
              setState(() {
                _step = 4;
                _phase = 'review';
                _error = null;
              });
            } catch (e) {
              if (mounted) _setError(e.toString());
            } finally {
              if (mounted) _setLoading(false);
            }
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _docRow(String label, String key) {
    final done = _docs[key] ?? false;
    return GestureDetector(
      onTap: () => setState(() => _docs[key] = true),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.blackWithOpacity(0.05)),
          boxShadow: [
            BoxShadow(color: AppColors.blackWithOpacity(0.03), blurRadius: 8),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: done
                    ? AppColors.successWithOpacity(0.15)
                    : AppColors.navyWithOpacity(0.05),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Icon(
                done ? Icons.check : Icons.upload_file,
                size: 16,
                color: done
                    ? AppColors.success
                    : AppColors.navyWithOpacity(0.7),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.body(
                      size: 13,
                      weight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    done ? 'Uploaded' : 'Tap to upload',
                    style: AppTextStyles.captionMuted,
                  ),
                ],
              ),
            ),
            if (done)
              Text(
                'Uploaded ✓',
                style: AppTextStyles.body(
                  size: 10,
                  weight: FontWeight.w700,
                  color: AppColors.success,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showTerms() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollCtl) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Terms & Conditions', style: AppTextStyles.labelLarge),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Text(
                      'Close',
                      style: AppTextStyles.body(
                        size: 12,
                        weight: FontWeight.w700,
                        color: AppColors.navyWithOpacity(0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                controller: scrollCtl,
                padding: const EdgeInsets.all(16),
                children: const [
                  _TermItem(
                    num: '1',
                    title: 'Registration',
                    text:
                        'By registering as a bidder you agree to provide accurate KYC details and documents.',
                  ),
                  _TermItem(
                    num: '2',
                    title: 'EMD',
                    text:
                        'A refundable Earnest Money Deposit is required to bid on each lot.',
                  ),
                  _TermItem(
                    num: '3',
                    title: 'Winning bids',
                    text:
                        'Winning bidders must pay the balance within 48 hours or forfeit their EMD.',
                  ),
                  _TermItem(
                    num: '4',
                    title: 'Pickup & weighbridge',
                    text:
                        'Lot weights are verified at an authorised weighbridge. Variances are adjusted from the balance.',
                  ),
                  _TermItem(
                    num: '5',
                    title: 'Compliance',
                    text:
                        'Bidders must hold valid PCB / Recycler authorisation where applicable.',
                  ),
                  _TermItem(
                    num: '6',
                    title: 'Refunds',
                    text:
                        'EMD of losing bidders is auto-released within 2 hours of auction close.',
                  ),
                  _TermItem(
                    num: '7',
                    title: 'Approval',
                    text:
                        'Registration is subject to admin approval and may be rejected without cause.',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: AppSpacing.buttonXl,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => _termsAccepted = true);
                    Navigator.pop(ctx);
                  },
                  child: const Text('I Accept'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── STEP 4: COMPLETE ────────────────────────────────────
  Widget _step4Complete() {
    return switch (_phase) {
      'review' => _reviewPhase(),
      'payment' => _paymentPhase(),
      'pending' => _pendingPhase(),
      'approved' => _approvedPhase(),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _reviewPhase() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Review your details', style: AppTextStyles.titleMedium),
        const SizedBox(height: 4),
        Text(
          'All information from steps 1–3 has been validated.',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: 20),
        _reviewGroup('Verification', [
          _reviewRow('Mobile', '+91 ${_mobileCtl.text}'),
          _reviewRow('Email', _emailCtl.text),
          _reviewRow('OTP verified', '✓ Yes', isOk: true),
        ]),
        const SizedBox(height: 12),
        _reviewGroup('Login', [
          _reviewRow(
            'Username',
            _useEmail ? _emailCtl.text : '+91${_mobileCtl.text}',
          ),
          _reviewRow('Password', '•••••••• (set)'),
        ]),
        const SizedBox(height: 12),
        _reviewGroup('Company', [
          _reviewRow('Company', _companyCtl.text),
          _reviewRow('GST', _gstCtl.text),
          _reviewRow('PAN', _panCtl.text),
          _reviewRow('Contact', _contactCtl.text),
          _reviewRow('Business phone', _bizMobileCtl.text),
          _reviewRow('Business email', _bizEmailCtl.text),
          _reviewRow('Docs', 'All 4 uploaded', isOk: true),
          _reviewRow('T&C', 'Accepted', isOk: true),
        ]),
        const SizedBox(height: 20),
        _primaryButton(
          label: 'Proceed to Payment',
          onTap: () => setState(() => _phase = 'payment'),
        ),
      ],
    );
  }

  Widget _reviewGroup(String title, List<Widget> rows) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.blackWithOpacity(0.05)),
        boxShadow: [
          BoxShadow(color: AppColors.blackWithOpacity(0.03), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: AppTextStyles.body(
              size: 10,
              weight: FontWeight.w700,
              color: AppColors.navyWithOpacity(0.6),
            ).copyWith(letterSpacing: 0.8),
          ),
          const SizedBox(height: 8),
          ...rows,
        ],
      ),
    );
  }

  Widget _reviewRow(String key, String value, {bool isOk = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            key,
            style: AppTextStyles.body(
              size: 12,
              color: AppColors.navyWithOpacity(0.6),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: AppTextStyles.body(
                size: 12,
                weight: FontWeight.w700,
                color: isOk ? AppColors.success : AppColors.navy,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentPhase() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Registration fee', style: AppTextStyles.titleMedium),
        const SizedBox(height: 4),
        Text(
          'Pay the one-time registration fee to submit for admin review.',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.navy,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AMOUNT',
                style: AppTextStyles.body(
                  size: 10,
                  weight: FontWeight.w700,
                  color: AppColors.whiteWithOpacity(0.6),
                ).copyWith(letterSpacing: 1.5),
              ),
              const SizedBox(height: 4),
              Text(
                '₹5,000',
                style: AppTextStyles.heading(
                  size: 28,
                  weight: FontWeight.w900,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'GST included · one-time · non-refundable',
                style: AppTextStyles.body(
                  size: 11,
                  color: AppColors.whiteWithOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _fieldLabel('Choose payment method'),
        const SizedBox(height: 8),
        Row(
          children: ['RTGS', 'NEFT', 'UPI'].map((m) {
            final selected = _paymentMethod == m;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: m != 'UPI' ? 8 : 0),
                child: GestureDetector(
                  onTap: () => setState(() => _paymentMethod = m),
                  child: Container(
                    height: 72,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.auction : AppColors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      border: Border.all(
                        color: selected
                            ? AppColors.auction
                            : AppColors.blackWithOpacity(0.05),
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: AppColors.auctionWithOpacity(0.3),
                                blurRadius: 8,
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: AppColors.blackWithOpacity(0.03),
                                blurRadius: 4,
                              ),
                            ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.account_balance,
                          size: 18,
                          color: selected ? AppColors.white : AppColors.navy,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          m,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: selected ? AppColors.white : AppColors.navy,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (_error != null) ...[
          const SizedBox(height: 16),
          _errorBanner(_error!),
        ],
        const SizedBox(height: 24),
        _primaryButton(
          label: 'Submit Payment · ${_paymentMethod ?? "select method"}',
          color: AppColors.auction,
          enabled: _paymentMethod != null && !_loading,
          loading: _loading,
          onTap: () async {
            _setError(null);
            _setLoading(true);
            try {
              final user = ref.read(authProvider).user;
              if (user?.vendorCode != null) {
                final vendorService = VendorService();
                await vendorService.recordPayment(
                  vendorCode: user!.vendorCode!,
                  method: _paymentMethod!,
                  reference: 'REG-${DateTime.now().millisecondsSinceEpoch}',
                  amount: 5000,
                );
              }
              if (!mounted) return;
              setState(() {
                _phase = 'pending';
                _error = null;
              });
            } catch (e) {
              if (mounted) _setError(e.toString());
            } finally {
              if (mounted) _setLoading(false);
            }
          },
        ),
      ],
    );
  }

  Widget _pendingPhase() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.auctionWithOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            border: Border.all(color: AppColors.auctionWithOpacity(0.3)),
          ),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.auctionWithOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.schedule,
                  size: 24,
                  color: AppColors.auction,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Submitted — Pending Admin Review',
                style: AppTextStyles.labelLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Your registration is being reviewed. You can browse auctions, but bidding is locked until approval. You\'ll receive an email + SMS once approved.',
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            border: Border.all(color: AppColors.blackWithOpacity(0.05)),
            boxShadow: [
              BoxShadow(color: AppColors.blackWithOpacity(0.03), blurRadius: 8),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'APPLICATION ID',
                style: AppTextStyles.body(
                  size: 10,
                  weight: FontWeight.w700,
                  color: AppColors.navyWithOpacity(0.6),
                ).copyWith(letterSpacing: 0.8),
              ),
              const SizedBox(height: 4),
              Text(
                'SCR-REG-2026-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                style: AppTextStyles.labelLarge,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _primaryButton(
          label: 'Continue Browsing',
          onTap: () => context.go('/home'),
        ),
      ],
    );
  }

  Widget _approvedPhase() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.successWithOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            border: Border.all(color: AppColors.successWithOpacity(0.3)),
          ),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.successWithOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 24,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Approved — You can now bid',
                style: AppTextStyles.labelLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Bidding features are now unlocked across the app.',
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _primaryButton(
          label: 'Start Bidding',
          color: AppColors.auction,
          onTap: () => context.go('/home'),
        ),
      ],
    );
  }

  // ─── SHARED WIDGETS ──────────────────────────────────────
  Widget _fieldLabel(String label, {bool required = false, String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: label.toUpperCase(),
                style: AppTextStyles.body(
                  size: 10,
                  weight: FontWeight.w700,
                  color: AppColors.navyWithOpacity(0.6),
                ).copyWith(letterSpacing: 0.8),
              ),
              if (required)
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.auction,
                  ),
                ),
            ],
          ),
        ),
        if (hint != null) ...[
          const SizedBox(height: 2),
          Text(hint, style: AppTextStyles.captionMuted),
        ],
      ],
    );
  }

  Widget _inputField({
    TextEditingController? controller,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    bool readOnly = false,
    int maxLines = 1,
    TextAlign textAlign = TextAlign.start,
    double letterSpacing = 0,
    Widget? prefix,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      readOnly: readOnly,
      maxLines: maxLines,
      textAlign: textAlign,
      onChanged: onChanged,
      style: AppTextStyles.body(
        size: 14,
        weight: FontWeight.w500,
      ).copyWith(letterSpacing: letterSpacing),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: prefix,
        prefixIconConstraints: prefix != null
            ? const BoxConstraints(minWidth: 0)
            : null,
        filled: true,
        fillColor: readOnly ? AppColors.navyWithOpacity(0.05) : AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: BorderSide(color: AppColors.blackWithOpacity(0.05)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: BorderSide(color: AppColors.blackWithOpacity(0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: const BorderSide(color: AppColors.navy, width: 2),
        ),
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    required VoidCallback onTap,
    Color color = AppColors.navy,
    IconData? icon,
    bool enabled = true,
    bool loading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: AppSpacing.buttonXl,
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: color.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (icon != null) ...[
                    const SizedBox(width: 6),
                    Icon(icon, size: 16),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _errorBanner(String msg) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.destructiveWithOpacity(0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            size: 16,
            color: AppColors.destructive,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              msg,
              style: TextStyle(fontSize: 12, color: AppColors.destructive),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBanner(String msg) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.accentBlueWithOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.accentBlueWithOpacity(0.2)),
      ),
      child: Text(
        msg,
        style: AppTextStyles.body(size: 11, color: AppColors.accentBlue),
      ),
    );
  }
}

class _TermItem extends StatelessWidget {
  final String num;
  final String title;
  final String text;
  const _TermItem({required this.num, required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$num. $title. ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: text),
          ],
          style: AppTextStyles.body(
            size: 12,
            color: AppColors.navyWithOpacity(0.7),
          ),
        ),
      ),
    );
  }
}
