import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/models/pitch_music.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PitchRecommendationDetailScreen extends StatelessWidget {
  late String title;
  late List<FitchMusic> songList = [];
  PitchRecommendationDetailScreen(
      {required this.title, required this.songList});

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
        child: songList.isEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: defaultSize * 3),
                  Text("내 음역대에 맞는 노래가 없습니다 😢",
                      style: TextStyle(
                          color: kPrimaryWhiteColor,
                          fontWeight: FontWeight.w400,
                          fontSize: defaultSize * 1.5),
                      textAlign: TextAlign.start),
                  SizedBox(height: defaultSize),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: defaultSize * 1.5),
                      child: Text("1. 음역대를 측정해 주세요.",
                          style: TextStyle(
                              color: kPrimaryWhiteColor,
                              fontWeight: FontWeight.w400,
                              fontSize: defaultSize * 1.5),
                          textAlign: TextAlign.start),
                    ),
                  ),
                  SizedBox(height: defaultSize * 0.25),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: defaultSize * 1.5),
                      child: Text(
                          "2. 너무 낮은 음역대가 측정 됐을 경우 결과를 볼 수 없습니다. 다시 측정해 주세요.",
                          style: TextStyle(
                              color: kPrimaryWhiteColor,
                              fontWeight: FontWeight.w400,
                              fontSize: defaultSize * 1.5),
                          textAlign: TextAlign.start),
                    ),
                  ),
                ],
              )
            : ListView.builder(
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
