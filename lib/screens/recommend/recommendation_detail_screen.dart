import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/music_search_item.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:conopot/models/note.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/screens/feed/song_detail_screen.dart';
import 'package:conopot/screens/note/note_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 맞춤 추천 상세페이지
class RecommendationDetailScreen extends StatelessWidget {
  late String title;
  late List<MusicSearchItem> songList = [];
  RecommendationDetailScreen(
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
              String songNumber = songList[index].songNumber;
              String title = songList[index].title;
              String singer = songList[index].singer;
              Set<Note> entireNote =
                  Provider.of<MusicSearchItemLists>(context, listen: false)
                      .entireNote;
              Note? note;
              for (Note e in entireNote) {
                if (e.tj_songNumber == songNumber) {
                  note = e;
                }
              }
              return GestureDetector(
                onTap: () {
                  if (note != null)
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                SongDetailScreen(note: note!)));
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
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chevron_right, color: kPrimaryWhiteColor),
                        Text("상세정보",
                            style: TextStyle(
                                color: kPrimaryWhiteColor,
                                fontSize: defaultSize))
                      ],
                    )
                  ]),
                ),
              );
            }),
      ),
    );
  }
}
