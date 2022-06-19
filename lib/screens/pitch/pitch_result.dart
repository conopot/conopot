import 'package:conopot/config/constants.dart';
import 'package:conopot/models/music_search_item_lists.dart';
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
    SizeConfig().init(context);
    return Consumer<MusicSearchItemLists>(
      builder: (
        context,
        musicList,
        child,
      ) =>
          Scaffold(
        appBar: AppBar(
          leading: BackButton(color: Colors.black),
          title: Text(
            '측정 결과',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        body: Center(
          child: Column(
            children: [
              SizedBox(
                height: SizeConfig.defaultSize,
              ),
              Text(
                '내 최고음 구간',
                style: TextStyle(
                  color: kTextColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: SizeConfig.defaultSize * 2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color: Color(0xFFE2DCFC),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Text(
                      pitchNumToString[
                          (pitchLevel - 2 < 1) ? 1 : pitchLevel - 2],
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Icon(Icons.remove),
                  Container(
                    padding: EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color: Color(0xFFE2DCFC),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Text(
                      pitchNumToString[pitchLevel],
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: SizeConfig.defaultSize * 2,
              ),

              Text(
                '대한민국 평균 음역대',
                style: TextStyle(
                  color: kTextColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: SizeConfig.defaultSize * 2,
              ),
              Text(
                '남자',
                style: TextStyle(
                  color: Color(0xFF0359FF),
                ),
              ),
              SizedBox(
                height: SizeConfig.defaultSize,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color: Color(0xFF79A7FF),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Text(
                      '2옥타브 솔',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Icon(Icons.remove),
                  Container(
                    padding: EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color: Color(0xFF79A7FF),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Text(
                      '2옥타브 라',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: SizeConfig.defaultSize * 2,
              ),
              Text(
                '여자',
                style: TextStyle(
                  color: Color(0xFFFF037C),
                ),
              ),
              SizedBox(
                height: SizeConfig.defaultSize,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color: Color(0xFFFB83BC),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Text(
                      '3옥타브 레',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Icon(Icons.remove),
                  Container(
                    padding: EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color: Color(0xFFFB83BC),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Text(
                      '3옥타브 미',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
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
                    fontSize: 21,
                  ),
                  children: [
                    TextSpan(
                      text: '내 ',
                      style: TextStyle(
                        color: kTextColor,
                      ),
                    ),
                    TextSpan(
                      text: '최고음',
                      style: TextStyle(
                        color: Color(0xFF7B61FF),
                      ),
                    ),
                    TextSpan(
                      text: ' 주변의 인기곡들',
                      style: TextStyle(
                        color: kTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: SizeConfig.defaultSize * 2,
              ),

              Divider(
                height: 1,
              ),
              SizedBox(
                height: SizeConfig.defaultSize,
              ),
              PitchSearchList(musicList: musicList),
            ],
          ),
        ),
      ),
    );
  }
}
