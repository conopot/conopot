import 'package:conopot/config/analytics_config.dart';
import 'package:conopot/config/constants.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/screens/musicBook/components/pop_search_list.dart';
import 'package:conopot/screens/musicBook/components/musicbook_search_list.dart';
import 'package:conopot/config/size_config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChartScreen extends StatelessWidget {
  const ChartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    double widthSize = SizeConfig.screenWidth / 10;

    Analytics_config().popChartScreenPageViewEvent();

    return Consumer<MusicSearchItemLists>(
      builder: (
        context,
        musicList,
        child,
      ) =>
          DefaultTabController(
        initialIndex: 0,
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            leading: BackButton(
              color: Colors.black,
              onPressed: () {
                Navigator.pop(context); //뒤로가기
              },
            ),
            centerTitle: true,
            title: TabBar(
              isScrollable: true,
              onTap: (index) {
                musicList.changeChartTabIndex(index: index + 1);
              },
              indicatorSize: TabBarIndicatorSize.label,
              indicatorColor: Color(0xFF7B61FF),
              tabs: [
                Text(
                  'TJ',
                  style: TextStyle(
                    color: (musicList.tabIndex == 1)
                        ? kTextColor
                        : kTextLightColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '금영',
                  style: TextStyle(
                    color: (musicList.tabIndex == 2)
                        ? kTextColor
                        : kTextLightColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Center(
                    child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "${DateTime.now().month}월 ",
                        style: TextStyle(
                          color: kPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: "인기차트",
                        style: TextStyle(
                          color: kTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )),
              ),
            ],
          ),
          body: TabBarView(
            children: [
              Column(
                children: [
                  PopSearchList(musicList: musicList),
                ],
              ),
              Column(
                children: [
                  PopSearchList(musicList: musicList),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
