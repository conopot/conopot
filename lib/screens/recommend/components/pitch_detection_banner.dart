import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:conopot/config/analytics_config.dart';
import 'package:conopot/config/constants.dart';
import 'package:conopot/config/firebase_remote_config.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:conopot/models/note.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/models/pitch_item.dart';
import 'package:conopot/screens/note/add_note_screen.dart';
import 'package:conopot/screens/pitch/pitch_main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class PitchDetectionBanner extends StatefulWidget {
  late MusicSearchItemLists musicList;
  late List<Note> notes;
  PitchDetectionBanner({Key? key, required this.musicList, required this.notes})
      : super(key: key);

  @override
  State<PitchDetectionBanner> createState() => _PitchDetectionBannerState();
}

class _PitchDetectionBannerState extends State<PitchDetectionBanner> {
  double defaultSize = SizeConfig.defaultSize;
  int _current = 0;
  final CarouselController _controller = CarouselController();
  List<String> bannerList = ["Item1", "Item2"];
  final storage = new FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          items: [
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: defaultSize),
              padding: EdgeInsets.all(defaultSize * 2),
              decoration: BoxDecoration(
                  color: kPrimaryLightBlackColor,
                  borderRadius: BorderRadius.all(Radius.circular(8))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "애창곡노트에 노래 5개 이상 추가하고",
                        style: TextStyle(
                            color: kPrimaryWhiteColor,
                            fontSize: defaultSize * 1.7,
                            fontWeight: FontWeight.w500),
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                                text: "AI",
                                style: TextStyle(
                                    color: kMainColor,
                                    fontSize: defaultSize * 2.6,
                                    fontWeight: FontWeight.w600)),
                            TextSpan(
                                text: "가 분석한",
                                style: TextStyle(
                                    color: kPrimaryWhiteColor,
                                    fontSize: defaultSize * 2.5,
                                    fontWeight: FontWeight.w600))
                          ],
                        ),
                      ),
                      Text("노래 추천 받아 보세요!",
                          style: TextStyle(
                              color: kPrimaryWhiteColor,
                              fontSize: defaultSize * 2.5,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                  SizedBox(height: defaultSize * 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("저장한 노래 수 : ${widget.notes.length}",
                              style: TextStyle(
                                  color: kPrimaryWhiteColor,
                                  fontSize: defaultSize * 1.5,
                                  fontWeight: FontWeight.w400)),
                          SizedBox(height: defaultSize * 1.25),
                          (widget.notes.length < 5)
                              ? GestureDetector(
                                  onTap: () {
                                    //!event: 추천_뷰__AI추천_더보기
                                    Analytics_config().userloginEvent();
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                AddNoteScreen()));
                                  },
                                  child: Container(
                                    padding: EdgeInsets.fromLTRB(
                                        defaultSize * 1.5,
                                        defaultSize,
                                        defaultSize * 1.5,
                                        defaultSize),
                                    decoration: BoxDecoration(
                                        color: kMainColor,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8))),
                                    child: Text(
                                      "노래 추가하기",
                                      style: TextStyle(
                                          color: kPrimaryWhiteColor,
                                          fontSize: defaultSize * 1.5,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () {
                                    Analytics_config()
                                        .clickAIRecommendationEvent();
                                    requestCFApi();
                                    setState(() {});
                                    //전면 광고
                                    Provider.of<NoteData>(context,
                                            listen: false)
                                        .aiInterstitialAd();
                                  },
                                  child: Container(
                                    padding: EdgeInsets.fromLTRB(
                                        defaultSize * 1.5,
                                        defaultSize,
                                        defaultSize * 1.5,
                                        defaultSize),
                                    decoration: BoxDecoration(
                                        color: kMainColor,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8))),
                                    child: Text(
                                      "AI 추천받기",
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
                        "assets/images/ai.png",
                        width: defaultSize * 10,
                        height: defaultSize * 10,
                      )
                    ],
                  ),
                ],
              ),
            ),
            Container(
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
                                fontSize: defaultSize * 2.1,
                                fontWeight: FontWeight.w600)),
                        TextSpan(
                            text: "걱정 없는 노래 찾아 보세요!",
                            style: TextStyle(
                                color: kPrimaryWhiteColor,
                                fontSize: defaultSize * 2.1,
                                fontWeight: FontWeight.w600))
                      ],
                    ),
                  ),
                  SizedBox(height: defaultSize),
                  Text("[추천탭] - [테마] - [내 음역대] 에서 확인",
                      style: TextStyle(
                          color: kPrimaryWhiteColor,
                          fontSize: defaultSize * 1.6,
                          fontWeight: FontWeight.w400)),
                  SizedBox(height: defaultSize * 3),
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
                          SizedBox(height: defaultSize * 1.25),
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
            ),
          ],
          carouselController: _controller,
          options: CarouselOptions(
              height: defaultSize * 26,
              enableInfiniteScroll: false,
              viewportFraction: 1,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 5),
              autoPlayAnimationDuration: Duration(milliseconds: 800),
              onPageChanged: (index, reason) {
                setState(() {
                  _current = index;
                });
              }),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: bannerList.asMap().entries.map((e) {
            return GestureDetector(
              onTap: () => _controller.animateToPage(e.key),
              child: Container(
                width: 12,
                height: 12,
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: kMainColor.withOpacity(_current == e.key ? 1 : 0.4)),
              ),
            );
          }).toList(),
        )
      ],
    );
  }

  void requestCFApi() async {
    widget.musicList.recommendRequest = true;
    storage.write(key: "recommendRequest", value: 'true');
    await EasyLoading.show();
    String url = 'https://recommendcf-pfenq2lbpq-du.a.run.app/recommendCF';
    List<String> musicArr =
        Provider.of<NoteData>(context, listen: false).userMusics;
    if (musicArr.length > 20) {
      // 저장한 노트수가 20개 보다 많은 경우 자르기
      musicArr = musicArr.sublist(0, 20);
    }
    Future<dynamic> myFuture = new Future(() async {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"musicArr": musicArr.toString()}),
      );
      return response;
    });
    myFuture.then((response) {
      if (response.statusCode == 200) {
        String? recommendList = response.body;
        if (recommendList != null) {
          widget.musicList.saveAiRecommendationList(recommendList);
          EasyLoading.showSuccess('분석에 성공했습니다!');
        } else {
          EasyLoading.showToast('분석을 위한 데이터가 부족합니다\n노트를 좀더 추가해주세요');
        }
      } else {
        EasyLoading.showToast('서버 문제가 발생했습니다\n채널톡에 문의해주세요');
      }
    }, onError: (e) {
      EasyLoading.showToast('분석에 실패했습니다\n인터넷 연결을 확인해 주세요');
    });
  }
}
