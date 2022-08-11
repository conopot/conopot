import 'package:conopot/config/analytics_config.dart';
import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/screens/recommend/customize_recommendation_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomizeRecommendation extends StatefulWidget {
  late MusicSearchItemLists musicList;
  CustomizeRecommendation({Key? key, required this.musicList})
      : super(key: key);

  @override
  State<CustomizeRecommendation> createState() =>
      _CustomizeRecommendationState();
}

// 맞춤 추천
class _CustomizeRecommendationState extends State<CustomizeRecommendation> {
  double defaultSize = SizeConfig.defaultSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: defaultSize * 1.5),
          child: Row(
            children: [
              Text("맞춤 추천",
                  style: TextStyle(
                      color: kPrimaryWhiteColor,
                      fontSize: defaultSize * 2,
                      fontWeight: FontWeight.w600)),
              Spacer(),
              if (widget.musicList.userMaxPitch != -1 && widget.musicList.customizeRecommendationList.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    //!event: 추천_뷰__맞춤_추천_더보기
                    Analytics_config().clickCustomizeRecommendationButtonEvent();

                    Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        CustomizeRecommendationDetailScreen(title: "맞춤 추천", songList: widget.musicList.customizeRecommendationList)));
                  },
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                        defaultSize * 0.8,
                        defaultSize * 0.5,
                        defaultSize * 0.8,
                        defaultSize * 0.5),
                    decoration: BoxDecoration(
                        color: kMainColor,
                        borderRadius: BorderRadius.all(Radius.circular(30))),
                    child: Text("더보기",
                        style: TextStyle(
                            color: kPrimaryWhiteColor,
                            fontSize: defaultSize,
                            fontWeight: FontWeight.w400)),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: defaultSize * 2),
        widget.musicList.userMaxPitch == -1
            ? Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: defaultSize * 1.25),
                padding: EdgeInsets.symmetric(vertical: defaultSize * 5),
                decoration: BoxDecoration(
                    color: kPrimaryLightBlackColor,
                    borderRadius: BorderRadius.all(Radius.circular(8))),
                child: Center(
                    child: Text("음역대를 측정해 주세요 😸",
                        style: TextStyle(
                            color: kPrimaryWhiteColor,
                            fontWeight: FontWeight.w400,
                            fontSize: defaultSize * 1.5))),
              )
            : widget.musicList.customizeRecommendationList.isEmpty
                ? Container(
                    width: double.infinity,
                    margin:
                        EdgeInsets.symmetric(horizontal: defaultSize * 1.25),
                    padding: EdgeInsets.symmetric(vertical: defaultSize * 5),
                    decoration: BoxDecoration(
                        color: kPrimaryLightBlackColor,
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    child: Center(
                        child: Text("비슷한 음역대의 노래가 없어요 😹",
                            style: TextStyle(
                                color: kPrimaryWhiteColor,
                                fontWeight: FontWeight.w400,
                                fontSize: defaultSize * 1.5))),
                  )
                : Container(
                    margin: EdgeInsets.symmetric(horizontal: defaultSize),
                    width: double.infinity,
                    height: 185,
                    child: GridView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.musicList.customizeRecommendationList.length,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 60,
                              childAspectRatio: 1 / 3.5,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 15),
                      itemBuilder: (context, index) {
                        String songNumber = widget.musicList.customizeRecommendationList[index].tj_songNumber;
                        String title = widget.musicList.customizeRecommendationList[index].tj_title;
                        String singer = widget.musicList.customizeRecommendationList[index].tj_singer;

                        return GestureDetector(
                          onTap: () {
                            Provider.of<NoteData>(context, listen: false).showAddNoteDialogWithInfo(context, songNumber: songNumber, title : title, singer : singer);
                          },
                          child: GridTile(
                            child: Container(
                              padding: EdgeInsets.all(defaultSize),
                              decoration: BoxDecoration(
                                  color: kPrimaryLightBlackColor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8))),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 40,
                                    child: Center(
                                      child: Text(
                                        "${songNumber}",
                                        style: TextStyle(
                                            color: kMainColor,
                                            fontWeight: FontWeight.w400,
                                            fontSize: defaultSize),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "${title}",
                                            style: TextStyle(
                                                overflow: TextOverflow.ellipsis,
                                                color: kPrimaryWhiteColor,
                                                fontWeight: FontWeight.w400,
                                                fontSize: 11),
                                          ),
                                          Text(
                                            "${singer}",
                                            style: TextStyle(
                                                overflow: TextOverflow.ellipsis,
                                                color: kPrimaryLightWhiteColor,
                                                fontWeight: FontWeight.w400,
                                                fontSize: 9),
                                          )
                                        ]),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ],
    );
  }
}
