import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'package:m50/config/theme_data.dart';
import 'package:m50/presentation/ads/ad_manager.dart';
import 'package:m50/providers/purchase_controller_provider.dart';

import 'config/router.dart';// 👈 importa tu tema cupertino

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final bool billingAvailable = await InAppPurchase.instance.isAvailable();
  print('Billing disponible: $billingAvailable');

  MobileAds.instance.initialize();
  AdManager.loadInterstitial();

  WidgetsBinding.instance.deferFirstFrame();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    const ProviderScope(child: MainApp()),
  );

  Future.delayed(const Duration(milliseconds: 500), () {
    WidgetsBinding.instance.allowFirstFrame();
  });
}

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {

  @override
  void initState() {
    super.initState();

    // Restaurar compras al iniciar la app
    Future.microtask(() {
      ref.read(purchaseControllerProvider).verifyPastPurchases();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'M50',
      theme: ThemeData(
        useMaterial3: false, // Para evitar que Material 3 cambie los colores automáticamente
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      routerConfig: router,
      builder: (context, child) {
        // 👇 Aplicamos el CupertinoTheme a toda la app
        return CupertinoTheme(
          data: cupertinoAppTheme,
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}