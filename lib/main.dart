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
      builder: (context, child) {
        // Add debug banner overlay
        if (DebugConfig.isDebugMode) {
          return Stack(
            children: [
              child!,
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.orange.withOpacity(0.9),
                  child: Row(
                    children: [
                      const Icon(Icons.bug_report, color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Environment: Debug | Backend: ${DebugConfig.apiUrl}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
        return child!;
      },
    );
  }
}
