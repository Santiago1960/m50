// lib/providers/purchase_state_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PurchaseState {
  final bool adsRemoved;
  final bool dofUnlocked;

  const PurchaseState({
    required this.adsRemoved,
    required this.dofUnlocked,
  });

  PurchaseState copyWith({
    bool? adsRemoved,
    bool? dofUnlocked,
  }) {
    return PurchaseState(
      adsRemoved: adsRemoved ?? this.adsRemoved,
      dofUnlocked: dofUnlocked ?? this.dofUnlocked,
    );
  }
}

class PurchaseStateNotifier extends StateNotifier<PurchaseState> {
  PurchaseStateNotifier() : super(const PurchaseState(adsRemoved: false, dofUnlocked: false)) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    state = PurchaseState(
      adsRemoved: prefs.getBool('adsRemoved') ?? false,
      dofUnlocked: prefs.getBool('dofUnlocked') ?? false,
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
}

final purchaseStateProvider = StateNotifierProvider<PurchaseStateNotifier, PurchaseState>(
  (ref) => PurchaseStateNotifier(),
);