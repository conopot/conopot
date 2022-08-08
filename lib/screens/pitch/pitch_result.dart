import 'package:conopot/config/analytics_config.dart';
import 'package:conopot/config/constants.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:conopot/models/pitch_item.dart';
import 'package:conopot/screens/chart/components/pitch_search_list.dart';
import 'package:conopot/config/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

class PitchResult extends StatefulWidget {
  PitchResult({Key? key, required this.fitchLevel}) : super(key: key);

  final int fitchLevel;

  @override
  State<PitchResult> createState() => _PitchResultState(fitchLevel);
}

class _PitchResultState extends State<PitchResult> {
  final int pitchLevel;

  _PitchResultState(this.pitchLevel);

  @override
  void initState() {
    setUserFitch();
    super.initState();
  }

  Future<void> setUserFitch() async {
    final storage = new FlutterSecureStorage();
    await storage.write(key: 'userPitch', value: pitchLevel.toString());

    Future.delayed(Duration.zero, () {
      Provider.of<MusicSearchItemLists>(context, listen: false)
          .changeUserPitch(pitch: pitchLevel);
    });

    Future.delayed(Duration.zero, () {
      Provider.of<MusicSearchItemLists>(context, listen: false)
          .initPitchMusic(pitchNum: pitchLevel);
    });
  }

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;

    Analytics_config().event('음역대_측정_결과_뷰__페이지뷰', {});

    return Consumer<MusicSearchItemLists>(
      builder: (
        context,
        musicList,
        child,
      ) =>
          Scaffold(
        appBar: AppBar(
          title: Text(
            '측정 결과',
          ),
          centerTitle: true,
          leading: BackButton(
            color: kPrimaryWhiteColor,
            onPressed: () {
              int count = 0;
              Navigator.of(context).popUntil((_) => count++ >= 2); //뒤로가기
            },
          ),
        ),
        body: Center(
          child: Column(
            children: [
              SizedBox(
                height: SizeConfig.defaultSize * 2.5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '내 최고음 :',
                    style: TextStyle(
                      color: kPrimaryWhiteColor,
                      fontSize: defaultSize * 1.8,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    width: SizeConfig.defaultSize,
                  ),
                  Container(
                    padding: EdgeInsets.all(defaultSize),
                    decoration: BoxDecoration(
                      color: kPrimaryLightBlackColor,
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Text(
                      pitchNumToString[pitchLevel],
                      style: TextStyle(
                        color: kMainColor,
                        fontSize: defaultSize * 1.6,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: SizeConfig.defaultSize * 3,
              ),
              //내 음역대의 인기곡들
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: defaultSize * 1.5,
                  ),
                  children: [
                    TextSpan(
                      text: '내 ',
                      style: TextStyle(
                        color: kPrimaryWhiteColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: '최고음',
                      style: TextStyle(
                        color: kPrimaryWhiteColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: ' 근처의 인기곡',
                      style: TextStyle(
                        color: kPrimaryWhiteColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: SizeConfig.defaultSize,
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: defaultSize),
                child: Divider(
                  height: 1,
                  color: kPrimaryLightWhiteColor,
                ),
              ),
              SizedBox(
                height: SizeConfig.defaultSize,
              ),
              PitchSearchList(),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            // !event : 음역대 측정 결과뷰 - 홈화면으로 이동
            Analytics_config().event('음역대_측정_결과뷰__홈화면으로_이동', {});
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          label: Text(
            '홈 화면으로 이동',
            style: TextStyle(
                fontWeight: FontWeight.w600, color: kPrimaryWhiteColor),
          ),
          icon: Icon(Icons.home),
          backgroundColor: kMainColor,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
