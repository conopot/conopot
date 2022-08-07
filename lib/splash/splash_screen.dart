import 'dart:async';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:conopot/main_screen.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/models/recommendation_item_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState () {
    super.initState();
    /// 노래방 곡 관련 초기화
    Future.delayed(Duration.zero, () {
      Provider.of<MusicSearchItemLists>(context, listen: false).init();
    });

    /// 2초 후 MainScreen 전환 (replace)
    Timer(Duration(milliseconds: 2000), () {
      /// 사용자 노트 초기화 (local storage)
      Provider.of<NoteData>(context, listen: false).initNotes();
      RecommendationItemList().initRecommendationList();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => MainScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image(
              image: const AssetImage('assets/images/splash.png'),
              height: SizeConfig.screenWidth * 0.3,
            ),
          ),
        ),
      ),
    );
  }
}
