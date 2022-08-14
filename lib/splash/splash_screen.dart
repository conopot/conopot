import 'dart:async';
import 'package:conopot/config/constants.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:conopot/main_screen.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/models/recommendation_item_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  /// 앱 실행 시 얻어야 하는 정보들 수집
  void init() async {
    //print(DateTime.now().millisecondsSinceEpoch);
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('first_run') ?? true) {
      FlutterSecureStorage storage = FlutterSecureStorage();
      await storage.deleteAll();
      prefs.setBool('first_run', false);
    }

    /// 노래방 곡 관련 초기화
    await Provider.of<MusicSearchItemLists>(context, listen: false)
        .initVersion();

    //print(DateTime.now().millisecondsSinceEpoch);

    /// 사용자 노트 초기화 (local storage)
    await Provider.of<NoteData>(context, listen: false).initNotes();
    await SizeConfig().init(context);
    await RecommendationItemList().initRecommendationList();
 
    /// 2초 후 MainScreen 전환 (replace)
    Timer(const Duration(milliseconds: 1000), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => MainScreen()));
    });
  }

  @override
  void initState() {
    super.initState();
    init();
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
            ),
          ],
        ),
      ),
    );
  }
}
