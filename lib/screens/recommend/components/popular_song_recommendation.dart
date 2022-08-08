import 'package:conopot/config/analytics_config.dart';
import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:conopot/models/recommendation_item_list.dart';
import 'package:conopot/screens/recommend/popular_recommendation_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PopularSongRecommendation extends StatelessWidget {
  double defaultSize = SizeConfig.defaultSize;
  List<String> _list = ['TJ 인기차트', '금영 인기차트', '올타임 레전드'];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: defaultSize * 1.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('인기',
              style: TextStyle(
                  color: kPrimaryWhiteColor,
                  fontSize: defaultSize * 2,
                  fontWeight: FontWeight.w600)),
          SizedBox(height: defaultSize * 2),
          Container(
            height: defaultSize * 11,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _list.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    if (index == 0) {
                      //!event: 추천_뷰___TJ_인기차트
                      Analytics_config().clickTJChartEvent();

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  PopularRecommendationDetailScreen(
                                      title: _list[index],
                                      songList:
                                          Provider.of<MusicSearchItemLists>(
                                                  context,
                                                  listen: false)
                                              .tjChartSongList)));
                    } else if (index == 1) {
                      //!event: 추천_뷰__금영_인기차트
                      Analytics_config().clickKYChartEvent();

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  PopularRecommendationDetailScreen(
                                      title: _list[index],
                                      songList:
                                          Provider.of<MusicSearchItemLists>(
                                                  context,
                                                  listen: false)
                                              .kyChartSongList)));
                    } else {
                      //!event: 추천_뷰__올타임_레전드
                      Analytics_config().clickAllTimeLegendRecommendationEvent();

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  PopularRecommendationDetailScreen(
                                      title: _list[index],
                                      songList: RecommendationItemList
                                          .allTimeLegendList)));
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: defaultSize * 2),
                    width: defaultSize * 11,
                    decoration: BoxDecoration(color: Colors.transparent),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          child: FittedBox(
                              fit: BoxFit.fill,
                              child: Image.asset(
                                "assets/images/recommend1.png",
                                width: defaultSize * 11,
                                height: defaultSize * 11,
                              )),
                        ),
                        Align(
                            alignment: Alignment.center,
                            child: Text(
                              _list[index],
                              style: TextStyle(
                                  color: kPrimaryWhiteColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: defaultSize * 1.5),
                            )),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
