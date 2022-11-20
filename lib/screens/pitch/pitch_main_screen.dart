import 'package:conopot/components/custom_page_route.dart';
import 'package:conopot/config/constants.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:conopot/models/youtube_player_provider.dart';
import 'package:conopot/screens/pitch/pitch_choice.dart';
import 'package:conopot/screens/pitch/pitch_measure.dart';
import 'package:conopot/config/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class PitchMainScreen extends StatefulWidget {
  PitchMainScreen({Key? key}) : super(key: key);

  @override
  State<PitchMainScreen> createState() => _PitchMainScreenState();
}

class _PitchMainScreenState extends State<PitchMainScreen> {
  double defaultSize = SizeConfig.defaultSize;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return WillPopScope(
      onWillPop: () async {
        Provider.of<YoutubePlayerProvider>(context, listen: false).openPlayer();
        Provider.of<YoutubePlayerProvider>(context, listen: false).refresh();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "음역대 측정",
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: defaultSize * 5),
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
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: defaultSize * 3),
                      width: double.infinity,
                      padding: EdgeInsets.all(defaultSize * 3),
                      decoration: BoxDecoration(
                        color: kPrimaryLightBlackColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Container(
                              width: SizeConfig.screenHeight * 0.15,
                              height: SizeConfig.screenHeight * 0.15,
                              child: FittedBox(
                                child: SvgPicture.asset(
                                  'assets/icons/mike.svg',
                                ),
                              ),
                            ),
                            SizedBox(
                              height: SizeConfig.defaultSize * 2.5,
                            ),
                            Text(
                              '크게 소리낼 수 있는 환경에서',
                              style: TextStyle(
                                color: kPrimaryWhiteColor,
                                fontSize: defaultSize * 1.5,
                                fontWeight: FontWeight.w200,
                              ),
                            ),
                            Text(
                              '직접 음역대 측정해보기',
                              style: TextStyle(
                                color: kPrimaryWhiteColor,
                                fontSize: defaultSize * 2,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: defaultSize * 3,
                ),
                GestureDetector(
                  onTap: () {
                    Provider.of<MusicSearchItemLists>(context, listen: false)
                        .initFitch();
                    Provider.of<MusicSearchItemLists>(context, listen: false)
                            .isChecked =
                        List<bool>.filled(
                            Provider.of<MusicSearchItemLists>(context,
                                    listen: false)
                                .highestFoundItems
                                .length,
                            false);
                    Navigator.push(
                      context,
                      CustomPageRoute(
                        child: PitchChoice(),
                      ),
                    );
                  },
                  child: Center(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: defaultSize * 3),
                      width: double.infinity,
                      padding: EdgeInsets.all(defaultSize * 3),
                      decoration: BoxDecoration(
                        color: kPrimaryLightBlackColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Container(
                              width: SizeConfig.screenHeight * 0.15,
                              height: SizeConfig.screenHeight * 0.15,
                              child: FittedBox(
                                child: SvgPicture.asset(
                                  'assets/icons/search.svg',
                                ),
                              ),
                            ),
                            SizedBox(
                              height: SizeConfig.defaultSize * 2.5,
                            ),
                            Text(
                              '불러 본 노래 바탕으로',
                              style: TextStyle(
                                color: kPrimaryWhiteColor,
                                fontSize: defaultSize * 1.5,
                                fontWeight: FontWeight.w200,
                              ),
                            ),
                            Text(
                              '내 음역대 찾기',
                              style: TextStyle(
                                color: kPrimaryWhiteColor,
                                fontSize: defaultSize * 2,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
