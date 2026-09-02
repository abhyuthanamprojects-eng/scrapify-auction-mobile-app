import 'package:flutter/material.dart';
import '../core/network/api_exception.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';

class ErrorDisplay extends StatelessWidget {
  final ApiException error;
  final VoidCallback? onRetry;
  final EdgeInsets padding;
  final bool showRetryButton;

  const ErrorDisplay({
    Key? key,
    required this.error,
    this.onRetry,
    this.padding = const EdgeInsets.all(AppSpacing.screenPaddingH),
    this.showRetryButton = true,
  }) : super(key: key);

  IconData _getIconForError() {
    if (error.isNetwork) return Icons.wifi_off_rounded;
    if (error.isTimeout) return Icons.schedule_rounded;
    if (error.isUnauthorized) return Icons.lock_outline_rounded;
    if (error.isForbidden) return Icons.block_rounded;
    if (error.isNotFound) return Icons.search_off_rounded;
    if (error.isServer) return Icons.error_outline_rounded;
    if (error.isRateLimited) return Icons.speed_rounded;
    return Icons.warning_rounded;
  }

  Color _getColorForError() {
    if (error.isServer) return AppColors.destructive;
    if (error.isUnauthorized || error.isForbidden) return AppColors.destructive;
    return AppColors.warning;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorForError();
    final icon = _getIconForError();

    return SingleChildScrollView(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.1),
              ),
              child: Icon(
                icon,
                size: 40,
                color: color,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              error.isValidation ? 'Validation Error' : 'Error',
              style: AppTextStyles.heading(size: 18, weight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              error.userMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (error.hasFieldErrors) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.05),
                  border: Border.all(color: color.withValues(alpha: 0.2)),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Validation Errors:',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...error.fieldErrors.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text('• ', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                            ),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${entry.key}: ',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: color,
                                      ),
                                    ),
                                    TextSpan(
                                      text: entry.value.join(', '),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
            if (showRetryButton && onRetry != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Inline error widget for forms (shows error below a field)
class FieldError extends StatelessWidget {
  final String? error;
  final EdgeInsets padding;

  const FieldError({
    Key? key,
    this.error,
    this.padding = const EdgeInsets.only(top: 6),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (error == null || error!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: padding,
      child: Text(
        error!,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.destructive,
          height: 1.3,
        ),
      ),
    );
  }
}

/// Snackbar error display
void showErrorSnackBar(
  BuildContext context, {
  required ApiException error,
  VoidCallback? onRetry,
}) {
  final color = error.isServer ? AppColors.destructive : AppColors.warning;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(_getIconForError(error), color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error.userMessage,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
      backgroundColor: color,
      duration: Duration(seconds: error.isTimeout ? 5 : 3),
      action: onRetry != null
          ? SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: onRetry,
            )
          : null,
    ),
  );
}

IconData _getIconForError(ApiException error) {
  if (error.isNetwork) return Icons.wifi_off_rounded;
  if (error.isTimeout) return Icons.schedule_rounded;
  if (error.isUnauthorized) return Icons.lock_outline_rounded;
  if (error.isForbidden) return Icons.block_rounded;
  if (error.isNotFound) return Icons.search_off_rounded;
  if (error.isServer) return Icons.error_outline_rounded;
  return Icons.warning_rounded;
}
