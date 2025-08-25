import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/app/themes/app_theme.dart';
import 'package:mindhearth/app/router/app_router.dart';
import 'package:mindhearth/core/config/debug_config.dart';
import 'package:mindhearth/core/providers/app_state_provider.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MindhearthApp(),
    ),
  );
}

class MindhearthApp extends ConsumerStatefulWidget {
  const MindhearthApp({super.key});

  @override
  ConsumerState<MindhearthApp> createState() => _MindhearthAppState();
}

class _MindhearthAppState extends ConsumerState<MindhearthApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Reset safety code verification when app is paused or terminated
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      final appStateNotifier = ref.read(appStateNotifierProvider.notifier);
      appStateNotifier.resetSafetyCodeVerification();
      print('🐛 Safety code verification reset due to app lifecycle change: $state');
    }
  }

  @override
  Widget build(BuildContext context) {
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
        // Add debug banner overlay (configurable via DebugConfig.showDebugBanner)
        if (DebugConfig.isDebugMode && DebugConfig.showDebugBanner) {
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
