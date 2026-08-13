import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';

class CountdownTimer extends StatefulWidget {
  final int initialSeconds;
  final TextStyle? style;
  final ValueChanged<int>? onTick;
  final VoidCallback? onComplete;
  final bool showIcon;

  const CountdownTimer({
    super.key,
    required this.initialSeconds,
    this.style,
    this.onTick,
    this.onComplete,
    this.showIcon = true,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late int _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.initialSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining > 0) {
        setState(() => _remaining--);
        widget.onTick?.call(_remaining);
      } else {
        _timer?.cancel();
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUrgent = _remaining < 300;
    final color = isUrgent ? AppColors.destructive : AppColors.auction;
    final style = widget.style ??
        TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: color,
        );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showIcon) ...[
          Icon(Icons.access_time, size: 14, color: color),
          const SizedBox(width: 4),
        ],
        Text(Formatters.formatCountdown(_remaining), style: style),
      ],
    );
  }
}
