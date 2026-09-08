import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../core/theme/app_colors.dart';

/// Route-level role enforcement for deep links. Backend authorization remains
/// authoritative; this prevents an already-authenticated user from seeing a
/// workspace that cannot be used by their role.
class RoleGuard extends ConsumerStatefulWidget {
  final Set<String> allowedRoles;
  final Widget child;

  const RoleGuard({super.key, required this.allowedRoles, required this.child});

  @override
  ConsumerState<RoleGuard> createState() => _RoleGuardState();
}

class _RoleGuardState extends ConsumerState<RoleGuard> {
  bool _redirectScheduled = false;

  @override
  void initState() {
    super.initState();
    if (ref.read(authProvider).authState == AuthState.initial) {
      Future<void>(() => ref.read(authProvider.notifier).checkSession());
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    if (auth.authState == AuthState.initial ||
        auth.authState == AuthState.loading) {
      return const _GuardLoading();
    }
    if (!auth.isAuthenticated) {
      _redirect('/login');
      return const _GuardLoading();
    }
    if (auth.isAdmin ||
        !widget.allowedRoles.contains(auth.user?.role.toLowerCase())) {
      return _AccessDenied(onHome: () => context.go('/home'));
    }
    return widget.child;
  }

  void _redirect(String location) {
    if (_redirectScheduled) return;
    _redirectScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.go(location);
    });
  }
}

class _GuardLoading extends StatelessWidget {
  const _GuardLoading();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

class _AccessDenied extends StatelessWidget {
  final VoidCallback onHome;

  const _AccessDenied({required this.onHome});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.block_rounded,
              size: 48,
              color: AppColors.destructive,
            ),
            const SizedBox(height: 12),
            const Text(
              'Access denied',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'This screen is not available for your account role.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onHome,
              child: const Text('Go to my workspace'),
            ),
          ],
        ),
      ),
    ),
  );
}
