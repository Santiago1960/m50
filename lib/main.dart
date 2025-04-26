import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:m50/config/theme_data.dart';
import 'package:m50/presentation/ads/ad_manager.dart';

import 'config/router.dart';// 👈 importa tu tema cupertino

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  MobileAds.instance.initialize();
  AdManager.loadInterstitial();

  WidgetsBinding.instance.deferFirstFrame();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MainApp());

  Future.delayed(const Duration(milliseconds: 500), () {
    WidgetsBinding.instance.allowFirstFrame();
  });
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'M50',
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