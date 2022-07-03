import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/music_search_item_lists.dart';
import 'package:conopot/screens/chart/pitch_screen.dart';
import 'package:conopot/screens/musicBook/music_book.dart';
import 'package:conopot/screens/musicBook/music_chart_screen.dart';
import 'package:conopot/screens/musicBook/music_screen.dart';
import 'package:conopot/screens/pitch/pitch_main_screen.dart';
import 'package:conopot/screens/pitch/pitch_choice.dart';
import 'package:conopot/screens/user/user_note_setting_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class UserScreen extends StatefulWidget {
  UserScreen({Key? key}) : super(key: key);

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "MY",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: BackButton(
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context); //뒤로가기
          },
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/user.svg',
                    height: 70,
                  ),
                  SizedBox(
                    width: SizeConfig.defaultSize,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '내 최고음',
                        style: TextStyle(color: kTextColor, fontSize: 15),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(
                        height: SizeConfig.defaultSize / 2,
                      ),
                      Text(
                        '3옥타브 시',
                        style: TextStyle(
                            color: kTextColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(
              height: SizeConfig.screenWidth / 20,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => noteSettingScreen()),
                );
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 20.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.settings,
                      size: 25,
                    ),
                    SizedBox(
                      width: SizeConfig.defaultSize,
                    ),
                    Text(
                      '애창곡 노트 설정',
                      style: TextStyle(
                        color: kTextColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => HomeScreen()),
                );
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 20.0),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/homeSpeak.svg',
                      height: 20,
                    ),
                    SizedBox(
                      width: SizeConfig.defaultSize,
                    ),
                    Text(
                      '최고 음역대 측정하기',
                      style: TextStyle(
                        color: kTextColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Future.delayed(Duration.zero, () {
                  Provider.of<MusicSearchItemLists>(context, listen: false)
                      .initBook();
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MusicBookScreen()),
                );
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 20.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      size: 25,
                    ),
                    SizedBox(
                      width: SizeConfig.defaultSize,
                    ),
                    Text(
                      '노래 검색',
                      style: TextStyle(
                        color: kTextColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Future.delayed(Duration.zero, () {
                  Provider.of<MusicSearchItemLists>(context, listen: false)
                      .initChart();
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ChartScreen()),
                );
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 20.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.bar_chart_rounded,
                      size: 25,
                    ),
                    SizedBox(
                      width: SizeConfig.defaultSize,
                    ),
                    Text(
                      '노래방 인기 차트',
                      style: TextStyle(
                        color: kTextColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Future.delayed(Duration.zero, () {
                  Provider.of<MusicSearchItemLists>(context, listen: false)
                      .initFitch();
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PitchScreen()),
                );
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 20.0),
                child: Row(
                  children: [
                    Icon(Icons.music_note),
                    SizedBox(
                      width: SizeConfig.defaultSize,
                    ),
                    Text(
                      '노래 최고음 검색',
                      style: TextStyle(
                        color: kTextColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(
                      width: SizeConfig.defaultSize,
                    ),
                    SvgPicture.asset(
                      'assets/icons/betaTag.svg',
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}