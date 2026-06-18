import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    runApp(_ErrorApp(message: 'Failed to initialize: $e'));
    return;
  }
  runApp(const ProviderScope(child: PCBApp()));
}

class PCBApp extends ConsumerWidget {
  const PCBApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'PCB Operations',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          themeMode: ThemeMode.light,
          routerConfig: router,
        );
      },
    );
  }
}

class _ErrorApp extends StatelessWidget {
  final String message;
  const _ErrorApp({required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('App Initialization Failed',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey)),
            ]),
          ),
        ),
      ),
    );
  }
}
