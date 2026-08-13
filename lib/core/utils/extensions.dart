import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  MediaQueryData get mq => MediaQuery.of(this);
  double get screenWidth => mq.size.width;
  double get screenHeight => mq.size.height;
  EdgeInsets get padding => mq.padding;
}

extension WidgetExtensions on Widget {
  Widget padAll(double value) => Padding(
        padding: EdgeInsets.all(value),
        child: this,
      );

  Widget padH(double value) => Padding(
        padding: EdgeInsets.symmetric(horizontal: value),
        child: this,
      );

  Widget padV(double value) => Padding(
        padding: EdgeInsets.symmetric(vertical: value),
        child: this,
      );
}

extension ColorExtensions on Color {
  Color get o10 => withValues(alpha: 0.1);
  Color get o20 => withValues(alpha: 0.2);
  Color get o50 => withValues(alpha: 0.5);
  Color get o70 => withValues(alpha: 0.7);
}

extension StatusColor on String {
  Color get statusColor {
    switch (toLowerCase()) {
      case 'live':
      case 'active':
      case 'approved':
      case 'success':
        return AppColors.success;
      case 'pending':
      case 'upcoming':
      case 'scheduled':
        return AppColors.auction;
      case 'ended':
      case 'closed':
      case 'lost':
        return AppColors.navyWithOpacity(0.5);
      case 'rejected':
      case 'sent_back':
      case 'suspended':
      case 'failed':
        return AppColors.destructive;
      case 'won':
        return AppColors.accentBlue;
      default:
        return AppColors.navy;
    }
  }
}
