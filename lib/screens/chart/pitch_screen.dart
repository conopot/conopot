import 'package:conopot/config/analytics_config.dart';
import 'package:conopot/config/constants.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/screens/chart/components/pitch_search_bar.dart';
import 'package:conopot/screens/chart/components/pitch_search_list.dart';
import 'package:conopot/screens/pitch/components/pitch_dropdown_option.dart';
import 'package:conopot/config/size_config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PitchScreen extends StatefulWidget {
  PitchScreen({Key? key}) : super(key: key);

  @override
  State<PitchScreen> createState() => _PitchScreenState();
}

class _PitchScreenState extends State<PitchScreen> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    double widthSize = SizeConfig.screenWidth / 10;
    Analytics_config().pitchMeasurePageView();

    return Consumer<MusicSearchItemLists>(
      builder: (
        context,
        musicList,
        child,
      ) =>
          Scaffold(
        appBar: AppBar(
          title: Text(
            '노래 최고음 검색',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          leading: BackButton(
            color: Colors.black,
            onPressed: () {
              Navigator.pop(context); //뒤로가기
            },
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            PitchSearchBar(
              musicList: musicList,
            ),
            // RichText(
            //   text: TextSpan(
            //     style: TextStyle(
            //       fontWeight: FontWeight.bold,
            //       fontSize: 12,
            //     ),
            //     children: [
            //       TextSpan(
            //         text: '* 음역대 측정 ',
            //         style: TextStyle(
            //           color: kPrimaryColor,
            //         ),
            //       ),
            //       TextSpan(
            //         text: '후 내게 맞는 노래인지 확인하세요!',
            //         style: TextStyle(
            //           color: kTextColor,
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            PitchDropdownOption(),
            PitchSearchList(),
          ],
        ),
      ),
    );
  }
}
