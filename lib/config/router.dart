import 'package:go_router/go_router.dart';

import '../presentation/screens/screens.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),

    GoRoute(
      path: '/hyperfocal',
      builder: (context, state) => const HyperfocalScreen(),
    ),

    GoRoute(
      path: '/compensation',
      builder: (context, state) => const CompensationScreen(),
    ),

    GoRoute(
      path: '/whitebalance',
      builder: (context, state) => const WhiteBalanceScreen(),
    ),

    GoRoute(
      path: '/dof',
      builder: (context, state) => const DepthOfFieldScreen(),
    ),
  ],
);