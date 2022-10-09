import 'package:conopot/config/analytics_config.dart';
import 'package:conopot/config/constants.dart';
import 'package:conopot/config/firebase_remote_config.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/music_search_item.dart';
import 'package:conopot/models/recommendation_item_list.dart';
import 'package:conopot/screens/recommend/recommendation_detail_screen.dart';
import 'package:flutter/material.dart';

class GenreRecommendation extends StatelessWidget {
  const GenreRecommendation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    var recommandJPOP =
        Firebase_Remote_Config().remoteConfig.getString('recommandJPOP');

    List<String> titleList = ['발라드', '힙합', '알앤비', '팝', '만화 주제가', '트로트'];

    if (recommandJPOP == 'B') {
      titleList.insert(1, '일본 노래');
    }

    List<List<MusicSearchItem>> songList = [
      RecommendationItemList.balladeList,
      RecommendationItemList.hiphopList,
      RecommendationItemList.rnbList,
      RecommendationItemList.popList,
      RecommendationItemList.cartoonList,
      RecommendationItemList.oldList,
    ];

    if (recommandJPOP == 'B') {
      songList.insert(1, RecommendationItemList.jpopList);
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: defaultSize * 1.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('장르',
              style: TextStyle(
                  color: kPrimaryWhiteColor,
                  fontSize: defaultSize * 2,
                  fontWeight: FontWeight.w600)),
          SizedBox(height: defaultSize * 2),
          Container(
            height: defaultSize * 11,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: titleList.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    if (recommandJPOP == 'B') {
                      switch (index) {
                        case 0:
                          //event!: 추천_뷰__발라드
                          Analytics_config().clickBalladRecommendationEvent();
                          break;
                        case 1:
                          //event!: 추천_뷰__일본노래
                          Analytics_config().clickJPOPRecommendationEvent();
                          break;
                        case 2:
                          //event!: 추천_뷰__힙합
                          Analytics_config().clickHipHopRecommendationEvent();
                          break;
                        case 3:
                          //event!: 추천_뷰__알앤비
                          Analytics_config().clickRnbRecommendationEvent();
                          break;
                        case 4:
                          //event!: 추천_뷰_팝
                          Analytics_config().clickPopRecommendationEvent();
                          break;
                        case 5:
                          //event!: 추천_뷰__만화주제가
                          Analytics_config().clickCarttonRecommendationEvent();
                          break;
                        case 6:
                          //event!: 추천_뷰__트로트
                          Analytics_config().clickOldrecommendationEvent();
                          break;
                      }
                    } else {
                      switch (index) {
                        case 0:
                          //event!: 추천_뷰__발라드
                          Analytics_config().clickBalladRecommendationEvent();
                          break;
                        case 1:
                          //event!: 추천_뷰__힙합
                          Analytics_config().clickHipHopRecommendationEvent();
                          break;
                        case 2:
                          //event!: 추천_뷰__알앤비
                          Analytics_config().clickRnbRecommendationEvent();
                          break;
                        case 3:
                          //event!: 추천_뷰_팝
                          Analytics_config().clickPopRecommendationEvent();
                          break;
                        case 4:
                          //event!: 추천_뷰__만화주제가
                          Analytics_config().clickCarttonRecommendationEvent();
                          break;
                        case 5:
                          //event!: 추천_뷰__트로트
                          Analytics_config().clickOldrecommendationEvent();
                          break;
                      }
                    }
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RecommendationDetailScreen(
                                title: titleList[index],
                                songList: songList[index])));
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
                              titleList[index],
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
