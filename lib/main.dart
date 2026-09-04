import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/app_env.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';

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
        if (!AppEnv.isProd) {
          return Banner(
            location: BannerLocation.topStart,
            message: AppEnv.isDev ? 'DEV' : 'STG',
            color: AppEnv.isDev ? Colors.green : Colors.orange,
            child: child ?? const SizedBox.shrink(),
          );
        }
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
