import 'package:conopot/config/analytics_config.dart';
import 'package:conopot/config/constants.dart';
import 'package:conopot/config/firebase_remote_config.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/screens/musicBook/music_book.dart';
import 'package:conopot/screens/note/note_screen.dart';
import 'package:conopot/screens/recommend/recommend_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  //AdMob
  Map<String, String> App_Quit_Banner_UNIT_ID = kReleaseMode
      ? {
          //release 모드일때 (실기기 사용자)
          'android': 'ca-app-pub-1461012385298546/6974183177',
          'ios': 'ca-app-pub-1461012385298546/6068295613',
        }
      : {
          'android': 'ca-app-pub-3940256099942544/6300978111',
          'ios': 'ca-app-pub-3940256099942544/2934735716',
        };

  int _selectedIndex = 0;
  double defaultSize = SizeConfig.defaultSize;
  List<Widget> _widgetOptions = <Widget>[
    NoteScreen(),
    MusicBookScreen(),
    RecommendScreen()
  ];

  //firebase admob
  bool quitBannerSetting = false;
  bool bannerExist = true;

  @override
  void initState() {
    setState(() {
      //firebase 원격 설정
      //firebase에서 종료 시 배너 광고 출력 여부를 판단
      quitBannerSetting =
          Firebase_Remote_Config().remoteConfig.getBool('quitBannerSetting');
    });
    super.initState();
  }

  // 앱 종료여부 확인 다이어로그
  Future<bool> showExitPopup(context) async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: kDialogColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8))),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text("앱을 종료하시겠습니까?",
                      style: TextStyle(
                          color: kPrimaryLightWhiteColor,
                          fontWeight: FontWeight.w400)),
                ),
                SizedBox(height: defaultSize * 2),
                Row(
                  children: [
                    Expanded(
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("취소",
                                style: TextStyle(
                                    color: kPrimaryLightWhiteColor,
                                    fontWeight: FontWeight.w600)),
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    kPrimaryGreyColor),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ))))),
                    SizedBox(width: defaultSize * 1.5),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          SystemNavigator.pop();
                        },
                        child: Text("종료하기",
                            style: TextStyle(
                                color: kPrimaryWhiteColor,
                                fontWeight: FontWeight.w600)),
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(kMainColor),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ))),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;

    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex == 0) {
          return showExitPopup(context);
        } else {
          (Provider.of<NoteData>(context, listen: false).globalKey.currentWidget
                  as BottomNavigationBar)
              .onTap!(0);
          return false;
        }
      },
      child: Scaffold(
        body: _widgetOptions.elementAt(_selectedIndex),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(color: kPrimaryWhiteColor, width: 0.1))),
          child: BottomNavigationBar(
            key: Provider.of<NoteData>(context, listen: false).globalKey,
            selectedFontSize: defaultSize * 1.2,
            unselectedFontSize: defaultSize * 1.2,
            backgroundColor: kBackgroundColor,
            currentIndex: _selectedIndex,
            selectedItemColor: kMainColor,
            unselectedItemColor: kPrimaryWhiteColor,
            items: [
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.home,
                  color: kPrimaryWhiteColor,
                ),
                label: "홈",
                activeIcon: Icon(
                  Icons.home,
                  color: kMainColor,
                ),
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.search,
                  color: kPrimaryWhiteColor,
                ),
                label: "검색",
                activeIcon: Icon(
                  Icons.search,
                  color: kMainColor,
                ),
              ),
              BottomNavigationBarItem(
                icon: Padding(
                    padding: EdgeInsets.only(bottom: defaultSize * 0.2),
                    child: SvgPicture.asset("assets/icons/recommend.svg",
                        height: defaultSize * 1.7, width: defaultSize * 1.7)),
                label: "추천",
                activeIcon: Padding(
                    padding: EdgeInsets.only(bottom: defaultSize * 0.2),
                    child: SvgPicture.asset("assets/icons/recommend_click.svg",
                        height: defaultSize * 1.7, width: defaultSize * 1.7)),
              ),
            ],
            onTap: (index) {
              if (index == 1) {
                Provider.of<MusicSearchItemLists>(context, listen: false)
                    .changeTabIndex(index: 1);
              }
              setState(() {
                _selectedIndex = index;
                if (index == 1) {
                  //!event: 네비게이션__검색탭
                  Analytics_config().clicksearchTapEvent();
                } else if (index == 2) {
                  //!event: 네비게이션__추천탭
                  Analytics_config().clickRecommendationTapEvent();
                }
              });
            },
          ),
        ),
      ),
    );
  }
}
