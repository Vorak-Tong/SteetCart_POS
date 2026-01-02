import 'package:flutter/material.dart';
import 'package:street_cart_pos/data/local/app_database.dart';
import 'package:street_cart_pos/routing/app_router.dart';
import 'package:street_cart_pos/ui/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await AppDatabase.instance(); // optional pre‑open
  } catch (e) {
    debugPrint('Failed to initialize database: $e');
  }
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Street Cart POS',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: appRouter,
    );
  }
}
