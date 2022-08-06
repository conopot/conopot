import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/music_search_item.dart';
import 'package:conopot/models/note_data.dart';
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
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('M월 d일');
    String today = formatter.format(now);

    return Scaffold(
      appBar: AppBar(
        title: (title == 'tj 인기차트' || title == '금영 인기차트')
            ? RichText(text: TextSpan(children: [TextSpan(text: '${title} ', style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: defaultSize * 1.8)), TextSpan(text: '${today} 기준', style: TextStyle(
                              color: kMainColor,
                              fontWeight: FontWeight.w300,
                              fontSize: defaultSize * 1.2,
                              ))]))
            : Text('${title}'),
        centerTitle: true,
      ),
      body: SafeArea(
          child: ListView.builder(
              itemCount: songList.length,
              itemBuilder: (context, index) {
                String songNumber = songList[index].songNumber;
                String title = songList[index].title;
                String singer = songList[index].singer;

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
                                    image:
                                        AssetImage('assets/images/first.png'),
                                  )
                                : (index == 1)
                                    ? Image(
                                        image: AssetImage(
                                            'assets/images/second.png'),
                                      )
                                    : (index == 2)
                                        ? Image(
                                            image: AssetImage(
                                                'assets/images/third.png'),
                                          )
                                        : Text(
                                            (index + 1).toString() + "위",
                                            style: TextStyle(
                                              color: kPrimaryWhiteColor,
                                              fontSize: defaultSize * 1.4,
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
                              fontWeight: FontWeight.w500,
                              fontSize: defaultSize * 1.2),
                        ),
                        trailing: SizedBox(
                          width: defaultSize * 5,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [Text(
                              songNumber,
                              style: TextStyle(
                                  color: kMainColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: defaultSize * 1.3),
                            )],
                          ),
                        ),
                        onTap: () {
                          Provider.of<NoteData>(context, listen: false)
                              .showAddNoteDialogWithInfo(context,
                                  songNumber: songNumber,
                                  title: title,
                                  singer: singer);
                        }),
                  ),
                );
              })),
    );
  }
}
