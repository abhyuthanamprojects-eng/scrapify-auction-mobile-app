import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class StatusChip extends StatelessWidget {
  final String label;
  final Color? color;
  final bool showDot;
  final bool animate;

  const StatusChip({
    super.key,
    required this.label,
    this.color,
    this.showDot = false,
    this.animate = false,
  });

  factory StatusChip.live() => const StatusChip(
        label: 'LIVE',
        color: AppColors.success,
        showDot: true,
        animate: true,
      );

  factory StatusChip.fromStatus(String status) {
    final map = {
      'pending': (label: 'Pending', color: AppColors.auction),
      'sent_back': (label: 'Sent Back', color: AppColors.destructive),
      'scheduled': (label: 'Scheduled', color: AppColors.accentBlue),
      'live': (label: 'Live', color: AppColors.success),
      'closed': (label: 'Closed', color: AppColors.navy),
      'won': (label: 'Won', color: AppColors.accentBlue),
      'lost': (label: 'Lost', color: AppColors.navy),
      'active': (label: 'Active', color: AppColors.success),
      'upcoming': (label: 'Upcoming', color: AppColors.auction),
      'ended': (label: 'Ended', color: AppColors.navy),
    };
    final entry = map[status.toLowerCase()];
    return StatusChip(
      label: entry?.label ?? status,
      color: entry?.color ?? AppColors.navy,
      showDot: status.toLowerCase() == 'live',
      animate: status.toLowerCase() == 'live',
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.navy;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            _LiveDot(color: c, animate: animate),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: c,
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveDot extends StatefulWidget {
  final Color color;
  final bool animate;
  const _LiveDot({required this.color, required this.animate});

  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    if (widget.animate) _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 8,
      height: 8,
      child: Stack(
        children: [
          if (widget.animate)
            AnimatedBuilder(
              animation: _controller,
              builder: (_, __) => Opacity(
                opacity: 1 - _controller.value,
                child: Transform.scale(
                  scale: 1 + _controller.value,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.color,
                    ),
                  ),
                ),
              ),
            ),
          Center(
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
