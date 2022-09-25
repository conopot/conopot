import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/models/pitch_music.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';

class PitchRecommendationDetailScreen extends StatelessWidget {
  late String title;
  late List<FitchMusic> songList = [];
  PitchRecommendationDetailScreen({required this.title, required this.songList});

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

              return GestureDetector(
                onTap: () {
                  Provider.of<NoteData>(context, listen: false)
                      .showAddNoteDialogWithInfo(context,
                          isTj: true,
                          songNumber: songNumber,
                          title: title,
                          singer: singer);
                },
                child: Container(
                  margin: EdgeInsets.fromLTRB(
                      defaultSize, 0, defaultSize, defaultSize),
                  padding: EdgeInsets.all(defaultSize * 1.5),
                  decoration: BoxDecoration(
                      color: kPrimaryLightBlackColor,
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  child: Row(children: [
                    SizedBox(
                      width: defaultSize * 6,
                      child: Center(
                          child: Text("${songNumber}",
                              style: TextStyle(
                                  color: kMainColor,
                                  fontSize: defaultSize * 1.4,
                                  fontWeight: FontWeight.w500))),
                    ),
                    SizedBox(width: defaultSize),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${title}",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: kPrimaryWhiteColor,
                                fontSize: defaultSize * 1.4,
                                fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: defaultSize * 0.5),
                          Text(
                            "${singer}",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: kPrimaryLightWhiteColor,
                                fontSize: defaultSize * 1.2,
                                fontWeight: FontWeight.w300),
                          )
                        ],
                      ),
                    )
                  ]),
                ),
              );
            }),
      ),
    );
  }
}