import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../models/notification_item.dart';
import '../../providers/notification_provider.dart';
import '../../services/notification_service.dart';
import '../../widgets/shared/screen_header.dart';
import '../../widgets/shared/loading_skeleton.dart';
import '../../widgets/shared/empty_state.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: Column(
        children: [
          ScreenHeader(
            title: 'Notifications',
            onBack: () => context.pop(),
            trailing: TextButton(
              onPressed: () async {
                await NotificationService().markAllRead();
                ref.invalidate(notificationsProvider);
                ref.invalidate(unreadCountProvider);
              },
              child: Text('Mark all read', style: AppTextStyles.labelSmall.copyWith(color: AppColors.auction)),
            ),
          ),
          Expanded(
            child: notifsAsync.when(
              data: (notifs) {
                if (notifs.isEmpty) {
                  return const EmptyState(
                    icon: Icons.notifications_none,
                    title: 'No notifications',
                    subtitle: 'You\'re all caught up',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPaddingH, 0, AppSpacing.screenPaddingH, 24,
                  ),
                  itemCount: notifs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (_, i) => _notifCard(notifs[i], ref),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(AppSpacing.screenPaddingH),
                child: ListSkeleton(),
              ),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Failed to load', style: AppTextStyles.caption),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => ref.invalidate(notificationsProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _notifCard(NotificationItem notif, WidgetRef ref) {
    final cat = notif.category;
    final iconMap = {
      'bid': (Icons.gavel, AppColors.auction),
      'auction': (Icons.event, AppColors.accentBlue),
      'wallet': (Icons.account_balance_wallet, AppColors.success),
      'order': (Icons.local_shipping, AppColors.accentBlue),
      'system': (Icons.info_outline, AppColors.navy),
    };
    final (icon, color) = iconMap[cat] ?? (Icons.info, AppColors.navy);

    return GestureDetector(
      onTap: () async {
        if (!notif.read) {
          await NotificationService().markRead(notif.id);
          ref.invalidate(notificationsProvider);
          ref.invalidate(unreadCountProvider);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: notif.read ? AppColors.white : AppColors.auction.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.blackWithOpacity(notif.read ? 0.05 : 0.08)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notif.title, style: AppTextStyles.labelMedium),
                  const SizedBox(height: 2),
                  Text(notif.body, style: AppTextStyles.caption, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(Formatters.timeAgo(notif.at), style: AppTextStyles.captionMuted),
                ],
              ),
            ),
            if (!notif.read)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(
                  color: AppColors.auction,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
