import 'package:conopot/config/analytics_config.dart';
import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:conopot/models/pitch_item.dart';
import 'package:conopot/screens/pitch/pitch_main_screen.dart';
import 'package:flutter/material.dart';

class PitchDetectionBanner extends StatefulWidget {
  late MusicSearchItemLists musicList;
  PitchDetectionBanner({Key? key, required this.musicList}) : super(key: key);

  @override
  State<PitchDetectionBanner> createState() => _PitchDetectionBannerState();
}

class _PitchDetectionBannerState extends State<PitchDetectionBanner> {
  double defaultSize = SizeConfig.defaultSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: defaultSize),
      padding: EdgeInsets.all(defaultSize * 2),
      decoration: BoxDecoration(
          color: kPrimaryLightBlackColor,
          borderRadius: BorderRadius.all(Radius.circular(8))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "내 음역대 측정하고",
            style: TextStyle(
                color: kPrimaryWhiteColor,
                fontSize: defaultSize * 1.7,
                fontWeight: FontWeight.w500),
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                    text: "삑사리 ",
                    style: TextStyle(
                        color: kMainColor,
                        fontSize: defaultSize * 2.5,
                        fontWeight: FontWeight.w600)),
                TextSpan(
                    text: "걱정 없는",
                    style: TextStyle(
                        color: kPrimaryWhiteColor,
                        fontSize: defaultSize * 2.5,
                        fontWeight: FontWeight.w600))
              ],
            ),
          ),
          Text("노래 추천 받아보세요!",
              style: TextStyle(
                  color: kPrimaryWhiteColor,
                  fontSize: defaultSize * 2.5,
                  fontWeight: FontWeight.w600)),
          SizedBox(height: defaultSize * 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      "내 음역대 : ${widget.musicList.userMaxPitch == -1 ? "" : pitchNumToString[widget.musicList.userPitch].toString()}",
                      style: TextStyle(
                          color: kPrimaryWhiteColor,
                          fontSize: defaultSize * 1.5,
                          fontWeight: FontWeight.w400)),
                  SizedBox(height: defaultSize * 2),
                  GestureDetector(
                    onTap: () {
                      //!evnet: 추천_뷰__음역대 측정
                      Analytics_config()
                          .clickRecommendationPitchDetectionButtonEvent();
              
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PitchMainScreen()));
                    },
                    child: Container(
                      padding: EdgeInsets.fromLTRB(defaultSize * 1.5,
                          defaultSize, defaultSize * 1.5, defaultSize),
                      decoration: BoxDecoration(
                          color: kMainColor,
                          borderRadius:
                              BorderRadius.all(Radius.circular(8))),
                      child: Text(
                        "음역대 측정하기",
                        style: TextStyle(
                            color: kPrimaryWhiteColor,
                            fontSize: defaultSize * 1.5,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  )
                ],
              ),
              Spacer(),
              Image.asset(
                "assets/images/test.png",
                width: defaultSize * 10,
                height: defaultSize * 10,
              )
            ],
          ),
        ],
      ),
    );
  }
}
