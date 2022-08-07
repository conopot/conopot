import 'package:carousel_slider/carousel_slider.dart';
import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/main_screen.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/screens/pitch/pitch_main_screen.dart';
import 'package:conopot/screens/user/user_note_setting_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class CarouselSliderBanner extends StatelessWidget {
  final double defaultSize = SizeConfig.defaultSize;

  final imageIcons = [
    "assets/icons/banner_cat.svg",
    "assets/icons/banner_mike.svg",
    "assets/icons/banner_music_score.svg",
  ];

  final sentence1 = [
    "노래방에서 부를 노래를 찾고 계신가요? 😮",
    "노래방 전투력 측정 😎",
    "최고음 표시가 가능한 것을 아시나요? 🧐",
  ];

  final sentence2 = [
    "추천탭에서 노래를 추천받아 보세요!",
    "당신의 음역대를 측정해보세요",
    "우측 상단 [설정] - [애창곡 노트 설정]",
  ];

  final screen = [
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
        Provider.of<MusicSearchItemLists>(context, listen: false)
            .pitchBannerClickEvent(
                Provider.of<NoteData>(context, listen: false).notes.length);
        if (itemIndex == 0) {
          (Provider.of<NoteData>(context, listen: false).globalKey.currentWidget
                  as BottomNavigationBar)
              .onTap!(2);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => screen),
          );
        }
      },
      child: Container(
        width: defaultSize * 35.5,
        margin: EdgeInsets.symmetric(horizontal: defaultSize * 0.3),
        padding: EdgeInsets.all(defaultSize * 1.5),
        decoration: BoxDecoration(
          color: kPrimaryLightBlackColor,
          borderRadius: BorderRadius.all(
            Radius.circular(8),
          ),
        ),
        child: Row(children: [
          SvgPicture.asset(
            imageIcon,
            width: defaultSize * 5,
            height: defaultSize * 5,
            fit: BoxFit.scaleDown,
          ),
          SizedBox(width: defaultSize * 1.5),
          Column(
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
                  fontSize: defaultSize * 1.5,
                  color: kPrimaryWhiteColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          )
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      options: CarouselOptions(
        height: defaultSize * 7.8,
        enableInfiniteScroll: false,
        viewportFraction: 0.95,
        autoPlay: true,
        autoPlayInterval: Duration(seconds: 5),
        autoPlayAnimationDuration: Duration(milliseconds: 800),
      ),
      itemCount: 3,
      itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) =>
          _bannerItem(context, itemIndex, imageIcons[itemIndex],
              sentence1[itemIndex], sentence2[itemIndex], screen[itemIndex]),
    );
  }
}
