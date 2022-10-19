import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:conopot/app_open_ad_manager.dart';
import 'package:conopot/applifecycle_reactor.dart';
import 'package:conopot/config/analytics_config.dart';
import 'package:conopot/config/constants.dart';
import 'package:conopot/config/firebase_remote_config.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:conopot/main_screen.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/models/recommendation_item_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  checkConnection() async {
    //버전이 존재하는지 체크한다.
    final storage = new FlutterSecureStorage();
    String? userVersionStr = await storage.read(key: 'userVersion');
    //print(userVersionStr);

    //인터넷 연결 확인
    try {
      final result = await InternetAddress.lookup('example.com');
      //("인터넷 연결 성공");

      int sessionCnt = Provider.of<MusicSearchItemLists>(context, listen: false)
          .sessionCount;

      if (sessionCnt == 0) {
        Analytics_config().firstSessionEvent();
      }

      //firebase remote config 초기화
      await Firebase_Remote_Config().init(sessionCnt);
      //이때 remote config - musicUpdateSetting 이 false 라면, 하지 않기
      bool musicUpdateSetting = false;
      musicUpdateSetting =
          Firebase_Remote_Config().remoteConfig.getBool('musicUpdateSetting');
      //만약 버전이 없다면, remote config 상관없이 뭐라도 받아오는 것이 낫다.
      if (userVersionStr == null) {
        musicUpdateSetting = true;
      }

      /// 노래방 곡 관련 초기화
      await Provider.of<MusicSearchItemLists>(context, listen: false)
          .initVersion(musicUpdateSetting, false);

      /// 사용자 노트 초기화 (local storage)
      await Provider.of<NoteData>(context, listen: false).initNotes();
      await SizeConfig().init(context);
      await RecommendationItemList().initRecommendationList();
      await appOpenAds(context);
    }
    //인터넷 연결이 안 되어있다면
    on SocketException {
      print("인터넷 연결 실패");
      //버전이 없다면 (첫 설치 이용자라면) -> 인터넷 연결 알림 문구 띄우기
      if (userVersionStr == null) {
        //기존에 있는 txt 파일 사용
        //버전이 존재한다면 -> 버전 체크 없이 초기화 진행
        await Provider.of<MusicSearchItemLists>(context, listen: false)
            .initVersion(false, true);
      } else {
        //버전이 존재한다면 -> 버전 체크 없이 초기화 진행
        await Provider.of<MusicSearchItemLists>(context, listen: false)
            .initVersion(false, false);
      }

      /// 사용자 노트 초기화 (local storage)
      await Provider.of<NoteData>(context, listen: false).initNotes();

      await SizeConfig().init(context);

      await RecommendationItemList().initRecommendationList();

      /// MainScreen 전환 (replace)
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => MainScreen()));
    }
  }

  /// 앱 실행 시 얻어야 하는 정보들 수집
  void init() async {
    if (Platform.isIOS)
      final status =
          await AppTrackingTransparency.requestTrackingAuthorization();
    await Analytics_config().init();
    // 유저 세션 체크
    await Provider.of<MusicSearchItemLists>(context, listen: false)
        .checkSessionCount();
    //Admob 전면광고 캐싱
    await Provider.of<NoteData>(context, listen: false)
        .createInterstitialAd("noteAdd");

    // 첫 설치 사용자라면, 로컬 스토리지를 비운다.
    final prefs = await SharedPreferences.getInstance();

    if (prefs.getBool('first_run') ?? true) {
      FlutterSecureStorage storage = FlutterSecureStorage();
      await storage.delete(key: 'userVersion');
      prefs.setBool('first_run', false);
    }

    checkConnection();
  }

  static final String oneSignalAppId = "3dd8ef2b-8d2b-4e05-9499-479c974fed91";
  // onesignal 설정
  Future<void> initOneSignal() async {
    OneSignal.shared.setAppId(oneSignalAppId);
    // 권한 허가
    OneSignal.shared
        .promptUserForPushNotificationPermission()
        .then((accepted) {});

    OneSignal.shared.setNotificationWillShowInForegroundHandler(
        (OSNotificationReceivedEvent event) {
      event.complete(event.notification);
    });
  }

  appOpenAds(BuildContext context) async {
    AppOpenAdManager appOpenAdManager = AppOpenAdManager()..loadAd(context);
    WidgetsBinding.instance.addObserver(AppLifecycleReactor(
        appOpenAdManager: appOpenAdManager, context: context));
  }

  @override
  void initState() {
    super.initState();
    init();
    initOneSignal();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image(
                image: const AssetImage('assets/images/splash.png'),
                height: SizeConfig.screenWidth * 0.3,
              ),
            ),
            SizedBox(
              height: SizeConfig.defaultSize * 5,
            ),
            const CircularProgressIndicator(
              color: kMainColor,
              backgroundColor: Color(0x4DFF9A62),
            )
          ],
        ),
      ),
    );
  }
}
