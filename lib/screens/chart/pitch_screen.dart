import 'package:conopot/config/constants.dart';
import 'package:conopot/models/music_search_item_lists.dart';
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

    return Consumer<MusicSearchItemLists>(
      builder: (
        context,
        musicList,
        child,
      ) =>
          Scaffold(
        appBar: AppBar(
          title: Text(
            '나만의 옥타브 차트',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          automaticallyImplyLeading: false,
          centerTitle: true,
        ),
        body: Column(
          children: [
            PitchSearchBar(musicList: musicList),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                children: [
                  TextSpan(
                    text: '* 음역대 측정 ',
                    style: TextStyle(
                      color: Color(0xFF7B61FF),
                    ),
                  ),
                  TextSpan(
                    text: '후 내게 맞는 노래인지 확인하세요!',
                    style: TextStyle(
                      color: kTextColor,
                    ),
                  ),
                ],
              ),
            ),
            PitchDropdownOption(musicList: musicList),
            PitchSearchList(musicList: musicList),
          ],
        ),
      ),
    );
  }
}
