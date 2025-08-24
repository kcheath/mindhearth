import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/app/themes/app_theme.dart';
import 'package:mindhearth/app/router/app_router.dart';
import 'package:mindhearth/core/config/debug_config.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MindhearthApp(),
    ),
  );
}

class MindhearthApp extends ConsumerWidget {
  const MindhearthApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'Mindhearth',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: DebugConfig.showDebugBanner,
      showPerformanceOverlay: DebugConfig.enablePerformanceOverlay,
    );
  }
}
