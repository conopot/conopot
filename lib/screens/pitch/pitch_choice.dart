import 'package:conopot/components/custom_page_route.dart';
import 'package:conopot/config/constants.dart';
import 'package:conopot/models/music_search_item_lists.dart';
import 'package:conopot/screens/chart/components/pitch_search_bar.dart';
import 'package:conopot/screens/pitch/components/pitch_checkbox.dart';
import 'package:conopot/screens/pitch/components/pitch_dropdown.dart';
import 'package:conopot/screens/pitch/pitch_result.dart';
import 'package:conopot/config/size_config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PitchChoice extends StatelessWidget {
  const PitchChoice({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Consumer<MusicSearchItemLists>(
        builder: (context, musicList, child) => Container(
              child: Scaffold(
                appBar: AppBar(
                  leading: BackButton(color: Colors.black),
                  title: Text(
                    '음역대 측정',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  centerTitle: true,
                ),
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: SizeConfig.defaultSize * 3,
                    ),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 21,
                        ),
                        children: [
                          TextSpan(
                            text: '이노래, ',
                            style: TextStyle(
                              color: Color(0xFF7B61FF),
                            ),
                          ),
                          TextSpan(
                            text: '가능하세요?',
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
                    Text(
                      '전 구간 부를 수 있는 노래만 선택해주세요!',
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                        color: Color(0xFF4F4F4F),
                      ),
                    ),
                    PitchSearchBar(musicList: musicList),
                    PitchDropdown(musicList: musicList),
                    PitchCheckBox(musicList: musicList),
                  ],
                ),
                floatingActionButton: FloatingActionButton.extended(
                  onPressed: () => {
                    musicList.getMaxPitch(),
                    if (musicList.userMaxPitch == -1)
                      {
                        AlertDialog(
                          title: Text('최소 하나 이상 선택해주세요!'),
                        ),
                        print(1),
                      }
                    else
                      {
                        Navigator.push(
                          context,
                          CustomPageRoute(
                            child:
                                PitchResult(fitchLevel: musicList.userMaxPitch),
                          ),
                        ),
                      }
                  },
                  icon: Icon(Icons.check_sharp),
                  label: Text('선택 완료'),
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerFloat,
              ),
            ));
  }
}
