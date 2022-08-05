import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/music_search_item_lists.dart';
import 'package:conopot/models/pitch_item.dart';
import 'package:conopot/screens/pitch/pitch_main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class RecommendScreen extends StatefulWidget {
  const RecommendScreen({Key? key}) : super(key: key);

  @override
  State<RecommendScreen> createState() => _RecommendScreenState();
}

class _RecommendScreenState extends State<RecommendScreen> {
  double defaultSize = SizeConfig.defaultSize;

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
          title: Text("추천"),
          centerTitle: false,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: defaultSize),
                  padding: EdgeInsets.all(defaultSize * 1.5),
                  decoration: BoxDecoration(
                      color: kPrimaryLightBlackColor,
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "내 음역대 측정하고",
                              style: TextStyle(
                                  color: kPrimaryWhiteColor,
                                  fontSize: defaultSize * 1.7,
                                  fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: defaultSize),
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
                            Text(
                                "내 음역대 : ${musicList.userMaxPitch == -1 ? "" : pitchNumToString[musicList.userPitch].toString()}",
                                style: TextStyle(
                                    color: kPrimaryWhiteColor,
                                    fontSize: defaultSize * 1.5,
                                    fontWeight: FontWeight.w400)),
                            SizedBox(height: defaultSize * 2),
                            GestureDetector(
                              onTap: () {
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
                        Align(
                            alignment: Alignment.bottomRight,
                            child: SvgPicture.asset(
                              "assets/icons/chart.svg",
                              height: defaultSize * 10,
                              width: defaultSize * 10,
                            ))
                      ],
                    ),
                  ),
                ),
                SizedBox(height: defaultSize),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: defaultSize),
                  child: Row(
                    children: [
                      Text("맞춤 추천", style: TextStyle(fontSize: defaultSize)),
                      Spacer(),
                      Container(padding: EdgeInsets.all(defaultSize * 0.8),decoration: BoxDecoration(color: kMainColor, borderRadius: BorderRadius.all(Radius.circular(8))),)
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
