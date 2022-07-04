import 'package:conopot/config/constants.dart';
import 'package:conopot/models/music_search_item_lists.dart';
import 'package:conopot/models/pitch_item.dart';
import 'package:conopot/screens/chart/components/pitch_search_list.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/screens/user/user_note_setting_screen.dart';
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
                '내 최고음',
                style: TextStyle(
                  color: kTextColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: SizeConfig.defaultSize * 2,
              ),

              Container(
                padding: EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: Color(0xFFE2DCFC),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  pitchNumToString[pitchLevel],
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),

              SizedBox(
                height: SizeConfig.defaultSize * 2,
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
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => noteSettingScreen()),
            );
          },
          label: Text(
            '애창곡 노트 설정하러가기',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          icon: Icon(Icons.note_add_outlined),
          backgroundColor: kPrimaryColor,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
