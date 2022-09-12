import 'package:conopot/main_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io' show Platform;

bool canShowOpenAd = true;

class AppOpenAdManager {
  Map<String, String> APP_OPEN_UNIT_ID = {
    'android': 'ca-app-pub-1461012385298546/9733912146',
    'ios': 'ca-app-pub-1461012385298546/1304757780',
  };

  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;

  /// Maximum duration allowed between loading and showing the ad.
  final Duration maxCacheDuration = Duration(hours: 4);

  /// Keep track of load time so we don't show an expired ad.
  DateTime? _appOpenLoadTime;

  /// Load an [AppOpenAd].
  void loadAd(BuildContext context) {
    AppOpenAd.load(
      adUnitId: APP_OPEN_UNIT_ID[Platform.isIOS ? 'ios' : 'android']!,
      orientation: AppOpenAd.orientationPortrait,
      request: AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          print('$ad loaded');
          _appOpenLoadTime = DateTime.now();
          _appOpenAd = ad;

          showAdIfAvailable(context);
        },
        onAdFailedToLoad: (error) {
          print('app open ad err : ${error}');
        },
      ),
    );
  }

  void showAdIfAvailable(BuildContext context) {
    if (!canShowOpenAd) return;
    if (!isAdAvailable) {
      print('Tried to show ad before available.');
      loadAd(context);
      return;
    }
    if (_isShowingAd) {
      canShowOpenAd = false;
      print('Tried to show ad while already showing an ad.');
      return;
    }

    if (DateTime.now().subtract(maxCacheDuration).isAfter(_appOpenLoadTime!)) {
      print('Maximum cache duration exceeded. Loading another ad.');
      _appOpenAd!.dispose();
      _appOpenAd = null;
      loadAd(context);
      return;
    }
    // Set the fullScreenContentCallback and show the ad.
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        print('$ad onAdShowedFullScreenContent');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
      },
      onAdDismissedFullScreenContent: (ad) {
        print('$ad onAdDismissedFullScreenContent');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAd(context);

        /// MainScreen 전환 (replace)
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MainScreen()));
      },
    );
    canShowOpenAd = false;
    _appOpenAd!.show();
  }

  /// Whether an ad is available to be shown.
  bool get isAdAvailable {
    return _appOpenAd != null;
  }
}
