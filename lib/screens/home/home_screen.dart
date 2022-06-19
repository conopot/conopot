import 'package:conopot/components/custom_page_route.dart';
import 'package:conopot/config/constants.dart';
import 'package:conopot/models/music_search_item_lists.dart';
import 'package:conopot/screens/pitch/pitch_choice.dart';
import 'package:conopot/screens/pitch/pitch_measure.dart';
import 'package:conopot/config/size_config.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: SizeConfig.screenHeight / 5,
          ),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              children: [
                TextSpan(
                  text: '내 ',
                  style: TextStyle(
                    color: kTextColor,
                  ),
                ),
                TextSpan(
                  text: '음역대',
                  style: TextStyle(
                    color: Color(0xFF7B61FF),
                  ),
                ),
                TextSpan(
                  text: '를 알고있나요?',
                  style: TextStyle(
                    color: kTextColor,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: SizeConfig.defaultSize,
          ),
          Text(
            '음역대란 사람이 낼 수 있는',
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 13,
              color: Color(0xFF4F4F4F),
            ),
          ),
          SizedBox(
            height: SizeConfig.defaultSize,
          ),
          Text(
            '최저음부터 최고음까지의 범위를 말합니다.',
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 13,
              color: Color(0xFF4F4F4F),
            ),
          ),
          SizedBox(
            height: SizeConfig.defaultSize * 5,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                CustomPageRoute(
                  child: PitchMeasure(),
                ),
              );
            },
            child: Center(
              child: Card(
                color: Colors.white,
                elevation: 2,
                margin: EdgeInsets.symmetric(vertical: 15.0),
                child: SizedBox(
                  width: SizeConfig.screenWidth * 0.8,
                  height: SizeConfig.screenHeight * 0.15,
                  child: Center(
                    child: ListTile(
                      leading: Icon(
                        Icons.mic,
                        size: SizeConfig.screenHeight * 0.15 * 0.5,
                        color: Colors.black,
                      ),
                      title: Text(
                        '직접 음역대 측정해볼래요!',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('크게 소리낼 수 있는 환경에서 추천'),
                    ),
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              /// Pitch chart 초기화
              Future.delayed(Duration.zero, () {
                Provider.of<MusicSearchItemLists>(context, listen: false)
                    .initFitch();
              });
              Navigator.push(
                context,
                CustomPageRoute(
                  child: PitchChoice(),
                ),
              );
            },
            child: Center(
              child: Card(
                color: Colors.white,
                elevation: 2,
                margin: EdgeInsets.symmetric(vertical: 15.0),
                child: SizedBox(
                  width: SizeConfig.screenWidth * 0.8,
                  height: SizeConfig.screenHeight * 0.15,
                  child: Center(
                    child: ListTile(
                      leading: Icon(
                        Icons.music_note_outlined,
                        size: SizeConfig.screenHeight * 0.15 * 0.5,
                        color: Colors.black,
                      ),
                      title: Text(
                        '이 노래 불러봤어요!',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('불러본 노래 바탕으로 내 음역대 찾기'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
