import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/shared/screen_header.dart';

class NotifSettingsScreen extends StatefulWidget {
  const NotifSettingsScreen({super.key});

  @override
  State<NotifSettingsScreen> createState() => _NotifSettingsScreenState();
}

class _NotifSettingsScreenState extends State<NotifSettingsScreen> {
  final _prefs = {
    'Bid updates': true,
    'Auction alerts': true,
    'Wallet transactions': true,
    'Order updates': true,
    'Promotions': false,
    'Newsletter': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: Column(
        children: [
          ScreenHeader(title: 'Notification Settings', onBack: () => context.pop()),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH),
              children: [
                _group('Auction & Bidding', ['Bid updates', 'Auction alerts']),
                _group('Transactions', ['Wallet transactions', 'Order updates']),
                _group('Marketing', ['Promotions', 'Newsletter']),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity, height: AppSpacing.buttonLg,
                  child: ElevatedButton(onPressed: () => context.pop(), child: const Text('Save Preferences')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _group(String title, List<String> keys) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 4),
          child: Text(title, style: AppTextStyles.labelSmall.copyWith(color: AppColors.navyWithOpacity(0.5))),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            border: Border.all(color: AppColors.blackWithOpacity(0.05)),
          ),
          child: Column(
            children: keys.map((k) => SwitchListTile(
              title: Text(k, style: AppTextStyles.bodyMedium),
              value: _prefs[k] ?? false,
              onChanged: (v) => setState(() => _prefs[k] = v),
              activeColor: AppColors.auction,
            )).toList(),
          ),
        ),
      ],
    );
  }
}
