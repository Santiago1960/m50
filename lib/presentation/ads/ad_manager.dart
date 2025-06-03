import 'package:flutter/material.dart';  
import 'dart:io' show Platform;
import 'package:google_mobile_ads/google_mobile_ads.dart';

//const _androidInterstitialTestId  = 'ca-app-pub-3940256099942544/1033173712'; // SOLO PARA PRUEBAS
const _androidInterstitialTestId  = 'ca-app-pub-3102508405391403/7620793503'; // PARA PRODUCCION
const _iosInterstitialTestId      = 'ca-app-pub-3940256099942544/4411468910'; // SOLO PARA PRUEBAS

class AdManager {
  static InterstitialAd? _interstitialAd;

  static void loadInterstitial() {
    final adUnitId = Platform.isAndroid
      ? _androidInterstitialTestId
      : _iosInterstitialTestId;

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (_) => _interstitialAd = null,
      ),
    );
  }

  static void showInterstitial({required VoidCallback onFinish}) {
    if (_interstitialAd == null) return onFinish();

    _interstitialAd!
      ..fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitialAd = null;
          loadInterstitial();
          onFinish();
        },
        onAdFailedToShowFullScreenContent: (ad, _) {
          ad.dispose();
          _interstitialAd = null;
          loadInterstitial();
          onFinish();
        },
      )
      ..show();
  }
}