import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/music_search_item.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:conopot/models/note.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/screens/feed/song_detail_screen.dart';
import 'package:conopot/screens/note/note_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// 맞춤 추천 상세페이지
class PopularRecommendationDetailScreen extends StatelessWidget {
  late String title;
  late List<MusicSearchItem> songList = [];
  PopularRecommendationDetailScreen(
      {Key? key, required this.title, required this.songList})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    double screenHeight = SizeConfig.screenHeight;
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('M월 d일');
    String today = formatter.format(now);

    return Scaffold(
      appBar: AppBar(
        title: (title == 'TJ 인기차트' || title == '금영 인기차트')
            ? RichText(
                text: TextSpan(children: [
                TextSpan(
                    text: '${title} ',
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: defaultSize * 1.8)),
                TextSpan(
                    text: '${today} 기준',
                    style: TextStyle(
                      color: kMainColor,
                      fontWeight: FontWeight.w300,
                      fontSize: defaultSize * 1.2,
                    ))
              ]))
            : Text('${title}'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView.builder(
            padding: EdgeInsets.only(bottom: screenHeight * 0.3),
            itemCount: songList.length,
            itemBuilder: (context, index) {
              String songNumber = songList[index].songNumber;
              String songTitle = songList[index].title;
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
                          child: (index == 0)
                              ? Image(
                                  width: defaultSize * 4,
                                  height: defaultSize * 4,
                                  image: AssetImage('assets/images/first.png'),
                                )
                              : (index == 1)
                                  ? Image(
                                      width: defaultSize * 4,
                                      height: defaultSize * 4,
                                      image: AssetImage(
                                          'assets/images/second.png'),
                                    )
                                  : (index == 2)
                                      ? Image(
                                          width: defaultSize * 4,
                                          height: defaultSize * 4,
                                          image: AssetImage(
                                              'assets/images/third.png'),
                                        )
                                      : Text(
                                          (index + 1).toString() + "위",
                                          style: TextStyle(
                                            color: kMainColor,
                                            fontSize: defaultSize * 1.4,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                        ),
                      ),
                      title: Text(
                        songTitle,
                        style: TextStyle(
                          overflow: TextOverflow.ellipsis,
                          color: kPrimaryWhiteColor,
                          fontSize: defaultSize * 1.4,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        singer,
                        style: TextStyle(
                            overflow: TextOverflow.ellipsis,
                            color: kPrimaryLightWhiteColor,
                            fontWeight: FontWeight.w500,
                            fontSize: defaultSize * 1.2),
                      ),
                      trailing: IntrinsicWidth(
                        child: Row(
                          children: [
                            SizedBox(
                              width: defaultSize * 5,
                              child: Center(
                                child: Text(
                                  songNumber,
                                  style: TextStyle(
                                      color: kPrimaryWhiteColor,
                                      fontWeight: FontWeight.w500,
                                      fontSize: defaultSize * 1.3),
                                ),
                              ),
                            ),
                            Icon(Icons.chevron_right, color: kPrimaryWhiteColor)
                          ],
                        ),
                      ),
                      onTap: () {
                        if (title != '금영 인기차트') {
                          if (note != null)
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        SongDetailScreen(note: note!)));
                        } else {
                          Provider.of<NoteData>(context, listen: false)
                              .showAddNoteDialogWithInfo(context,
                                  isTj: false,
                                  songNumber: songNumber,
                                  title: songTitle,
                                  singer: singer);
                        }
                      }),
                ),
              );
            }),
      ),
    );
  }
}
