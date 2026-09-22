import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/app_env.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'widgets/web_security_gate.dart';

/// Default Android Studio entrypoint. Use the flavor-specific entrypoints for
/// Dev, Staging, and Production configurations.
void main() {
  AppEnv.dev();
  bootstrap();
}

void bootstrap() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const ProviderScope(child: ScrapifyApp()));
}

class ScrapifyApp extends StatelessWidget {
  const ScrapifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppEnv.instance.appTitle,
      debugShowCheckedModeBanner: AppEnv.isDev || AppEnv.isStaging,
      theme: AppTheme.light,
      routerConfig: AppRouter.router,
      builder: (context, child) {
        final gatedChild = WebSecurityGate(
          child: child ?? const SizedBox.shrink(),
        );
        final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
        final content = Stack(
          children: [
            gatedChild,
            if (defaultTargetPlatform == TargetPlatform.iOS &&
                keyboardInset > 0)
              Positioned(
                right: 12,
                bottom: keyboardInset + 8,
                child: Material(
                  color: Colors.transparent,
                  child: ElevatedButton(
                    onPressed: () =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(72, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      backgroundColor: const Color(0xFF0B1F3A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
          ],
        );
        if (!AppEnv.isProd) {
          return Banner(
            location: BannerLocation.topStart,
            message: AppEnv.isDev ? 'DEV' : 'STG',
            color: AppEnv.isDev ? Colors.green : Colors.orange,
            child: content,
          );
        }
        return content;
      },
    );
  }
}
