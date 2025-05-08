// lib/providers/purchase_state_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PurchaseState {
  final bool adsRemoved;
  final bool dofUnlocked;
  final int dofTrialRemaining;

  const PurchaseState({
    required this.adsRemoved,
    required this.dofUnlocked,
    required this.dofTrialRemaining,
  });

  PurchaseState copyWith({
    bool? adsRemoved,
    bool? dofUnlocked,
    int? dofTrialRemaining,
  }) {
    return PurchaseState(
      adsRemoved: adsRemoved ?? this.adsRemoved,
      dofUnlocked: dofUnlocked ?? this.dofUnlocked,
      dofTrialRemaining: dofTrialRemaining ?? this.dofTrialRemaining,
    );
  }
}

class PurchaseStateNotifier extends StateNotifier<PurchaseState> {
  PurchaseStateNotifier() : super(const PurchaseState(adsRemoved: false, dofUnlocked: false, dofTrialRemaining: 5)) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    state = PurchaseState(
      adsRemoved: prefs.getBool('adsRemoved') ?? false,
      dofUnlocked: prefs.getBool('dofUnlocked') ?? false,
      dofTrialRemaining: prefs.getInt('dofTrialRemaining') ?? 5,
    );
  }

  Future<void> unlockAds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('adsRemoved', true);
    state = state.copyWith(adsRemoved: true);
  }

  Future<void> unlockDOF() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dofUnlocked', true);
    state = state.copyWith(dofUnlocked: true);
  }

  Future<void> consumeDOFTrial() async {
    print('DOF trial remaining: ${state.dofTrialRemaining}');
    if (state.dofUnlocked || state.dofTrialRemaining <= 0) return;

    final prefs = await SharedPreferences.getInstance();
    final newCount = state.dofTrialRemaining - 1;
    await prefs.setInt('dofTrialRemaining', newCount);
    state = state.copyWith(dofTrialRemaining: newCount);
  }

  //! SOLO PARA PRUEBAS. Restaura las compras
  Future<void> resetPurchases() async {
    final prefs = await SharedPreferences.getInstance();
    //await prefs.setBool('adsRemoved', true);
    await prefs.remove('adsRemoved');
    await prefs.remove('dofUnlocked');
    await prefs.setInt('dofTrialRemaining', 5);
    state = const PurchaseState(adsRemoved: false, dofUnlocked: false, dofTrialRemaining: 5);
  }
}

final purchaseStateProvider = StateNotifierProvider<PurchaseStateNotifier, PurchaseState>(
  (ref) => PurchaseStateNotifier(),
);