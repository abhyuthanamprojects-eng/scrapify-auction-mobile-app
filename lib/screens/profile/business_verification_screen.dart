import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../providers/auth_provider.dart';
import '../../services/vendor_service.dart';
import '../../widgets/shared/screen_header.dart';

class BusinessVerificationScreen extends ConsumerStatefulWidget {
  const BusinessVerificationScreen({super.key});
  @override
  ConsumerState<BusinessVerificationScreen> createState() =>
      _BusinessVerificationScreenState();
}

class _BusinessVerificationScreenState
    extends ConsumerState<BusinessVerificationScreen>
    with WidgetsBindingObserver {
  final _service = VendorService();

  final _gstinCtrl = TextEditingController();
  final _businessNameCtrl = TextEditingController();
  final _accountCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _ifscCtrl = TextEditingController();
  final _holderNameCtrl = TextEditingController();

  Map<String, dynamic> _status = {};
  Map<String, dynamic>? _identityStatus;
  bool _loading = true;
  bool _busy = false;
  bool _identityBusy = false;
  String? _message;
  bool _prefilled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
    _loadIdentityStatus();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadIdentityStatus();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _gstinCtrl.dispose();
    _businessNameCtrl.dispose();
    _accountCtrl.dispose();
    _confirmCtrl.dispose();
    _ifscCtrl.dispose();
    _holderNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final r = await _service.getBusinessVerification();
      if (mounted) {
        setState(() => _status = Map<String, dynamic>.from(r['data'] ?? r));
        _prefillFromVendor();
      }
    } catch (_) {
      if (mounted) setState(() => _message = 'Could not load verification status.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadIdentityStatus() async {
    try {
      final r = await _service.getIdentityVerificationStatus();
      if (mounted) {
        setState(() => _identityStatus = Map<String, dynamic>.from(r['data'] ?? r));
      }
    } catch (_) {}
  }

  Future<void> _startDigiLocker() async {
    setState(() { _identityBusy = true; _message = null; });
    try {
      final config = await _service.getPlatformConfig();
      final siteUrl = (config['data']?['site_url'] ?? config['site_url'] ?? '') as String;
      final redirectUri = siteUrl.isNotEmpty
          ? '$siteUrl/business-verification'
          : 'https://scrapifyauctions.com/business-verification';

      final r = await _service.initiateDigiLocker(redirectUri);
      final data = r['data'] ?? r;

      if (data['already_verified'] == true) {
        setState(() => _identityStatus = Map<String, dynamic>.from(data));
        if (mounted) _showSuccess('Identity is already verified');
        return;
      }

      final authUrl = data['authorization_url'] as String?;
      if (authUrl != null && authUrl.isNotEmpty) {
        final uri = Uri.parse(authUrl);
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) setState(() => _message = 'Could not start DigiLocker verification.');
    } finally {
      if (mounted) setState(() => _identityBusy = false);
    }
  }

  Future<void> _retryDigiLocker() async {
    setState(() { _identityBusy = true; _message = null; });
    try {
      final config = await _service.getPlatformConfig();
      final siteUrl = (config['data']?['site_url'] ?? config['site_url'] ?? '') as String;
      final redirectUri = siteUrl.isNotEmpty
          ? '$siteUrl/business-verification'
          : 'https://scrapifyauctions.com/business-verification';

      final r = await _service.retryDigiLocker(redirectUri);
      final data = r['data'] ?? r;

      if (data['already_verified'] == true) {
        setState(() => _identityStatus = Map<String, dynamic>.from(data));
        return;
      }

      final authUrl = data['authorization_url'] as String?;
      if (authUrl != null && authUrl.isNotEmpty) {
        final uri = Uri.parse(authUrl);
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) setState(() => _message = 'Could not restart DigiLocker verification.');
    } finally {
      if (mounted) setState(() => _identityBusy = false);
    }
  }

  void _prefillFromVendor() {
    if (_prefilled) return;
    _prefilled = true;
    final vendor = ref.read(authProvider).user?.vendor;
    if (vendor == null) return;

    if (_gstinCtrl.text.isEmpty && vendor.gstNumber != null) {
      _gstinCtrl.text = vendor.gstNumber!;
    }
    if (_businessNameCtrl.text.isEmpty) {
      _businessNameCtrl.text = vendor.companyName;
    }
    if (_holderNameCtrl.text.isEmpty && vendor.accountHolderName != null) {
      _holderNameCtrl.text = vendor.accountHolderName!;
    }
    if (_ifscCtrl.text.isEmpty && vendor.ifscCode != null) {
      _ifscCtrl.text = vendor.ifscCode!;
    }

    final gstinFromStatus = _status['gstin'] as String?;
    if (gstinFromStatus != null && gstinFromStatus.isNotEmpty) {
      _gstinCtrl.text = gstinFromStatus;
    }
    final bankMasked = _status['bank_account_masked'] as String?;
    if (bankMasked != null && bankMasked.isNotEmpty && _accountCtrl.text.isEmpty) {
      _accountCtrl.text = bankMasked;
    }
  }

  Future<void> _verifyGstin() async {
    if (_gstinCtrl.text.trim().isEmpty) return;
    setState(() { _busy = true; _message = null; });
    try {
      final r = await _service.verifyGstin(
        _gstinCtrl.text.trim(),
        businessName: _businessNameCtrl.text.trim(),
      );
      setState(() => _status = Map<String, dynamic>.from(r['data'] ?? r));
      await ref.read(authProvider.notifier).refreshUser();
      if (mounted) _showSuccess('GSTIN verification submitted');
    } catch (e) {
      if (mounted) setState(() => _message = 'GSTIN verification failed. Please check and retry.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verifyBank() async {
    if (_accountCtrl.text.trim().isEmpty || _ifscCtrl.text.trim().isEmpty) return;
    if (_accountCtrl.text.trim() != _confirmCtrl.text.trim()) {
      setState(() => _message = 'Account numbers do not match.');
      return;
    }
    setState(() { _busy = true; _message = null; });
    try {
      final r = await _service.verifyBank(
        account: _accountCtrl.text.trim(),
        confirmation: _confirmCtrl.text.trim(),
        ifsc: _ifscCtrl.text.trim(),
        name: _holderNameCtrl.text.trim(),
      );
      setState(() => _status = Map<String, dynamic>.from(r['data'] ?? r));
      await ref.read(authProvider.notifier).refreshUser();
      if (mounted) _showSuccess('Bank verification submitted');
    } catch (_) {
      if (mounted) setState(() => _message = 'Bank verification failed. Please check details.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.success),
    );
  }

  String _statusLabel(String? raw) {
    if (raw == null || raw.isEmpty) return 'Not Started';
    switch (raw.toUpperCase()) {
      case 'VERIFIED': return 'Verified';
      case 'PENDING': return 'Pending';
      case 'IN_PROGRESS': return 'In Progress';
      case 'REJECTED': return 'Rejected';
      case 'REVERIFICATION_REQUIRED': return 'Reverification Required';
      case 'NOT_STARTED': return 'Not Started';
      default: return raw;
    }
  }

  Color _statusColor(String? raw) {
    switch ((raw ?? '').toUpperCase()) {
      case 'VERIFIED': return AppColors.success;
      case 'REJECTED': return AppColors.destructive;
      case 'PENDING': case 'IN_PROGRESS': return AppColors.auction;
      default: return const Color(0xFF64748B);
    }
  }

  bool _isEditable(String? fieldStatus) {
    final s = (fieldStatus ?? '').toUpperCase();
    return s.isEmpty || s == 'NOT_STARTED' || s == 'REJECTED' || s == 'REVERIFICATION_REQUIRED';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.appBg,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final overallStatus = _status['overall_kyb_status'] as String?;
    final gstinStatus = _status['gstin_status'] as String?;
    final bankStatus = _status['bank_verification_status'] as String?;
    final gstinEditable = _isEditable(gstinStatus);
    final bankEditable = _isEditable(bankStatus);

    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: Column(
        children: [
          ScreenHeader(title: 'Business Verification', onBack: () => context.pop()),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
              children: [
                if (_message != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.destructive.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: AppColors.destructive.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.destructive, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_message!, style: const TextStyle(fontSize: 12, color: AppColors.destructive, fontWeight: FontWeight.w600))),
                      ],
                    ),
                  ),

                _overallBanner(overallStatus),
                const SizedBox(height: 20),

                _sectionCard(
                  icon: Icons.receipt_long_outlined,
                  title: 'GSTIN Verification',
                  status: gstinStatus,
                  children: [
                    _field('GSTIN', _gstinCtrl, readOnly: !gstinEditable, caps: true),
                    const SizedBox(height: 12),
                    _field('Business / Legal Name', _businessNameCtrl, readOnly: !gstinEditable),
                    if (gstinEditable) ...[
                      const SizedBox(height: 16),
                      _actionButton('Verify GSTIN', _busy ? null : _verifyGstin),
                    ],
                  ],
                ),
                const SizedBox(height: 16),

                _sectionCard(
                  icon: Icons.account_balance_outlined,
                  title: 'Bank Account Verification',
                  status: bankStatus,
                  children: [
                    _field('Account Number', _accountCtrl, readOnly: !bankEditable, obscure: true),
                    const SizedBox(height: 12),
                    _field('Confirm Account Number', _confirmCtrl, readOnly: !bankEditable, obscure: true),
                    const SizedBox(height: 12),
                    _field('IFSC Code', _ifscCtrl, readOnly: !bankEditable, caps: true),
                    const SizedBox(height: 12),
                    _field('Account Holder Name', _holderNameCtrl, readOnly: !bankEditable),
                    if (bankEditable) ...[
                      const SizedBox(height: 16),
                      _actionButton('Verify Bank Account', _busy ? null : _verifyBank),
                    ],
                  ],
                ),
                const SizedBox(height: 16),

                _identityCard(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _identityCard() {
    final idStatus = (_identityStatus?['status'] as String?) ?? 'NOT_STARTED';
    final isVerified = idStatus == 'VERIFIED';
    final canRetry = idStatus == 'NOT_STARTED' || idStatus == 'CANCELLED' || idStatus == 'FAILED' || idStatus == 'EXPIRED';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppColors.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.fingerprint, size: 20, color: AppColors.navy),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Identity Verification', style: AppTextStyles.heading(size: 14, weight: FontWeight.w800)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor(idStatus).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _statusLabel(idStatus),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: _statusColor(idStatus)),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isVerified) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.verified, size: 18, color: AppColors.success),
                            const SizedBox(width: 8),
                            Text('DigiLocker Verified', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.success)),
                          ],
                        ),
                        if (_identityStatus?['identity_name'] != null) ...[
                          const SizedBox(height: 8),
                          Text('Name: ${_identityStatus!['identity_name']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                        if (_identityStatus?['aadhaar_masked'] != null) ...[
                          const SizedBox(height: 4),
                          Text('Aadhaar: ${_identityStatus!['aadhaar_masked']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'monospace')),
                        ],
                        if (_identityStatus?['verified_at'] != null) ...[
                          const SizedBox(height: 4),
                          Text('Verified: ${_identityStatus!['verified_at']}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                        ],
                      ],
                    ),
                  ),
                ] else ...[
                  if (_identityStatus?['failure_code'] != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        _failureMessage(_identityStatus!['failure_code'] as String),
                        style: const TextStyle(fontSize: 12, color: AppColors.destructive, fontWeight: FontWeight.w600),
                      ),
                    ),
                  Text(
                    'Verify your identity securely through DigiLocker. You will be redirected to the DigiLocker website to authorize verification.',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Scrapify does not collect your Aadhaar OTP or DigiLocker credentials.',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
                  if (canRetry) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: AppSpacing.buttonXl,
                      child: ElevatedButton.icon(
                        onPressed: _identityBusy
                            ? null
                            : (idStatus == 'NOT_STARTED' ? _startDigiLocker : _retryDigiLocker),
                        icon: _identityBusy
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.open_in_browser, size: 18),
                        label: Text(
                          _identityBusy
                              ? 'Connecting...'
                              : idStatus == 'NOT_STARTED'
                                  ? 'Verify with DigiLocker'
                                  : 'Try Again',
                        ),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 12),
                    Text(
                      'Verification is in progress. Complete the DigiLocker authorization in your browser, then return here.',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: AppSpacing.buttonXl,
                      child: OutlinedButton.icon(
                        onPressed: _identityBusy ? null : _loadIdentityStatus,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Refresh Status'),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _failureMessage(String code) {
    switch (code) {
      case 'DIGILOCKER_AUTH_CANCELLED':
        return 'You cancelled the DigiLocker authorization. You can try again.';
      case 'DIGILOCKER_ACCESS_DENIED':
        return 'DigiLocker access was denied. You can try again.';
      case 'DIGILOCKER_SESSION_EXPIRED':
        return 'The verification session expired. Please start again.';
      default:
        return 'Verification could not be completed. Please try again.';
    }
  }

  Widget _overallBanner(String? status) {
    final isVerified = (status ?? '').toUpperCase() == 'VERIFIED';
    final isRejected = (status ?? '').toUpperCase() == 'REJECTED';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isVerified
            ? AppColors.success.withValues(alpha: 0.08)
            : isRejected
                ? AppColors.destructive.withValues(alpha: 0.08)
                : AppColors.auction.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
        border: Border.all(
          color: isVerified
              ? AppColors.success.withValues(alpha: 0.3)
              : isRejected
                  ? AppColors.destructive.withValues(alpha: 0.3)
                  : AppColors.auction.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: (isVerified ? AppColors.success : isRejected ? AppColors.destructive : AppColors.auction).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isVerified ? Icons.verified : isRejected ? Icons.warning_amber_rounded : Icons.hourglass_top_rounded,
              color: isVerified ? AppColors.success : isRejected ? AppColors.destructive : AppColors.auction,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KYB Status',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: _statusColor(status), letterSpacing: 0.5),
                ),
                const SizedBox(height: 2),
                Text(
                  _statusLabel(status),
                  style: AppTextStyles.heading(size: 16, weight: FontWeight.w800),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _statusColor(status).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              _statusLabel(status),
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: _statusColor(status)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required String? status,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppColors.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppColors.navy),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(title, style: AppTextStyles.heading(size: 14, weight: FontWeight.w800)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor(status).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _statusLabel(status),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: _statusColor(status)),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {bool readOnly = false, bool obscure = false, bool caps = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.labelMedium),
            if (readOnly)
              const Text('LOCKED', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8))),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          readOnly: readOnly,
          obscureText: obscure,
          textCapitalization: caps ? TextCapitalization.characters : TextCapitalization.none,
          decoration: InputDecoration(
            filled: readOnly,
            fillColor: readOnly ? const Color(0xFFF1F5F9) : AppColors.white,
          ),
        ),
      ],
    );
  }

  Widget _actionButton(String label, VoidCallback? onPressed) {
    return SizedBox(
      width: double.infinity,
      height: AppSpacing.buttonXl,
      child: ElevatedButton(
        onPressed: onPressed,
        child: _busy
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(label),
      ),
    );
  }
}
