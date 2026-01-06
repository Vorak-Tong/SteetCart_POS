import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:street_cart_pos/data/local/app_database.dart';
import 'package:street_cart_pos/routing/app_router.dart';
import 'package:street_cart_pos/ui/core/theme/app_theme.dart';
import 'package:street_cart_pos/ui/core/theme/theme_mode_state.dart';
import 'package:street_cart_pos/data/repositories/menu_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize FFI for Windows/Linux
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  try {
    await AppDatabase.instance(); // optional pre‑open
  } catch (e) {
    debugPrint('Failed to initialize database: $e');
  }

  // Initialize repository data
  try {
    await MenuRepository().init();
  } catch (e) {
    debugPrint('Failed to initialize repository: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  double _deviceTextScaleFactor(double width) {
    // Scale down on smaller screens to reduce truncation, but keep a floor so
    // text doesn't become too small.
    const baseWidth = 411.0; // Pixel 2-ish baseline
    return (width / baseWidth).clamp(0.85, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: appThemeMode,
      builder: (context, themeMode, _) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Street Cart POS',
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode,
          routerConfig: appRouter,
          builder: (context, child) {
            final mediaQuery = MediaQuery.of(context);
            final systemScale = mediaQuery.textScaler.scale(1.0);
            final deviceScale = _deviceTextScaleFactor(mediaQuery.size.width);

            // Respect accessibility: only scale down when user hasn't increased
            // system text scaling.
            final effectiveScale = systemScale <= 1.0
                ? systemScale * deviceScale
                : systemScale;

            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: MediaQuery(
                data: mediaQuery.copyWith(
                  textScaler: TextScaler.linear(effectiveScale),
                ),
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
        );
      },
    );
  }
}
