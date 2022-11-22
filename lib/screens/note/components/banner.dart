import 'package:carousel_slider/carousel_slider.dart';
import 'package:conopot/config/analytics_config.dart';
import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/models/youtube_player_provider.dart';
import 'package:conopot/screens/pitch/pitch_main_screen.dart';
import 'package:conopot/screens/user/invite_screen.dart';
import 'package:conopot/screens/user/user_note_setting_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class CarouselSliderBanner extends StatelessWidget {
  final double defaultSize = SizeConfig.defaultSize;

  final imageIcons = [
    "assets/icons/friends.svg",
    "assets/icons/feed.svg",
    "assets/icons/banner_cat.svg",
    "assets/icons/banner_mike.svg",
    "assets/icons/banner_music_score.svg",
  ];

  final sentence1 = [
    "친구 초대하고 미션 수행 시",
    "다른 사람들은 노래방에서 뭘 부를까? 🤔",
    "노래방에서 부를 노래를 찾고 계신가요? 😮",
    "노래방 전투력 측정 😎",
    "최고음 표시가 가능한 것을 아시나요? 🧐",
  ];

  final sentence2 = [
    "평생 광고 제거해드려요!",
    "싱스타그램에서 확인해보세요!!",
    "추천탭에서 노래를 추천받아 보세요!",
    "당신의 음역대를 측정해보세요",
    "우측 상단 [설정] - [애창곡 노트 설정]",
  ];

  final screen = [
    InviteScreen(),
    Container(),
    Container(),
    PitchMainScreen(),
    NoteSettingScreen(),
  ];

  // 배너 생성 함수 (인자 : 아이콘 이미지, 문장1, 문장2)
  Widget _bannerItem(BuildContext context, int itemIndex, String imageIcon,
      String sentence1, String sentence2, Widget screen) {
    return GestureDetector(
      onTap: () {
        // !event 배너 클릭 이벤트
        if (itemIndex == 0) {
          Analytics_config().inviteBannerClick();
          //login 여부 확인
          var loginState =
              Provider.of<NoteData>(context, listen: false).isLogined;
          //login 하지 않은 사용자라면 -> 로그인 유도
          if (loginState == false) {
            EasyLoading.showToast("로그인 후 사용 가능한 기능입니다 😄");
          }
          //login 사용자 -> 친구 초대 스크린 이동
          else {
            Provider.of<YoutubePlayerProvider>(context, listen: false)
                .closePlayer();
            Provider.of<YoutubePlayerProvider>(context, listen: false)
                .refresh();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => screen),
            );
          }
        } else if (itemIndex == 1) {
          (Provider.of<NoteData>(context, listen: false).globalKey.currentWidget
                  as BottomNavigationBar)
              .onTap!(3);
        } else if (itemIndex == 2) {
          Analytics_config().noteViewBannerRecommandEvent();
          (Provider.of<NoteData>(context, listen: false).globalKey.currentWidget
                  as BottomNavigationBar)
              .onTap!(2);
        } else {
          if (itemIndex == 3) {
            Provider.of<YoutubePlayerProvider>(context, listen: false)
                .closePlayer();
            Provider.of<YoutubePlayerProvider>(context, listen: false)
                .refresh();
            Analytics_config().noteViewBannerMeasureEvent();
          } else {
            Provider.of<YoutubePlayerProvider>(context, listen: false)
                .closePlayer();
            Provider.of<YoutubePlayerProvider>(context, listen: false)
                .refresh();
            Analytics_config().noteViewBannerNoteSettingEvent();
          }
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => screen),
          );
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: defaultSize * 0.3),
        padding: EdgeInsets.symmetric(horizontal: defaultSize * 1.5),
        decoration: BoxDecoration(
          color: kPrimaryLightBlackColor,
          borderRadius: BorderRadius.all(
            Radius.circular(8),
          ),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(
            flex: 1,
            child: Container(
              margin: EdgeInsets.only(right: defaultSize * 1.5),
              child: (itemIndex == 0)
                  ? Image.asset("assets/images/people.png",
                      width: defaultSize * 5, height: defaultSize * 5)
                  : (itemIndex == 1)
                      ? Image.asset("assets/images/singstagram.png",
                          width: defaultSize * 5, height: defaultSize * 5)
                      : SvgPicture.asset(
                          imageIcon,
                          width: defaultSize * 5,
                          height: defaultSize * 5,
                          fit: BoxFit.scaleDown,
                        ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: defaultSize * 0.5,
                ),
                Text(
                  sentence1,
                  style: TextStyle(
                    fontSize: defaultSize * 1.2,
                    color: kPrimaryWhiteColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  height: defaultSize * 0.2,
                ),
                Text(
                  sentence2,
                  style: TextStyle(
                    fontSize: defaultSize * 1.3,
                    color: kPrimaryWhiteColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      options: CarouselOptions(
        height: defaultSize * 8.5,
        enableInfiniteScroll: false,
        viewportFraction: 0.95,
        autoPlay: true,
        autoPlayInterval: Duration(seconds: 5),
        autoPlayAnimationDuration: Duration(milliseconds: 800),
      ),
      itemCount: 5,
      itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) =>
          _bannerItem(context, itemIndex, imageIcons[itemIndex],
              sentence1[itemIndex], sentence2[itemIndex], screen[itemIndex]),
    );
  }
}
