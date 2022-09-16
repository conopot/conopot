import 'dart:async';
import 'package:conopot/config/analytics_config.dart';
import 'package:conopot/config/constants.dart';
import 'package:conopot/config/firebase_remote_config.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:conopot/splash/splash_screen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  await Analytics_config().init();
  MobileAds.instance.initialize();
  // 세로 화면 고정
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  /// firebase crashlytics init
  runZonedGuarded<Future<void>>(
    () async {
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
      runApp(const MyApp());
    },
    (error, stack) =>
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MusicSearchItemLists()),
        ChangeNotifierProvider<NoteData>(create: (context) => NoteData()),
      ],
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus(); // 키보드 닫기
        },
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaleFactor: 1.0,
            ),
            child: child!,
          ),
          themeMode: ThemeMode.light,
          debugShowCheckedModeBanner: false,
          title: 'conopot',
          theme: ThemeData(
              fontFamily: 'pretendard',
              scaffoldBackgroundColor: kBackgroundColor,
              appBarTheme: const AppBarTheme(
                centerTitle: false,
                backgroundColor: kBackgroundColor,
                foregroundColor: kPrimaryWhiteColor,
                elevation: 0,
              ),
              visualDensity: VisualDensity.adaptivePlatformDensity,
              cupertinoOverrideTheme: CupertinoThemeData(
                  textTheme: CupertinoTextThemeData(
                pickerTextStyle: TextStyle(
                    color: kPrimaryWhiteColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w500),
              ))),
          home: const SplashScreen(),
          navigatorObservers: [
            FirebaseAnalyticsObserver(
                analytics: Analytics_config.firebaseAnalytics),
          ],
        ),
      ),
    );
  }
}
