import 'package:conopot/app_open_ad_manager.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AppLifecycleReactor extends WidgetsBindingObserver {
  final AppOpenAdManager appOpenAdManager;
  final BuildContext context;

  AppLifecycleReactor({required this.appOpenAdManager, required this.context});

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    // Try to show an app open ad if the app is being resumed and
    // we're not already showing an app open ad.
    if (state == AppLifecycleState.resumed) {
      appOpenAdManager.showAdIfAvailable(context);
    }
  }

  void listenToAppStateChanges() {
    AppStateEventNotifier.startListening();
    AppStateEventNotifier.appStateStream
        .forEach((state) => _onAppStateChanged(state));
  }

  void _onAppStateChanged(AppState appState) {
    // Try to show an app open ad if the app is being resumed and
    // we're not already showing an app open ad.
    if (appState == AppState.foreground) {
      appOpenAdManager.showAdIfAvailable(context);
      canShowOpenAd = false;
    } else {
      canShowOpenAd = true;
    }
  }
}
