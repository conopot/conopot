import 'package:conopot/config/analytics_config.dart';
import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/music_search_item_lists.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/models/pitch_item.dart';
import 'package:conopot/screens/chart/pitch_screen.dart';
import 'package:conopot/screens/musicBook/music_book.dart';
import 'package:conopot/screens/musicBook/music_chart_screen.dart';
import 'package:conopot/screens/pitch/pitch_main_screen.dart';
import 'package:conopot/screens/user/channel_talk.dart';
import 'package:conopot/screens/user/user_note_setting_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

class UserScreen extends StatefulWidget {
  UserScreen({Key? key}) : super(key: key);

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  @override
  void initState() {
    Analytics_config.analytics.logEvent("내 정보 뷰 - 페이지뷰");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicSearchItemLists>(
        builder: (
      context,
      musicList,
      child,
    ) =>
            Scaffold(
              appBar: AppBar(
                title: Text(
                  "MY",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
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
                            width: SizeConfig.defaultSize * 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '내 최고음',
                                style: TextStyle(
                                    color: kPrimaryBlackColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                                textAlign: TextAlign.left,
                              ),
                              SizedBox(
                                height: SizeConfig.defaultSize * 10 / 2,
                              ),
                              (musicList.userMaxPitch != -1)
                                  ? Text(
                                      pitchNumToString[musicList.userPitch]
                                          .toString(),
                                      style: TextStyle(
                                          color: kTextColor,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    )
                                  : TextButton(
                                      onPressed: () {
                                        Provider.of<MusicSearchItemLists>(
                                                context,
                                                listen: false)
                                            .checkPitchMeasureEvent(
                                                Provider.of<NoteData>(context,
                                                        listen: false)
                                                    .notes
                                                    .length);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  PitchMainScreen()),
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: Size(50, 30),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text("음 측정하러 가기")),
                            ],
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: SizeConfig.screenWidth / 20,
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        Future.delayed(Duration.zero, () {
                          musicList.initBook();
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
                              width: SizeConfig.defaultSize * 10,
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
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        Provider.of<MusicSearchItemLists>(context,
                                listen: false)
                            .checkPitchMeasureEvent(
                                Provider.of<NoteData>(context, listen: false)
                                    .notes
                                    .length);
                        Future.delayed(Duration.zero, () {
                          musicList.initChart();
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
                              width: SizeConfig.defaultSize * 10,
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
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        Provider.of<MusicSearchItemLists>(context,
                                listen: false)
                            .checkPitchMeasureEvent(
                                Provider.of<NoteData>(context, listen: false)
                                    .notes
                                    .length);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => PitchMainScreen()),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(left: 5),
                        padding: EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 20.0),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/measure.svg',
                              height: 20,
                            ),
                            SizedBox(
                              width: 15,
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
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        Provider.of<MusicSearchItemLists>(context,
                                listen: false)
                            .checkPitchMeasureEvent(
                                Provider.of<NoteData>(context, listen: false)
                                    .notes
                                    .length);
                        Future.delayed(Duration.zero, () {
                          musicList.initFitch();
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
                              width: SizeConfig.defaultSize * 10,
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
                              width: SizeConfig.defaultSize * 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        Provider.of<MusicSearchItemLists>(context,
                                listen: false)
                            .checkPitchMeasureEvent(
                                Provider.of<NoteData>(context, listen: false)
                                    .notes
                                    .length);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => noteSettingScreen()),
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
                              width: SizeConfig.defaultSize * 10,
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
                  ],
                ),
              ),
              floatingActionButton: Container(
                margin: EdgeInsets.fromLTRB(0, 0, 15, 15),
                width: 75,
                height: 75,
                child: FittedBox(
                  child: FloatingActionButton(
                    backgroundColor: Colors.white,
                    elevation: 5.0,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ChannelTalkScreen()),
                      );
                    },
                    child: Image.asset(
                      "assets/images/chat.png",
                      width: SizeConfig.defaultSize * 30,
                      height: SizeConfig.defaultSize * 30,
                    ),
                  ),
                ),
              ),
            ));
  }
}
