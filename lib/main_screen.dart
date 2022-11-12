import 'dart:io';

import 'package:conopot/config/analytics_config.dart';
import 'package:conopot/config/constants.dart';
import 'package:conopot/config/firebase_remote_config.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/models/youtube_player_provider.dart';
import 'package:conopot/screens/feed/feed_screen.dart';
import 'package:conopot/screens/musicBook/music_book.dart';
import 'package:conopot/screens/note/components/mini_youtube_player.dart';
import 'package:conopot/screens/note/note_screen.dart';
import 'package:conopot/screens/recommend/recommend_screen.dart';
import 'package:conopot/screens/user/user_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import 'models/note.dart';

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
          'android': 'ca-app-pub-7139143792782560/8735916434',
          'ios': 'ca-app-pub-7139143792782560/5121811348',
        }
      : {
          'android': 'ca-app-pub-3940256099942544/6300978111',
          'ios': 'ca-app-pub-3940256099942544/2934735716',
        };

  int _selectedIndex = 0;
  double defaultSize = SizeConfig.defaultSize;

  late List<Widget> _widgetOptions;

  //firebase admob
  bool quitBannerSetting = false;
  bool bannerExist = true;

  // TODO: Add _bannerAd
  BannerAd? _bannerAd;

  @override
  void initState() {
    Provider.of<NoteData>(context, listen: false).isUserRewarded();
    _widgetOptions = <Widget>[
      NoteScreen(),
      MusicBookScreen(),
      RecommendScreen(),
      FeedScreen(),
      UserScreen(),
    ];

    // TODO: Load a banner ad
    BannerAd(
      adUnitId: App_Quit_Banner_UNIT_ID[Platform.isIOS ? 'ios' : 'android']!,
      request: AdRequest(),
      size: AdSize.mediumRectangle,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
            Analytics_config().adQuitBannerSuccess();
          });
        },
        onAdFailedToLoad: (ad, err) {
          Analytics_config().adQuitBannerFail();
          ad.dispose();
        },
      ),
    ).load();

    setState(() {
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
                // TODO: Display a banner when ready
                if (_bannerAd != null &&
                    !Provider.of<NoteData>(context, listen: false).rewardFlag)
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: _bannerAd!.size.width.toDouble(),
                      height: _bannerAd!.size.height.toDouble(),
                      child: AdWidget(ad: _bannerAd!),
                    ),
                  ),
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
                                    color: kMainColor,
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
        bottomNavigationBar: IntrinsicHeight(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                    border: Border(
                        top:
                            BorderSide(color: kPrimaryWhiteColor, width: 0.1))),
                child: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
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
                        Icons.book,
                        color: kPrimaryWhiteColor,
                      ),
                      label: "노래방 책",
                      activeIcon: Icon(
                        Icons.book,
                        color: kMainColor,
                      ),
                    ),
                    BottomNavigationBarItem(
                      icon: Padding(
                          padding: EdgeInsets.only(bottom: 5),
                          child: SvgPicture.asset("assets/icons/recommend.svg",
                              height: 17, width: 17)),
                      label: "추천",
                      activeIcon: Padding(
                          padding: EdgeInsets.only(bottom: 5),
                          child: SvgPicture.asset(
                              "assets/icons/recommend_click.svg",
                              height: 17,
                              width: 17)),
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(
                        Icons.forum,
                        color: kPrimaryWhiteColor,
                      ),
                      label: "싱스타그램",
                      activeIcon: Icon(
                        Icons.forum,
                        color: kMainColor,
                      ),
                    ),
                    BottomNavigationBarItem(
                      icon:
                          Icon(Icons.perm_identity, color: kPrimaryWhiteColor),
                      label: "내 정보",
                      activeIcon: Icon(
                        Icons.perm_identity,
                        color: kMainColor,
                      ),
                    ),
                  ],
                  onTap: (index) {
                    if (index != 0) {
                      Provider.of<YoutubePlayerProvider>(context, listen: false)
                          .closePlayer();
                      Provider.of<YoutubePlayerProvider>(context, listen: false)
                          .refresh();
                    }
                    if (index == 0) {
                      Provider.of<YoutubePlayerProvider>(context, listen: false)
                          .firstStart();
                      Provider.of<YoutubePlayerProvider>(context, listen: false)
                          .refresh();
                    }
                    // TJ탭
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
                      } else if (index == 3) {
                        //!event: 네비게이션__피드탭
                        Analytics_config().feedTabClickEvent();
                      } else if (index == 4) {
                        //!event: 네비게이션__내정보
                        Analytics_config().clickMyTapEvent();
                      }
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: Dispose a BannerAd object
    _bannerAd?.dispose();

    super.dispose();
  }
}
