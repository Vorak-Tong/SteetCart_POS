import 'package:flutter/material.dart';
import 'package:street_cart_pos/data/local/app_database.dart';
import 'package:street_cart_pos/routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase.instance(); // optional pre‑open
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Street Cart POS',
      routerConfig: appRouter,
    );
  }
}
