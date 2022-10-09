import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/services.dart';

class Firebase_Remote_Config {
  final remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> init() async {
    final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(minutes: 1),
    ));
    await remoteConfig.setDefaults(<String, dynamic>{
      'musicUpdateSetting': false,
      'noteAddInterstitialSetting': false,
      'quitBannerSetting': false,
      'appopenadSetting': false,
      'pitchMeasureInterstitialSetting': false,
      'aaTest': 'A',
    });
    RemoteConfigValue(null, ValueSource.valueStatic);
    await remoteConfig.fetchAndActivate();
  }
}
