import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'config/router.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized();

  // Pausar el primer frame hasta que estemos listos
  WidgetsBinding.instance.deferFirstFrame();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MainApp());

  // Permitir que Flutter dibuje después de 2 segundos (o cuando tú digas)
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
    );
  }
}
