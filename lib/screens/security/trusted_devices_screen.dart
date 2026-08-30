import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';

class TrustedDevicesScreen extends StatefulWidget {
  const TrustedDevicesScreen({super.key});

  @override
  State<TrustedDevicesScreen> createState() => _TrustedDevicesScreenState();
}

class _TrustedDevicesScreenState extends State<TrustedDevicesScreen> {
  bool _biometrics = true;
  bool _mfaOnHighBids = true;
  bool _stepUpBankChanges = true;
  bool _screenshotProtection = true;

  List<Map<String, dynamic>> _devices = [
    {
      'id': 'DEV-01',
      'name': 'Apple iPhone 15 Pro',
      'os': 'iOS 18.2',
      'location': 'Mumbai, India',
      'lastActive': 'Active Now',
      'isCurrent': true,
      'icon': Icons.phone_iphone,
    },
    {
      'id': 'DEV-02',
      'name': 'MacBook Pro 16" (Corporate)',
      'os': 'macOS Sequoia 15.1 • Chrome',
      'location': 'Mumbai, India',
      'lastActive': '2 hours ago',
      'isCurrent': false,
      'icon': Icons.laptop_mac,
    },
    {
      'id': 'DEV-03',
      'name': 'Samsung Galaxy Tab S9',
      'os': 'Android 14 • Scrapify App',
      'location': 'New Delhi, India',
      'lastActive': 'Yesterday, 04:30 PM',
      'isCurrent': false,
      'icon': Icons.tablet_android,
    },
  ];

  void _terminateDevice(String id) {
    setState(() {
      _devices.removeWhere((d) => d['id'] == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✓ Device session terminated successfully')),
    );
  }

  void _terminateAllOthers() {
    setState(() {
      _devices = _devices.where((d) => d['isCurrent'] == true).toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✓ All other active corporate sessions have been signed out')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: AppBar(
        title: const Text('Security & Trusted Devices'),
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Security Settings Card
          _sectionHeader('AUTHENTICATION & STEP-UP SECURITY'),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
              border: Border.all(color: AppColors.cardBorder),
              boxShadow: AppColors.shadowSm,
            ),
            child: Column(
              children: [
                _switchTile(
                  'Biometric Authentication',
                  'Enable Face ID / Fingerprint for fast login & session unlock',
                  _biometrics,
                  (v) => setState(() => _biometrics = v),
                ),
                const Divider(height: 1),
                _switchTile(
                  'MFA for High-Value Bids (> ₹10 Lakhs)',
                  'Prompt 6-digit TOTP code before submitting bids exceeding ₹10L',
                  _mfaOnHighBids,
                  (v) => setState(() => _mfaOnHighBids = v),
                ),
                const Divider(height: 1),
                _switchTile(
                  'Step-Up Verification for Bank Changes',
                  'Mandatory SMS OTP and Admin clearance for changing settlement bank accounts',
                  _stepUpBankChanges,
                  (v) => setState(() => _stepUpBankChanges = v),
                ),
                const Divider(height: 1),
                _switchTile(
                  'Confidential Screenshot Warning',
                  'Alert when capturing screenshots of commercial tender pricing and addenda',
                  _screenshotProtection,
                  (v) => setState(() => _screenshotProtection = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Active Trusted Devices
          _sectionHeader('ACTIVE TRUSTED SESSIONS (${_devices.length})'),
          ..._devices.map((dev) => _deviceCard(dev)),

          const SizedBox(height: 12),
          if (_devices.length > 1)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _terminateAllOthers,
                icon: const Icon(Icons.phonelink_erase, color: AppColors.destructive, size: 20),
                label: const Text('Sign Out All Other Devices', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.destructive)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.destructive.withValues(alpha: 0.3)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusXl)),
                ),
              ),
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(fontFamily: 'monospace', fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 0.5),
      ),
    );
  }

  Widget _switchTile(String title, String subtitle, bool val, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.navy)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
              ],
            ),
          ),
          Switch.adaptive(
            value: val,
            activeColor: AppColors.success,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _deviceCard(Map<String, dynamic> dev) {
    final isCurrent = dev['isCurrent'] == true;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
        border: Border.all(color: isCurrent ? AppColors.navy.withValues(alpha: 0.3) : AppColors.cardBorder),
        boxShadow: AppColors.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isCurrent ? AppColors.navy.withValues(alpha: 0.08) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: Icon(dev['icon'] as IconData, color: isCurrent ? AppColors.navy : const Color(0xFF64748B), size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(dev['name'] as String, style: AppTextStyles.labelLarge),
                    if (isCurrent) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('THIS DEVICE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.success)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text('${dev['os']} • ${dev['location']}', style: AppTextStyles.captionMuted),
                const SizedBox(height: 2),
                Text('Last active: ${dev['lastActive']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
              ],
            ),
          ),
          if (!isCurrent)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.destructive),
              tooltip: 'Terminate Session',
              onPressed: () => _terminateDevice(dev['id'] as String),
            ),
        ],
      ),
    );
  }
}
