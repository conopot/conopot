import 'package:conopot/config/analytics_config.dart';
import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/models/pitch_item.dart';
import 'package:conopot/models/pitch_music.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 맞춤 추천 상세페이지
class CustomizeRecommendationDetailScreen extends StatelessWidget {
  late String title;
  late List<FitchMusic> songList = [];
  CustomizeRecommendationDetailScreen(
      {Key? key, required this.title, required this.songList})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    double screenHeight = SizeConfig.screenHeight;

    return Scaffold(
      appBar: AppBar(
        title: Text("${title}"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: EdgeInsets.only(bottom: screenHeight * 0.3),
          itemCount: songList.length,
          itemBuilder: (context, index) {
            String songNumber = songList[index].tj_songNumber;
            String title = songList[index].tj_title;
            String singer = songList[index].tj_singer;
            int pitchNum = songList[index].pitchNum;

            return ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              child: Card(
                margin: EdgeInsets.fromLTRB(
                    defaultSize, 0, defaultSize, defaultSize * 0.5),
                color: kPrimaryLightBlackColor,
                elevation: 1,
                child: ListTile(
                    leading: SizedBox(
                      width: defaultSize * 6.5,
                      child: Center(
                        child: Text(
                          pitchNumToString[pitchNum],
                          style: TextStyle(
                            color: kMainColor,
                            fontSize: defaultSize * 1.1,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      title,
                      style: TextStyle(
                        overflow: TextOverflow.ellipsis,
                        color: kPrimaryWhiteColor,
                        fontSize: defaultSize * 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      singer,
                      style: TextStyle(
                          overflow: TextOverflow.ellipsis,
                          color: kPrimaryLightWhiteColor,
                          fontWeight: FontWeight.w300,
                          fontSize: defaultSize * 1.2),
                    ),
                    onTap: () {
                      //!event: 추천_뷰__맞춤_추천_리스트_아이템_클릭
                      Analytics_config()
                          .clickCustomizeRecommendationListItemEvent();

                      Provider.of<NoteData>(context, listen: false)
                          .showAddNoteDialogWithInfo(context,
                              isTj: true,
                              songNumber: songNumber,
                              title: title,
                              singer: singer);
                    }),
              ),
            );
          },
        ),
      ),
    );
  }
}
